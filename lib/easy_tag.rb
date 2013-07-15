require 'easy_tag/engine'
require 'easy_tag/taggable'
require 'easy_tag/tagger'

# For some reason, this does not work when set in app/models/easy_tag.rb
# Therefore, it is put here.
module EasyTag
  def self.table_name_prefix
    'easy_tag_'
  end
end

if defined?(ActiveRecord::Base)
  class ActiveRecord::Base
    def is_taggable?
      return false
    end

    def is_tagger?
      return false
    end

    def self.acts_as_taggable(options = {})
      options.reverse_merge!({})
      include EasyTag::Taggable
    end

    def self.acts_as_tagger(options = {})
      options.reverse_merge!({})
      include EasyTag::Tagger

      EasyTag::Tagger.class_variable_set(:@@tagger_class, self)
      EasyTag::Tagging.belongs_to :tagger, :class_name => self.model_name
    end
  end
end
