require 'test_helper'
require 'database_cleaner'

def match_array(a, b)
  a.sort.must_equal(b.sort)
end

describe EasyTag do
  describe EasyTag::Tag do
    before :each do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end

    after :each do
      DatabaseCleaner.clean
    end

    it 'compact tag list' do
      tags = EasyTag::Tag.compact_tag_list('ruby, rails')
      match_array(tags, ['ruby', 'rails'])

      tags = EasyTag::Tag.compact_tag_list(['ruby', 'rails'])
      match_array(tags, ['ruby', 'rails'])

      tags = EasyTag::Tag.compact_tag_list('ruby; rails', {:delimiter => ';'})
      match_array(tags, ['ruby', 'rails'])

      tags = EasyTag::Tag.compact_tag_list('ruby; Rails', {:delimiter => ';', :downcase => true})
      match_array(tags, ['ruby', 'rails'])
    end

    it 'can get taggable' do
      post = Post.create(:name => 'post')
      comment = Comment.create(:name => 'comment')

      post.set_tags('ruby, jruby')
      comment.set_tags('jruby, java')

      match_array(EasyTag::Tag.pluck(:name), ['ruby', 'jruby', 'java'])

      tag = EasyTag::Tag.where(:name => 'ruby').first
      match_array(tag.taggings.collect(&:taggable).collect(&:name), ['post'])

      tag = EasyTag::Tag.where(:name => 'jruby').first
      match_array(tag.taggings.collect(&:taggable).collect(&:name), ['post', 'comment'])

      post.set_tags('ruby, rvm')
      tag = EasyTag::Tag.where(:name => 'jruby').first
      match_array(tag.taggings.collect(&:taggable).collect(&:name), ['comment'])
    end

    it 'can get tagger' do
      post = Post.create(:name => 'post')
      user = User.create(:name => 'bob')
      
      post.set_tags 'ruby, rvm', :tagger => user
      post.set_tags 'jruby, java'

      tag = EasyTag::Tag.where(:name => 'ruby').first
      match_array(tag.taggers.pluck(:name), ['bob'])

      tag = EasyTag::Tag.where(:name => 'java').first
      tag.taggers.pluck(:name).count.must_equal(0)
    end

    it 'can create tag' do
      tag = EasyTag::Tag.create(:name => 'tag')
      tag.wont_be_nil
    end
  end
end
