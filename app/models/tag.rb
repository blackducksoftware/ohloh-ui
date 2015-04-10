class Tag < ActiveRecord::Base
  MAX_ALLOWED_PER_PROJECT = 20

  has_many :taggings
  has_many :projects, through: :taggings

  scope :for_projects, -> { joins(:taggings).where(['taggings.taggable_type = ?', 'Project']).group('tags.id') }
  scope :by_popularity, -> { order(taggings_count: :desc, name: :asc) }
  scope :popular, -> { by_popularity.for_projects.where(['tags.taggings_count > ?', 1]) }

  validates :name, length: { within: 1..50 }, allow_nil: false,
                   format: { with: /\A[\w\+\(\)\_\-#]*\Z/, message: I18n.t('tags.allowed_characters') }

  class << self
    def autocomplete(project_id, query)
      by_popularity.for_projects
        .where(['tags.name ILIKE ?', "#{Tag.send(:sanitize_sql, query.to_s)}%"])
        .where(['tags.id NOT IN (SELECT tag_id FROM taggings WHERE taggable_id = ?)', project_id])
    end
  end
end
