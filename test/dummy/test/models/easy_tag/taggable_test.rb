require 'test_helper'

def match_array(a, b)
  a.sort.must_equal(b.sort)
end

# without context and tagger
class TaggableTest < ActiveSupport::TestCase
  test "no context" do
    post = Post.create(:name => 'post')
    assert_difference "EasyTag::TagContext.count", 0 do
      post.set_tags('rails, ruby')
    end
  end
  
  test "clean old tags" do
    post = Post.create(:name => 'post')
    assert_difference "EasyTag::Tag.count", 2 do
      post.set_tags('rails, ruby')
    end
    assert_equal 2, EasyTag::Tagging.count
    assert_equal 2, post.taggings.count
    assert_equal post.tags.pluck(:name).sort, ['rails', 'ruby'].sort

    assert_difference "EasyTag::Tag.count", 2 do
      post.set_tags('java, jruby')
    end
    assert_equal 2, EasyTag::Tagging.count
    assert_equal 2, post.taggings.count
    assert_equal post.tags.pluck(:name).sort, ['java', 'jruby'].sort
  end

  test 'set tags' do
    post = Post.create(:name => 'post')
    assert_difference "EasyTag::Tag.count", 2 do
      post.set_tags('rails, ruby')
    end
    assert_equal EasyTag::Tag.pluck(:name).sort, ['rails', 'ruby'].sort
    assert_equal post.tags.pluck(:name).sort,  ['rails', 'ruby'].sort

    comment = Comment.create(:name => 'comment')
    assert_difference "EasyTag::Tag.count", 1 do
      comment.set_tags(['ruby', 'RVM'])
    end
    assert_equal EasyTag::Tag.pluck(:name).sort, ['rails', 'ruby', 'rvm'].sort
    assert_equal comment.tags.pluck(:name).sort, ['ruby', 'rvm'].sort
  end
    
  test 'set tags in downcase' do
    post = Post.new(:name => 'post')
    post.set_tags('Rails, RUBY')
    assert_equal EasyTag::Tag.pluck(:name).sort, ['rails', 'ruby'].sort
  end

  # with context and without tagger
  test 'set tags with context and without tagger' do
    post = Post.create(:name => 'post')
    assert_difference "EasyTag::TagContext.count", 1 do
      post.set_tags('rails, ruby', :context => 'ruby')
    end
    assert_difference "EasyTag::TagContext.count", 1 do
      post.set_tags('jruby', :context => 'java')
    end
    assert_equal EasyTag::TagContext.pluck(:name).sort, ['ruby', 'java'].sort
    assert_equal post.tags.pluck(:name).sort, ['rails', 'ruby', 'jruby'].sort
    assert_equal post.tags.in_context(:ruby).pluck(:name).sort, ['rails', 'ruby'].sort
    assert_equal post.tags.in_context(:java).pluck(:name).sort, ['jruby']

    comment = Comment.create(:name => 'comment')
    comment.set_tags(['ruby', 'RVM'], :context => 'ruby')
    assert_equal EasyTag::TagContext.pluck(:name).sort, ['ruby', 'java'].sort
    assert_equal comment.tags.pluck(:name).sort, ['ruby', 'rvm'].sort
    assert_equal comment.tags.in_context(:ruby).pluck(:name).sort, ['ruby', 'rvm'].sort
  end

  # with context and with tagger
  test 'set tags with context and with tagger' do
    post = Post.create(:name => 'post')
    user = User.create(:name => 'bob')

    assert_difference "EasyTag::Tag.count", 2 do
      post.set_tags('rails, ruby', :context => 'ruby', :tagger => user)
    end

    assert_equal user.tags.pluck(:name).sort, ['rails', 'ruby'].sort

    post.set_tags('jruby', :context => 'java')
    assert_equal user.tags.pluck(:name).sort, ['rails', 'ruby'].sort

    post.set_tags('java', :tagger => user)
    assert_equal user.tags.pluck(:name).sort, ['rails', 'ruby', 'java'].sort

    assert_equal post.tags.pluck(:name).sort, ['rails', 'ruby', 'jruby', 'java'].sort
    assert_equal post.tags.in_context(:ruby).pluck(:name).sort, ['rails', 'ruby'].sort
    assert_equal post.tags.in_context(:java).pluck(:name).sort, ['jruby']
    assert_equal post.tags.in_context(:ruby).by_tagger(user).pluck(:name).sort, ['rails', 'ruby'].sort
    assert_equal post.tags.in_context(:java).by_tagger(user).pluck(:name).count, 0
    assert_equal post.tags.by_tagger(user).pluck(:name).sort, ['rails', 'ruby', 'java'].sort
  end
end

describe EasyTag do
  before :each do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

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

      Post.with_tags('ruby').count.must_equal(2)
      match_array(Post.with_tags('ruby').pluck(:name), ['post', 'jruby'])

      Post.with_tags('java, jruby').count.must_equal(2)
      match_array(Post.with_tags('java, jruby').pluck(:name), ['java', 'jruby'])

      Post.with_tags('rails, ruby').to_a.count.must_equal(2)
      match_array(Post.with_tags('rails, ruby').pluck(:name), ['post', 'jruby'])

      Post.with_tags('rails, ruby', {:match => :all}).to_a.count.must_equal(1)
      match_array(Post.with_tags('rails, ruby', {:match => :all}).pluck(:name), ['post'])
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

      match_array(Post.with_tags('rails').pluck(:name), ['post', 'skill'])
      match_array(Post.with_tags('rails').in_context(:skill).pluck(:name), ['skill'])
      match_array(Post.with_tags('rails').by_tagger(user).pluck(:name), ['post'])
      match_array(Post.with_tags('ruby').by_tagger(user).pluck(:name), ['post', 'jruby'])
      match_array(Post.with_tags('ruby').in_context(:skill).by_tagger(user).pluck(:name), ['jruby'])
    end
  end

  it 'remove all tags' do
    post = Post.create(:name => 'post')
    user = User.create(:name => 'bob')

    post.set_tags('rails, ruby')
    match_array(post.tags.pluck(:name), ['rails', 'ruby'])

    post.set_tags(nil)
    post.tags.count.must_equal(0)

    post.set_tags('rails, ruby', :context => 'ruby', :tagger => user)
    match_array(post.tags.pluck(:name), ['rails', 'ruby'])

    post.set_tags(nil)
    post.tags.count.must_equal(2)
    post.set_tags(nil, :context => 'ruby', :tagger => user)
    post.tags.count.must_equal(0)
  end

  describe 'Basic' do
    it 'is taggable' do
      post = Post.new(:name => 'post')
      post.is_taggable?.must_equal(true)
    end

    it 'is not taggable' do
      user = User.new(:name => 'user')
      user.is_taggable?.must_equal(false)
    end
  end

  describe String do
    it 'turn string into tags' do
      s = 'ruby, rails, tag'
      match_array(s.to_tags, ['ruby', 'rails', 'tag'])
    end

    it 'remove whitespaces' do
      s = 'ruby  , rails, tag    '
      match_array(s.to_tags, ['ruby', 'rails', 'tag'])
    end

    it 'remove single quote' do
      s = "'ruby'  , 'rails', tag    "
      match_array(s.to_tags, ['ruby', 'rails', 'tag'])
    end

    it 'remove mixed quote' do
      s = "\"ruby\"  , 'ruby on rails', tag    "
      match_array(s.to_tags, ['ruby', 'ruby on rails', 'tag'])
    end

    it 'set delimiter' do
      s = 'ruby; rails; tag'
      match_array(s.to_tags(';'), ['ruby', 'rails', 'tag'])
    end
  end
end
