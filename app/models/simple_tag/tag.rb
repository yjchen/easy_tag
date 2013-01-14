class SimpleTag::Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy, 
                      :class_name => 'SimpleTag::Tagging'
  has_many :taggers, :through => :taggings

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name
end
