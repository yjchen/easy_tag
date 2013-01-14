require 'spec_helper'

describe SimpleTag do
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
