# frozen_string_literal: true

module ActsAsTaggable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_taggable
      has_many :taggings, as: :taggable, dependent: :destroy
      has_many :tags, through: :taggings

      attr_accessor :tag_list_is_dirty

      include ActsAsTaggable::InstanceMethods
    end
  end

  module InstanceMethods
    def tag_list=(list)
      return if tag_list == list

      self.tag_list_is_dirty = true
      self.tags = parse_tag_list(list).map { |tag| Tag.where(name: tag).first_or_create }
    end

    def tag_list
      query_string = Arel.sql('DISTINCT name') # tags.name format is validated.
      tags.pluck(query_string).compact.join(' ').fix_encoding_if_invalid
    end

    private

    def parse_tag_list(list)
      return [] if list.blank?

      list.delete('"').split(/\s/).reject(&:blank?)
    end
  end
end

ApplicationRecord.include ActsAsTaggable
