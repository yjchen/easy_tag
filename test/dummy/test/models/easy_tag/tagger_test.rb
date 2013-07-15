require 'test_helper'

def match_array(a, b)
  a.sort.must_equal(b.sort)
end

describe EasyTag do
  before :each do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  describe 'with context and with tagger' do
    it 'in context' do
      post = Post.create(:name => 'post')
      user = User.create(:name => 'bob')

      post.set_tags('rails, ruby, jruby', :context => 'ruby', :tagger => user)
      post.set_tags('java, jruby', :context => 'java', :tagger => user)

      match_array(user.tags.in_context('ruby').pluck(:name), ['rails', 'ruby', 'jruby'])
      match_array(user.tags.in_context('java').pluck(:name), ['java', 'jruby'])
    end

    it 'get uniq tags' do
      user = User.create(:name => 'bob')

      post = Post.create(:name => 'post')
      post.set_tags('ruby', :tagger => user)
      post.set_tags('ruby', :context => :skill, :tagger => user)

      ruby = Post.create(:name => 'ruby')
      ruby.set_tags('ruby', :context => :skill, :tagger => user)

      user.tags.count.must_equal(1)
      match_array(user.tags.pluck(:name), ['ruby'])

      match_array(post.tags.pluck(:name), ['ruby'])
    end
  end

  describe EasyTag::Tagger do
    it 'is tagger' do
      user = User.new(:name => 'post')
      user.is_tagger?.must_equal(true)
      EasyTag::Tagger.class_variable_get(:@@tagger_class).must_equal(User)
    end

    it 'is not tagger' do
      post = Post.new(:name => 'user')
      post.is_tagger?.must_equal(false)
    end
  end
end
