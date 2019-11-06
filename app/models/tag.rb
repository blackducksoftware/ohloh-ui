# frozen_string_literal: true

# rubocop:disable HasManyOrHasOneDependent

class Tag < ActiveRecord::Base
  MAX_ALLOWED_PER_PROJECT = 20

  has_many :taggings
  has_many :projects, through: :taggings

  scope :for_projects, -> { joins(:taggings).where(['taggings.taggable_type = ?', 'Project']).group('tags.id') }
  scope :by_popularity, -> { order(taggings_count: :desc, name: :asc) }
  scope :popular, -> { by_popularity.for_projects.where(['tags.taggings_count > ?', 1]) }
  scope :related_tags, lambda { |tags|
    joins(:taggings).where(taggings: { taggable_id: Project.tagged_with(tags).select(:id) })
                    .where.not(name: tags)
                    .group(:id, :name, :taggings_count, :weight)
                    .limit(25)
  }

  validates :name, length: { within: 1..50 }, allow_nil: false,
                   format: { with: /\A[\w\+\(\)\_\-#]*\Z/, message: I18n.t('tags.allowed_characters') }

  class << self
    def autocomplete(project_id, query)
      project_id = nil if project_id.blank?
      by_popularity.for_projects
                   .where(['tags.name ILIKE ?', "#{Tag.send(:sanitize_sql, query.to_s)}%"])
                   .where(['tags.id NOT IN (SELECT tag_id FROM taggings WHERE taggable_id = ?)', project_id])
    end
  end

  def recalc_weight!
    recalc_taggings_count
    update_attribute :weight, (taggings_count.zero? && 1.0) || (1.0 / (1.0 + Math.log10(taggings_count)))
  end

  def recalc_taggings_count
    sql = <<-SQL
      SELECT COUNT(*) FROM taggings AS t INNER JOIN projects p ON t.taggable_id = p.id AND t.taggable_type = 'Project'
      WHERE t.tag_id = #{id} AND p.deleted = FALSE
    SQL
    update_attribute :taggings_count, Tagging.count_by_sql(sql)
  end
end

# rubocop:enable HasManyOrHasOneDependent
