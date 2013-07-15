class User < ActiveRecord::Base
  acts_as_tagger

  attr_accessible :name
end
