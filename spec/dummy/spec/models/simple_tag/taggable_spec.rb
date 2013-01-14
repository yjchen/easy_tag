require 'spec_helper'

describe SimpleTag do
  describe 'without context and tagger' do
    it 'set tags' do
      post = Post.create(:name => 'post')
      expect {
        post.set_tags('rails, ruby')
      }.to change(SimpleTag::Tag, :count).by(2)
      SimpleTag::Tag.pluck(:name).should match_array(['rails', 'ruby'])

      post.tags.pluck(:name).should match_array(['rails', 'ruby'])

      comment = Comment.create(:name => 'comment')
      expect {
        comment.set_tags(['ruby', 'RVM'])
      }.to change(SimpleTag::Tag, :count).by(1)
      SimpleTag::Tag.pluck(:name).should match_array(['rails', 'ruby', 'rvm'])

      comment.tags.pluck(:name).should match_array(['ruby', 'rvm'])
    end
    
    it 'set tags in downcase' do
      post = Post.new(:name => 'post')
      post.set_tags('Rails, RUBY')
      SimpleTag::Tag.pluck(:name).should match_array(['rails', 'ruby'])
    end
  end

  describe 'with context and without tagger' do
    it 'set tags' do
      post = Post.create(:name => 'post')
      expect {
        post.set_tags('rails, ruby', :context => 'ruby')
      }.to change(SimpleTag::TagContext, :count).by(1)
      expect {
        post.set_tags('jruby', :context => 'java')
      }.to change(SimpleTag::TagContext, :count).by(1)
      SimpleTag::TagContext.pluck(:name).should match_array(['ruby', 'java'])
      post.tags.pluck(:name).should match_array(['rails', 'ruby', 'jruby'])
      post.tags.in_context(:ruby).pluck(:name).should match_array(['rails', 'ruby'])
      post.tags.in_context(:java).pluck(:name).should match_array(['jruby'])

      comment = Comment.create(:name => 'comment')
      comment.set_tags(['ruby', 'RVM'], :context => 'ruby')
      SimpleTag::TagContext.pluck(:name).should match_array(['ruby', 'java'])
      comment.tags.pluck(:name).should match_array(['ruby', 'rvm'])
      comment.tags.in_context(:ruby).pluck(:name).should match_array(['ruby', 'rvm'])
    end
  end

  describe 'Basic' do
    it 'is taggable' do
      post = Post.new(:name => 'post')
      post.is_taggable?.should be_true
    end

    it 'is not taggable' do
      user = User.new(:name => 'user')
      expect {
        user.is_taggable?
      }.to raise_error(NoMethodError)
    end
  end

  describe String do
    it 'turn string into tags' do
      s = 'ruby, rails, tag'
      s.to_tags.should match_array(['ruby', 'rails', 'tag'])
    end

    it 'remove whitespaces' do
      s = 'ruby  , rails, tag    '
      s.to_tags.should match_array(['ruby', 'rails', 'tag'])
    end

    it 'remove single quote' do
      s = "'ruby'  , 'rails', tag    "
      s.to_tags.should match_array(['ruby', 'rails', 'tag'])
    end

    it 'remove mixed quote' do
      s = "\"ruby\"  , 'ruby on rails', tag    "
      s.to_tags.should match_array(['ruby', 'ruby on rails', 'tag'])
    end

    it 'set delimiter' do
      s = 'ruby; rails; tag'
      s.to_tags(';').should match_array(['ruby', 'rails', 'tag'])
    end
  end
end
