class SimpleTag::TagContext < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy,
                      :class_name => 'SimpleTag::Tagging'
  has_many :tags, :through => :taggings

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name

  def self.get_id(context)
    if context.is_a?(String) || context.is_a?(Symbol)
      context_id = self.where(:name => context.to_s).first
    elsif context.is_a?(Integer)
      context_id = context
    else
      raise SimpleTag::InvalidContext
    end
    context_id
  end
end
