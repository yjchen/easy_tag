class SimpleTag::Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy, 
                      :class_name => 'SimpleTag::Tagging'
  has_many :taggables, :through => :taggings

  scope :in_context, lambda { |context|
    return where('1 == 1')
  }

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name
end
