class Stack < ActiveRecord::Base
  belongs_to :account
  belongs_to :project

  has_many :stack_entries, -> { where(deleted_at: nil) }, dependent: :destroy
  has_many :projects, -> { where.not(deleted: true) }, through: :stack_entries
  has_many :stack_ignores

  scope :has_account, -> { where.not(account_id: nil) }

  validates :title, uniqueness: { scope: [:account_id], if: proc { |stack| stack.session_id.nil? } }
  validates :description, length: { within: 0..120 }, allow_nil: true
  validates :title, length: { within: 0..20 }, allow_nil: true

  def similar_stacks(limit = 12)
    Stack.find_by_sql(similar_stacks_sql(limit)).map do |s|
      { stack: s, shared_projects: (s.projects & projects), uniq_projects: (s.projects - projects) }
    end
  end

  private

  def similar_stacks_sql(limit)
    <<-SQL
      SELECT S.*, shared_count, s_count.count, shared_count/sqrt(s_count.count) as func
      FROM stacks S
      INNER JOIN (#{stack_entry_to_stack_join_sql}) AS se_to_s
        ON S.id = se_to_s.stack_id
      INNER JOIN ( SELECT count(*), stack_id from stack_entries where deleted_at IS NULL group by stack_id) as s_count
        ON se_to_s.stack_id = s_count.stack_id
      WHERE S.account_id IS NOT NULL #{ account ? " AND S.account_id != #{account.id} " : '' }
      ORDER BY func DESC LIMIT #{limit}
    SQL
  end

  def stack_entry_to_stack_join_sql
    <<-SQL
      SELECT SE1.stack_id AS stack_id, count(*) AS shared_count
      FROM stack_entries SE0
      INNER JOIN stack_entries SE1
       ON SE0.project_id = SE1.project_id
       AND SE0.stack_id = #{id || 0} AND SE1.deleted_at IS NULL
       AND SE0.deleted_at IS NULL AND SE1.stack_id != SE0.stack_id
      GROUP BY SE1.stack_id
    SQL
  end
end
