module SimpleTag
  module Tagger
    extend ActiveSupport::Concern

    included do
      has_many :taggings, :as => :tagger, :dependent => :destroy,
               :class_name => 'SimpleTag::Tagging'
      has_many :tags, :through => :taggings do
        def in_context(context)
          return where('1 == 1')
        end
      end
    end # end of included

    module ClassMethods
    end # end of class methods

    def is_tagger?
      return true
    end
  end
end
