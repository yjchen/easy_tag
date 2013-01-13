module SimpleTag
  module Taggable
    extend ActiveSupport::Concern

    included do
      has_many :taggings, :as => :taggable, :dependent => :destroy,
               :class_name => 'SimpleTag::Tagging'
    end # end of included

    module ClassMethods
    end # end of class methods

    def is_taggable?
      return true
    end
  end
end
