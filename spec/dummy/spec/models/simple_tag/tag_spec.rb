require 'spec_helper'

describe SimpleTag do
  describe SimpleTag::Tag do
    it 'can get taggable' do
      post = Post.create(:name => 'post')
      comment = Comment.create(:name => 'comment')

      post.set_tags('ruby, jruby')
      comment.set_tags('jruby, java')

      SimpleTag::Tag.pluck(:name).should match_array(['ruby', 'jruby', 'java'])

      tag = SimpleTag::Tag.where(:name => 'ruby').first
      tag.taggings.collect(&:taggable).collect(&:name).should match_array(['post'])

      tag = SimpleTag::Tag.where(:name => 'jruby').first
      tag.taggings.collect(&:taggable).collect(&:name).should match_array(['post', 'comment'])

      post.set_tags('ruby, rvm')
      tag = SimpleTag::Tag.where(:name => 'jruby').first
      tag.taggings.collect(&:taggable).collect(&:name).should match_array(['comment'])
    end

    it 'can get tagger' do
      post = Post.create(:name => 'post')
      user = User.create(:name => 'bob')
      
      post.set_tags 'ruby, rvm', :tagger => user
      post.set_tags 'jruby, java'

      tag = SimpleTag::Tag.where(:name => 'ruby').first
      tag.taggers.pluck(:name).should match_array(['bob'])
      tag = SimpleTag::Tag.where(:name => 'java').first
      tag.taggers.pluck(:name).should be_empty
    end

    it 'can create tag' do
      tag = SimpleTag::Tag.create(:name => 'tag')
      tag.should_not be_nil
    end
  end
end
