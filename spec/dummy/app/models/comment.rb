class Comment < ActiveRecord::Base
  acts_as_taggable

  attr_accessible :name
end
