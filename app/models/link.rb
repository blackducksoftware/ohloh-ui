# frozen_string_literal: true

class Link < ActiveRecord::Base
  # Maintain this order for the index page.
  CATEGORIES = HashWithIndifferentAccess.new(
    Homepage: 9,
    Download: 10,
    Community: 7,
    Documentation: 4,
    Forums: 3,
    'Issue Trackers' => 5,
    'Mailing Lists' => 6,
    Other: 8
  ).freeze

  belongs_to :project
  acts_as_editable editable_attributes: %i[title url link_category_id],
                   merge_within: 30.minutes
  acts_as_protected parent: :project
  has_many :accounts, through: :edits

  scope :of_category, ->(category_id) { where(link_category_id: category_id) }
  scope :general, -> { where.not(link_category_id: [CATEGORIES[:Homepage], CATEGORIES[:Download]]) }

  validates :title, length: { in: 3..60 }, allow_blank: true
  validates :title, presence: true
  validates :url, presence: true
  validates :url, allow_blank: true,
                  uniqueness: { scope: %i[project_id link_category_id] },
                  url_format: { message: :invalid_url }
  validates :link_category_id, presence: true

  def revive_or_create
    deleted_link = Link.find_by(url: url, project_id: project_id, deleted: true)

    return save unless deleted_link

    CreateEdit.find_by(target: deleted_link).redo!(editor_account)
    deleted_link.editor_account = editor_account
    deleted_link.update(title: title, link_category_id: link_category_id)
  end

  def category
    self.class.find_category_by_id(link_category_id)
  end

  def allow_undo_to_nil?(key)
    !%i[title url link_category_id].include?(key)
  end

  def url_escaped
    CGI.escape(url)
  end

  def url_host
    URI.parse(url_escaped).host
  end

  class << self
    def find_category_by_id(category_id)
      return unless category_id

      CATEGORIES.invert[category_id.to_i]
    end
  end
end
