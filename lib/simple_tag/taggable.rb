module SimpleTag
  module Taggable
    extend ActiveSupport::Concern

    included do
      has_many :taggings, :as => :taggable, :dependent => :destroy,
               :class_name => 'SimpleTag::Tagging'
      has_many :tags, :through => :taggings
    end # end of included

    module ClassMethods
    end # end of class methods

    def set_tags(tag_list, options = {})
      options.reverse_merge! :context => :tag, :tagger => nil, :downcase => true

      if block_given?
        tags = yield(klass)
      else
        tags = compact_tag_list(tag_list, options[:downcase])
      end

      context = compact_context(options[:context])
      tagger = compact_tagger(options[:tagger])

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
      options.reverse_merge! :context => :tag, :tagger => nil

      if block_given?
        tags = yield(klass)
      else
        tags = compact_tag_list(tag_list, options[:downcase])
      end
    end

    def remove_tags(tag_list, options = {})
      options.reverse_merge! :context => :tag, :tagger => nil

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

    def compact_tag_list(tag_list, downcase = false)
      if (tag_list.is_a?(String))
        tag_list.downcase! if downcase
        tag_list.to_tags
      elsif (tag_list.is_a?(Array))
        tag_list.collect { |t| t.downcase }
      else
        raise SimpleTag::InvalidTagList
      end
    end

    def compact_context(context)
      if (context.is_a?(String) || context.is_a?(Symbol))
        return SimpleTag::TagContext.where(:name => context.to_s).first_or_create
      elsif (context.is_a?(Integer))
        return SimpleTag::TagContext.where(:id => context).first_or_create
      elsif (context.nil?)
        return nil
      end

      raise SimpleTag::InvalidTagContext
    end

    def compact_tagger(tagger)
      klass = SimpleTag::Tagger.class_variable_get(:@@tagger_class)
      if (tagger.is_a?(String) || tagger.is_a?(Symbol))
        return klass.where(:name => tagger.to_s).first_or_create
      elsif (tagger.is_a?(Integer))
        return klass.where(:id => tagger).first_or_create
      elsif (tagger.nil?)
        return nil
      end

      raise SimpleTag::InvalidTagger
    end
  end
end

class String
  def to_tags
    self.split(',').collect do |t|
      t.strip.gsub(/\A["']|["']\Z/, '')
    end
  end
end
