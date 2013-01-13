module SimpleTag
  module Tagger
    extend ActiveSupport::Concern

    included do
      has_many :taggings, :as => :tagger, :dependent => :destroy,
               :class_name => 'SimpleTag::Tagging'
    end # end of included

    module ClassMethods
    end # end of class methods

    def is_tagger?
      return true
    end
  end
end
