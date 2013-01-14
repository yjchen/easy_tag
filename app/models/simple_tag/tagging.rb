class SimpleTag::Tagging < ActiveRecord::Base
  belongs_to :tag, :class_name => 'SimpleTag::Tag'
  belongs_to :tag_context, :class_name => 'SimpleTag::TagContext'
  belongs_to :taggable, :polymorphic => true
end
