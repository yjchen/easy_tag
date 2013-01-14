module SimpleTag
  module Taggable
    extend ActiveSupport::Concern

    included do
      has_many :taggings, :as => :taggable, :dependent => :destroy,
               :class_name => 'SimpleTag::Tagging'
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

        def by_tagger(tagger)
          where('1 == 1')
        end
      end
    end # end of included

    module ClassMethods
    end # end of class methods

    def set_tags(tag_list, options = {})
      options.reverse_merge! :context => nil, 
                             :tagger => nil, 
                             :downcase => true,
                             :delimiter => ','

      if block_given?
        tags = yield(klass)
      else
        tags = compact_tag_list(tag_list, options[:downcase], options[:delimiter])
      end

      context = compact_context(options[:context])
      tagger = compact_tagger(options[:tagger])

      # Remove old tags
      self.taggings.where(:tag_context_id => context.try(:id), :tagger_id => tagger.try(:id)).destroy_all
      # TODO: should remove unused tags and contexts

      tags.each do |t|
        tag = SimpleTag::Tag.where(:name => t).first_or_create
        raise SimgleTag::InvalidTag if tag.nil?
        self.taggings.where(:tagger_id => tagger.try(:id), :tag_context_id => context.try(:id), :tag_id => tag.id).first_or_create
      end
    end

    def tags=(tag_list)
      self.set_tags(tag_list)
    end

    def add_tags(tag_list, options = {})
      options.reverse_merge! :context => nil, :tagger => nil

      if block_given?
        tags = yield(klass)
      else
        tags = compact_tag_list(tag_list, options[:downcase])
      end
    end

    def remove_tags(tag_list, options = {})
      options.reverse_merge! :context => nil, :tagger => nil

      if block_given?
        tags = yield(klass)
      else
        tags = compact_tag_list(tag_list, options[:downcase])
      end
    end

    def is_taggable?
      return true
    end

    protected

    def compact_tag_list(tag_list, downcase = false, delimiter = ',')
      if (tag_list.is_a?(String))
        tag_list.downcase! if downcase
        tag_list.to_tags(delimiter)
      elsif (tag_list.is_a?(Array))
        tag_list.collect { |t| t.downcase }
      else
        raise SimpleTag::InvalidTagList
      end
    end

    def compact_context(context)
      return nil if context.blank?

      if (context.is_a?(String) || context.is_a?(Symbol))
        return SimpleTag::TagContext.where(:name => context.to_s).first_or_create
      elsif (context.is_a?(Integer))
        return SimpleTag::TagContext.where(:id => context).first_or_create
      end

      raise SimpleTag::InvalidTagContext
    end

    def compact_tagger(tagger)
      return nil if tagger.blank?
      return tagger if tagger.is_tagger?

      if (tagger.is_a?(Integer))
        if SimpleTag::Tagger.class_variable_defined?(:@@tagger_class)
          klass = SimpleTag::Tagger.class_variable_get(:@@tagger_class)
          return klass.where(:id => tagger).first_or_create
        else
          raise SimpleTag::NoTaggerDefined
        end
      end

      raise SimpleTag::InvalidTagger
    end
  end
end

class String
  def to_tags(delimiter = ',')
    self.split(delimiter).collect do |t|
      t.strip.gsub(/\A["']|["']\Z/, '')
    end
  end
end
