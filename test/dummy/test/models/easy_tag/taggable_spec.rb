require 'spec_helper'

describe EasyTag do
  describe 'taggable with_tags' do
    it 'return match tags' do
      post = Post.create(:name => 'post')
      post.set_tags('rails, ruby')
      java = Post.create(:name => 'java')
      java.set_tags('java, jsp')
      jruby = Post.create(:name => 'jruby')
      jruby.set_tags('ruby, jruby')
      comment = Comment.create(:name => 'comment')
      comment.set_tags('rails, ruby')

      Post.with_tags('ruby').count.should eq(2)
      Post.with_tags('ruby').pluck(:name).should match_array(['post', 'jruby'])

      Post.with_tags('java, jruby').count.should eq(2)
      Post.with_tags('java, jruby').pluck(:name).should match_array(['java', 'jruby'])

      Post.with_tags('rails, ruby').to_a.count.should eq(2)
      Post.with_tags('rails, ruby').pluck(:name).should match_array(['post', 'jruby'])

      Post.with_tags('rails, ruby', {:match => :all}).to_a.count.should eq(1)
      Post.with_tags('rails, ruby', {:match => :all}).pluck(:name).should match_array(['post'])
    end

    it 'return match tags in context and with tagger' do
      user = User.create(:name => 'bob')
      post = Post.create(:name => 'post')
      post.set_tags('rails, ruby', :tagger => user)
      skill = Post.create(:name => 'skill')
      skill.set_tags('rails, ruby', :context => :skill)
      java = Post.create(:name => 'java')
      java.set_tags('java, jsp')
      jruby = Post.create(:name => 'jruby')
      jruby.set_tags('ruby, jruby', :context => :skill, :tagger => user)
      comment = Comment.create(:name => 'comment')
      comment.set_tags('rails, ruby')

      Post.with_tags('rails').pluck(:name).should match_array(['post', 'skill'])
      Post.with_tags('rails').in_context(:skill).pluck(:name).should match_array(['skill'])
      Post.with_tags('rails').by_tagger(user).pluck(:name).should match_array(['post'])
      Post.with_tags('ruby').by_tagger(user).pluck(:name).should match_array(['post', 'jruby'])
      Post.with_tags('ruby').in_context(:skill).by_tagger(user).pluck(:name).should match_array(['jruby'])
    end
  end

  describe 'without context and tagger' do
    it 'no context' do
      post = Post.create(:name => 'post')
      expect {
        post.set_tags('rails, ruby')
      }.to change(EasyTag::TagContext, :count).by(0)
    end

    it 'clean old tags' do
      post = Post.create(:name => 'post')
      expect {
        post.set_tags('rails, ruby')
      }.to change(EasyTag::Tag, :count).by(2)
      EasyTag::Tagging.count.should eq(2)
      post.taggings.count.should eq(2)
      post.tags.pluck(:name).should match_array(['rails', 'ruby'])

      expect {
        post.set_tags('java, jruby')
      }.to change(EasyTag::Tag, :count).by(2)
      EasyTag::Tagging.count.should eq(2)
      post.taggings.count.should eq(2)
      post.tags.pluck(:name).should match_array(['java', 'jruby'])
    end

    it 'set tags' do
      post = Post.create(:name => 'post')
      expect {
        post.set_tags('rails, ruby')
      }.to change(EasyTag::Tag, :count).by(2)
      EasyTag::Tag.pluck(:name).should match_array(['rails', 'ruby'])

      post.tags.pluck(:name).should match_array(['rails', 'ruby'])

      comment = Comment.create(:name => 'comment')
      expect {
        comment.set_tags(['ruby', 'RVM'])
      }.to change(EasyTag::Tag, :count).by(1)
      EasyTag::Tag.pluck(:name).should match_array(['rails', 'ruby', 'rvm'])

      comment.tags.pluck(:name).should match_array(['ruby', 'rvm'])
    end
    
    it 'set tags in downcase' do
      post = Post.new(:name => 'post')
      post.set_tags('Rails, RUBY')
      EasyTag::Tag.pluck(:name).should match_array(['rails', 'ruby'])
    end
  end

  describe 'with context and without tagger' do
    it 'set tags' do
      post = Post.create(:name => 'post')
      expect {
        post.set_tags('rails, ruby', :context => 'ruby')
      }.to change(EasyTag::TagContext, :count).by(1)
      expect {
        post.set_tags('jruby', :context => 'java')
      }.to change(EasyTag::TagContext, :count).by(1)
      EasyTag::TagContext.pluck(:name).should match_array(['ruby', 'java'])
      post.tags.pluck(:name).should match_array(['rails', 'ruby', 'jruby'])
      post.tags.in_context(:ruby).pluck(:name).should match_array(['rails', 'ruby'])
      post.tags.in_context(:java).pluck(:name).should match_array(['jruby'])

      comment = Comment.create(:name => 'comment')
      comment.set_tags(['ruby', 'RVM'], :context => 'ruby')
      EasyTag::TagContext.pluck(:name).should match_array(['ruby', 'java'])
      comment.tags.pluck(:name).should match_array(['ruby', 'rvm'])
      comment.tags.in_context(:ruby).pluck(:name).should match_array(['ruby', 'rvm'])
    end
  end

  describe 'with context and wit tagger' do
    it 'set tags' do
      post = Post.create(:name => 'post')
      user = User.create(:name => 'bob')

      expect {
        post.set_tags('rails, ruby', :context => 'ruby', :tagger => user)
      }.to change(EasyTag::Tag, :count).by(2)

      user.tags.pluck(:name).should match_array(['rails', 'ruby'])

      post.set_tags('jruby', :context => 'java')
      user.tags.pluck(:name).should match_array(['rails', 'ruby'])

      post.set_tags('java', :tagger => user)
      user.tags.pluck(:name).should match_array(['rails', 'ruby', 'java'])

      post.tags.pluck(:name).should match_array(['rails', 'ruby', 'jruby', 'java'])
      post.tags.in_context(:ruby).pluck(:name).should match_array(['rails', 'ruby'])
      post.tags.in_context(:java).pluck(:name).should match_array(['jruby'])
      post.tags.in_context(:ruby).by_tagger(user).pluck(:name).should match_array(['rails', 'ruby'])
      post.tags.in_context(:java).by_tagger(user).pluck(:name).should be_empty
      post.tags.by_tagger(user).pluck(:name).should match_array(['rails', 'ruby', 'java'])
    end
  end

  it 'remove all tags' do
    post = Post.create(:name => 'post')
    user = User.create(:name => 'bob')

    post.set_tags('rails, ruby')
    post.tags.pluck(:name).should match_array(['rails', 'ruby'])

    post.set_tags(nil)
    post.tags.count.should eq(0)

    post.set_tags('rails, ruby', :context => 'ruby', :tagger => user)
    post.tags.pluck(:name).should match_array(['rails', 'ruby'])

    post.set_tags(nil)
    post.tags.count.should eq(2)
    post.set_tags(nil, :context => 'ruby', :tagger => user)
    post.tags.count.should eq(0)
  end

  describe 'Basic' do
    it 'is taggable' do
      post = Post.new(:name => 'post')
      post.is_taggable?.should be_true
    end

    it 'is not taggable' do
      user = User.new(:name => 'user')
      user.is_taggable?.should be_false
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
