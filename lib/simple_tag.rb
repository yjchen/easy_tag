require 'simple_tag/engine'
require 'simple_tag/taggable.rb'
require 'simple_tag/tagger.rb'

# For some reason, this does not work when set in app/models/simple_tag.rb
# Therefore, it is put here.
module SimpleTag
  def self.table_name_prefix
    'simple_tag_'
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
      include SimpleTag::Taggable
    end

    def self.acts_as_tagger(options = {})
      options.reverse_merge!({})
      include SimpleTag::Tagger

      SimpleTag::Tagger.class_variable_set(:@@tagger_class, self)
      self.has_many :taggings, :dependent => :destroy, 
                               :class_name => 'SimpleTag::Tagging',
                               :foreign_key => 'tagger_id'
      self.has_many :tags, :through => :taggings
      SimpleTag::Tagging.belongs_to :tagger, :class_name => self.model_name
    end
  end
end
