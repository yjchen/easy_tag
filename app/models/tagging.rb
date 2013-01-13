module SimpleTag
  class Tagging < ActiveRecord::Base
    belongs_to :tag, :class_name => 'SimpleTag::Tag'
    belongs_to :tag_context
    belongs_to :taggable, :polymorphic => true
  end
end