require 'spec_helper'

describe SimpleTag do
  describe SimpleTag::Tagger do
    it 'is tagger' do
      user = User.new(:name => 'post')
      user.is_tagger?.should be_true
    end

    it 'is not tagger' do
      post = Post.new(:name => 'user')
      expect {
        post.is_tagger?
      }.to raise_error(NoMethodError)
    end
  end
end
