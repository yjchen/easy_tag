module SimpleTag
  module Tagger
    extend ActiveSupport::Concern

    included do
      has_many :taggings, :dependent => :destroy,
               :class_name => 'SimpleTag::Tagging',
               :foreign_key => 'tagger_id'
      has_many :tags, :through => :taggings do
        def in_context(context)
          if context.is_a?(String) || context.is_a?(Symbol)
            context_id = SimpleTag::TagContext.where(:name => context.to_s).first
          elsif context.is_a?(Number)
            context_id = context
          else
            raise SimpleTag::InvalidContext
          end
          where('simple_tag_taggings.tag_context_id = ?', context_id)
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
