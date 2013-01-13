require 'spec_helper'

describe 'Foo' do
  it 'should return true' do
    true == true
  end

  it 'access database' do
    tag = SimpleTag::Tag.create(:name => 'tag')
    tag.should_not be_nil
  end
end
