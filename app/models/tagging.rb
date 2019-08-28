# frozen_string_literal: true

class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, polymorphic: true

  after_create :recalc_weight!
  after_destroy :recalc_weight!

  class << self
    def tag_weight_sql(klass, tag_ids)
      tags = Tag.arel_table
      Tagging.select('taggings.taggable_id as project_id, SUM(tags.weight) AS weight')
             .joins(:tag)
             .where(tags[:id].in(tag_ids))
             .where(taggable_type: klass)
             .group(:taggable_id).to_sql
    end
  end

  private

  def recalc_weight!
    tag&.recalc_weight!
  end
end
