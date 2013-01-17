class EasyTag::Tagging < ActiveRecord::Base
  belongs_to :tag, :class_name => 'EasyTag::Tag'
  belongs_to :tag_context, :class_name => 'EasyTag::TagContext'
  belongs_to :taggable, :polymorphic => true
end
