class Link < ActiveRecord::Base
  # TODO: acts_as_editable and acts_as_protected
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
  # TODO: Uncomment after integrating acts_as_editable.
  # acts_as_editable :title, :url, :link_category_id, merge_within: 30.minutes,
  #   explanation: :explain_yourself
  # TODO: Uncomment after integrating acts_as_protected.
  # acts_as_protected parent: :project
  has_many :accounts, through: :edits

  validates :title, length: { in: 3..60 }, presence: true
  validates :url, presence: true,
                  uniqueness: { scope: [:project_id, :link_category_id] },
                  url_format: { message: :invalid_url }
  validates :link_category_id, presence: true

  def url_host
    URI.parse(url_escaped).host
  end

  def revive_or_create
    deleted_link = Link.find_by(url: url, project_id: project_id, deleted: true)

    return save unless deleted_link

    deleted_link.create_edit.redo
    deleted_link.title, deleted_link.link_category_id = title, link_category_id
    deleted_link.save
  end

  def url_escaped
    URI.escape(url)
  end

  def explain_yourself(edit)
    message = "#{ I18n.t('created') } #{ I18n.t('links.title').downcase } #{ id }"
    return message unless edit.is_a?(PropertyEdit)

    value = category_name_or_edited_value(edit)
    I18n.t('edits_pattern', id: id, edit_key: edit.key, value: value)
  end

  def category
    self.class.find_category_by_id(link_category_id)
  end

  def allow_undo?(key)
    ![:title, :url, :link_category_id].include?(key)
  end

  class << self
    def find_category_by_id(category_id)
      return unless category_id

      CATEGORIES.find { |_k, v| v == category_id.to_i }.first
    end
  end

  private

  def category_name_or_edited_value(edit)
    if edit.key == 'link_category_id'
      self.class.find_category_by_id(edit.value)
    else
      edit.value
    end
  end
end
