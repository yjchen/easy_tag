module SimpleTag
  module Tagger
    extend ActiveSupport::Concern

    included do
      has_many :taggings, :dependent => :destroy,
               :class_name => 'SimpleTag::Tagging',
               :foreign_key => 'tagger_id'
      has_many :tags, :through => :taggings, :uniq => true do
        def in_context(context)
          context_id = SimpleTag::TagContext.get_id(context)
          where('simple_tag_taggings.tag_context_id = ?', context_id)
        end
      end
    end # end of included

    module ClassMethods
      def get_id(tagger)
        if tagger.is_a?(Integer)
          tagger_id = tagger
        elsif tagger.is_tagger?
          tagger_id = tagger.id
        else
          raise SimpleTag::InvalidTagger
        end
        tagger_id
      end
    end # end of class methods

    extend ClassMethods # to be use in SimpleTag::Tag module

    def is_tagger?
      return true
    end
  end
end
