require 'spec_helper'

describe SimpleTag do
  describe SimpleTag::Taggable do
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
end
