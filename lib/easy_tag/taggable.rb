module EasyTag
  module Taggable
    extend ActiveSupport::Concern

    included do
      has_many :taggings, :as => :taggable, :dependent => :destroy,
               :class_name => 'EasyTag::Tagging'
      has_many :tags, :through => :taggings, :uniq => true do
        def in_context(context)
          context_id = EasyTag::TagContext.get_id(context)
          where('easy_tag_taggings.tag_context_id = ?', context_id)
        end

        def by_tagger(tagger)
          tagger_id = EasyTag::Tagger.get_id(tagger)
          where('easy_tag_taggings.tagger_id = ?', tagger_id)
        end
      end # end of has_many :tags

      scope :with_tags, ->(tag_list, options = {}) {
        options.reverse_merge! :match => :any

        if block_given?
          tags = yield(klass)
        else
          tags = EasyTag::Tag.compact_tag_list(tag_list, options.slice(:downcase, :delimiter))
        end

        return where('1 == 2') if tags.nil?

        query = tags.collect { |t| "name = '#{t}'" }.join(' OR ')
        tag_ids = EasyTag::Tag.where(query).pluck(:id)

        if options[:match] == :all
          ids = nil
          tag_ids.each do |tag_id|
#            p EasyTag::Tag.find(tag_id)
            taggable_ids = EasyTag::Tagging.where(:tag_id => tag_id).where(:taggable_type => self.model_name).pluck(:taggable_id).to_a
            if ids
              ids = ids & taggable_ids
            else
              ids = taggable_ids # first tag
            end
          end
          joins(:taggings).where(:id => ids).uniq
        else
          # :any
          joins(:taggings).where('easy_tag_taggings.tag_id' => tag_ids).uniq
        end

      } do
        def in_context(context)
          context_id = EasyTag::TagContext.get_id(context)
          where('easy_tag_taggings.tag_context_id = ?', context_id)
        end

        def by_tagger(tagger)
          tagger_id = EasyTag::Tagger.get_id(tagger)
          where('easy_tag_taggings.tagger_id = ?', tagger_id)
        end
      end # end of scope :with_tags
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
        tags = EasyTag::Tag.compact_tag_list(tag_list, options.slice(:downcase, :delimiter))
      end

      context = compact_context(options[:context])
      tagger = compact_tagger(options[:tagger])

      # Remove old tags
      self.taggings.where(:tag_context_id => context.try(:id), :tagger_id => tagger.try(:id)).destroy_all
      # TODO: should remove unused tags and contexts

      if tags
        tags.each do |t|
          tag = EasyTag::Tag.where(:name => t).first_or_create
          raise SimgleTag::InvalidTag if tag.nil?
          self.taggings.where(:tagger_id => tagger.try(:id), :tag_context_id => context.try(:id), :tag_id => tag.id).first_or_create
        end
      end
    end

    def tags=(tag_list)
      self.set_tags(tag_list)
    end

    def is_taggable?
      return true
    end

    protected

    def compact_context(context)
      return nil if context.blank?

      if (context.is_a?(String) || context.is_a?(Symbol))
        return EasyTag::TagContext.where(:name => context.to_s).first_or_create
      elsif (context.is_a?(Integer))
        return EasyTag::TagContext.where(:id => context).first_or_create
      end

      raise EasyTag::InvalidTagContext
    end

    def compact_tagger(tagger)
      return nil if tagger.blank?

      if (tagger.is_a?(Integer))
        if EasyTag::Tagger.class_variable_defined?(:@@tagger_class)
          klass = EasyTag::Tagger.class_variable_get(:@@tagger_class)
          return klass.where(:id => tagger).first_or_create
        else
          raise EasyTag::NoTaggerDefined
        end
      elsif tagger.is_tagger?
        return tagger
      end

      raise EasyTag::InvalidTagger
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
