require 'spec_helper'

describe EasyTag do
  describe EasyTag::Tag do
    it 'compact tag list' do
      tags = EasyTag::Tag.compact_tag_list('ruby, rails')
      tags.should match_array(['ruby', 'rails'])

      tags = EasyTag::Tag.compact_tag_list(['ruby', 'rails'])
      tags.should match_array(['ruby', 'rails'])

      tags = EasyTag::Tag.compact_tag_list('ruby; rails', {:delimiter => ';'})
      tags.should match_array(['ruby', 'rails'])

      tags = EasyTag::Tag.compact_tag_list('ruby; Rails', {:delimiter => ';', :downcase => true})
      tags.should match_array(['ruby', 'rails'])

    end
    
    it 'can get taggable' do
      post = Post.create(:name => 'post')
      comment = Comment.create(:name => 'comment')

      post.set_tags('ruby, jruby')
      comment.set_tags('jruby, java')

      EasyTag::Tag.pluck(:name).should match_array(['ruby', 'jruby', 'java'])

      tag = EasyTag::Tag.where(:name => 'ruby').first
      tag.taggings.collect(&:taggable).collect(&:name).should match_array(['post'])

      tag = EasyTag::Tag.where(:name => 'jruby').first
      tag.taggings.collect(&:taggable).collect(&:name).should match_array(['post', 'comment'])

      post.set_tags('ruby, rvm')
      tag = EasyTag::Tag.where(:name => 'jruby').first
      tag.taggings.collect(&:taggable).collect(&:name).should match_array(['comment'])
    end

    it 'can get tagger' do
      post = Post.create(:name => 'post')
      user = User.create(:name => 'bob')
      
      post.set_tags 'ruby, rvm', :tagger => user
      post.set_tags 'jruby, java'

      tag = EasyTag::Tag.where(:name => 'ruby').first
      tag.taggers.pluck(:name).should match_array(['bob'])
      tag = EasyTag::Tag.where(:name => 'java').first
      tag.taggers.pluck(:name).should be_empty
    end

    it 'can create tag' do
      tag = EasyTag::Tag.create(:name => 'tag')
      tag.should_not be_nil
    end
  end
end
