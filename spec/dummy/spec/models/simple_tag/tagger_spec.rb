require 'spec_helper'

describe SimpleTag do
  describe 'with context and with tagger' do
    it 'in context' do
      post = Post.create(:name => 'post')
      user = User.create(:name => 'bob')

      post.set_tags('rails, ruby, jruby', :context => 'ruby', :tagger => user)
      post.set_tags('java, jruby', :context => 'java', :tagger => user)

      user.tags.in_context('ruby').pluck(:name).should match_array(['rails', 'ruby', 'jruby'])
      user.tags.in_context('java').pluck(:name).should match_array(['java', 'jruby'])
    end
  end

  describe SimpleTag::Tagger do
    it 'is tagger' do
      user = User.new(:name => 'post')
      user.is_tagger?.should be_true
      SimpleTag::Tagger.class_variable_get(:@@tagger_class).should eq(User)
    end

    it 'is not tagger' do
      post = Post.new(:name => 'user')
      post.is_tagger?.should be_false
    end
  end
end
