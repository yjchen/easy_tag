class EasyTag::Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy, 
                      :class_name => 'EasyTag::Tagging'
  has_many :taggers, :through => :taggings

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
    elsif tag_list.blank?
      tags = nil
    else
      raise EasyTag::InvalidTagList
    end

    tags
  end
end
