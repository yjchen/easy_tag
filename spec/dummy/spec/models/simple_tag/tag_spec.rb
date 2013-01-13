require 'spec_helper'

describe SimpleTag do
  describe SimpleTag::Tag do
    it 'can create tag' do
      tag = SimpleTag::Tag.create(:name => 'tag')
      tag.should_not be_nil
    end
  end
end
