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
    def self.acts_as_taggable(options = {})
      options.reverse_merge!({})
      include SimpleTag::Taggable
    end

    def self.acts_as_tagger(options = {})
      options.reverse_merge!({})
      include SimpleTag::Tagger

      SimpleTag::Tagger.class_variable_set(:@@tagger_class, self)
    end
  end
end
