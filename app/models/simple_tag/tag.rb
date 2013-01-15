class SimpleTag::Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy, 
                      :class_name => 'SimpleTag::Tagging'
  has_many :taggers, :through => :taggings

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name

  def self.compact_tag_list(tag_list, options = {})
    options.reverse_merge! :downcase => true, 
                           :delimiter => ','
    if (tag_list.is_a?(String))
      tag_list.downcase! if options[:downcase]
      tags = tag_list.to_tags(options[:delimiter])
    elsif (tag_list.is_a?(Array))
      if options[:downcase]
        tags = tag_list.collect { |t| t.downcase }
      else
        tags = tag_list
      end
    else
      raise SimpleTag::InvalidTagList
    end

    tags
  end
end
