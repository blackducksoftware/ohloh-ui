# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Stack < ApplicationRecord
  SAMPLE_PROJECT_IDS = { lamp: [3141, 72, 4139, 28],
                         sash: [41, 3468, 3568, 55],
                         gnome: [3760, 43, 9, 29, 36] }.freeze
  MAX_STACKS_PER_ACCOUNT = 30

  belongs_to :account, optional: true
  belongs_to :project, optional: true

  has_many :stack_entries, -> { where(deleted_at: nil) }, dependent: :destroy, inverse_of: :stack
  has_many :projects, -> { where.not(deleted: true) }, through: :stack_entries
  has_many :stack_ignores

  scope :has_account, -> { where.not(account_id: nil) }

  validates :title, uniqueness: { case_sensitive: true, scope: [:account_id],
                                  if: proc { |stack| stack.session_id.nil? } }
  validates :description, length: { within: 0..120 }, allow_nil: true
  validates :title, length: { within: 0..20 }, allow_nil: true, format: { without: Patterns::BAD_NAME }

  before_validation :sanitize_description

  accepts_nested_attributes_for :stack_entries, reject_if: :all_blank

  def sandox?
    account_id.nil? && project_id.nil? && !session_id.nil?
  end

  def similar_stacks(limit = 12)
    Stack.find_by_sql(similar_stacks_sql(limit)).map do |s|
      { stack: s, shared_projects: (s.projects & projects), uniq_projects: (s.projects - projects) }
    end
  end

  def suggest_projects(limit = 8)
    sql = [proj_suggest_select, proj_suggest_join_stack_entries, proj_suggest_join_stack_ignores,
           proj_suggest_wheres, proj_suggest_suffix(limit)].join(' ')
    pad_project_suggestions(Project.find_by_sql(sql), limit)
  end

  def name
    return title if respond_to?(:title) && title.present?
    return 'Default' if account && self == account.stack_core.default
    return "#{project.name}'s Stack" unless project.nil?

    'Unnamed'
  end

  def auto_generate_title_and_description(stack_count)
    self.title = "New Stack #{stack_count}"
    self.description = "The Projects used for #{title}"
  end

  def friendly_name
    "#{name}#{' Stack' unless name =~ /Stack/i}"
  end

  def stacked_project?(project_id)
    stack_entries.includes(:stack).find_by(project_id: project_id, deleted_at: nil)
  end

  private

  def sanitize_description
    self.description = description.strip_tags if description
  end

  def similar_stacks_sql(limit)
    <<-SQL.squish
      SELECT S.*, shared_count, s_count.count, shared_count/sqrt(s_count.count) as func
      FROM stacks S INNER JOIN (#{stack_entry_to_stack_join_sql}) AS se_to_s ON S.id = se_to_s.stack_id
      INNER JOIN ( SELECT count(*), stack_id from stack_entries where deleted_at IS NULL group by stack_id) as s_count
        ON se_to_s.stack_id = s_count.stack_id
      WHERE S.account_id IS NOT NULL #{account ? " AND S.account_id != #{account.id} " : ''}
      ORDER BY func DESC LIMIT #{limit}
    SQL
  end

  def stack_entry_to_stack_join_sql
    <<-SQL.squish
      SELECT SE1.stack_id AS stack_id, count(*) AS shared_count
      FROM stack_entries SE0
      INNER JOIN stack_entries SE1
       ON SE0.project_id = SE1.project_id
       AND SE0.stack_id = #{id || 0} AND SE1.deleted_at IS NULL
       AND SE0.deleted_at IS NULL AND SE1.stack_id != SE0.stack_id
      GROUP BY SE1.stack_id
    SQL
  end

  def proj_suggest_select
    'SELECT projects.*, query.total_weight - coalesce(0.25 * ignore.total_weight,0) as total_weight FROM projects'
  end

  def proj_suggest_join_stack_entries
    <<-SQL.squish
      INNER JOIN ( SELECT project_id_recommends, sum(weight) as total_weight
        FROM recommend_entries INNER JOIN stack_entries ON recommend_entries.project_id = stack_entries.project_id
        WHERE stack_entries.stack_id = #{id} AND stack_entries.deleted_at IS NULL
        GROUP BY project_id_recommends ) AS query ON projects.id = project_id_recommends
    SQL
  end

  def proj_suggest_join_stack_ignores
    <<-SQL.squish
      LEFT OUTER JOIN ( SELECT project_id_recommends as project_id_smells, sum(weight) as total_weight
        FROM recommend_entries WHERE project_id IN
        ( SELECT project_id FROM stack_ignores WHERE stack_id = #{id} ORDER BY created_at LIMIT 25 )
        GROUP BY project_id_smells ) AS ignore ON projects.id = project_id_smells
    SQL
  end

  def proj_suggest_wheres
    <<-SQL.squish
      WHERE projects.id NOT IN (SELECT project_id FROM stack_entries WHERE stack_id = #{id} AND deleted_at IS NULL)
      AND projects.id NOT IN (SELECT project_id FROM stack_ignores WHERE stack_id = #{id}) AND projects.deleted IS FALSE
    SQL
  end

  def proj_suggest_suffix(limit)
    "ORDER BY query.total_weight - coalesce(0.25 * ignore.total_weight, 0) DESC, LOWER(projects.name) LIMIT #{limit}"
  end

  def pad_project_suggestions(projects, limit)
    return projects unless projects.size < limit

    xtra_where = projects.empty? ? '' : "AND projects.id NOT IN (#{projects.collect { |p| p.id.to_s }.join(',')})"
    sql = <<-SQL.squish
      SELECT projects.* FROM projects WHERE projects.deleted IS FALSE AND projects.user_count > 0 #{xtra_where}
      AND projects.id NOT IN (SELECT project_id FROM stack_ignores WHERE stack_id = #{id})
      AND projects.id NOT IN (SELECT project_id FROM stack_entries WHERE stack_id = #{id} AND deleted_at IS NULL)
      ORDER BY projects.user_count DESC, LOWER(projects.name)
      LIMIT #{limit - projects.size}
    SQL
    [projects, Project.find_by_sql(sql)].flatten
  end
end
# rubocop:enable Metrics/ClassLength
