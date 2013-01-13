require 'simple_tag/engine'
require 'simple_tag/taggable.rb'
require 'simple_tag/tagger.rb'

if defined?(ActiveRecord::Base)
  class ActiveRecord::Base
    def self.acts_as_taggable(options = {})
      options.reverse_merge!({})
      include SimpleTag::Taggable
    end

    def self.acts_as_tagger(options = {})
      options.reverse_merge!({})
      include SimpleTag::Tagger
    end
  end
end
