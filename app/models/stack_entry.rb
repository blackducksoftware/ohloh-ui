# frozen_string_literal: true

class StackEntry < ActiveRecord::Base
  MAX_NOTE_LENGTH = 255

  belongs_to :stack
  belongs_to :project

  scope :active, -> { where(deleted_at: nil) }
  scope :for_project_id, ->(project_id) { for_project_id_arel(project_id) }
  scope :similar_stack_entries, ->(entries1, entries2) { similar_stack_entries_arel(entries1, entries2) }

  validates :stack, presence: true
  validates :project, presence: true,
                      uniqueness: { scope: %i[stack_id deleted_at] }

  validates :note, length: { within: 0..MAX_NOTE_LENGTH }, allow_nil: true

  after_create :update_counters
  after_create :clean_up_ignores

  def project_name
    project ? project.name : ''
  end

  def project_name=(name)
    self.project = Project.not_deleted.case_insensitive_name(name).first
  end

  def destroy
    update(deleted_at: Time.current)
    update_counters
  end

  def update_counters
    stack&.update_column(:project_count, stack.stack_entries.count)
    project&.update_column(:user_count, project.stacks_count)
  end

  class << self
    def stack_weight_sql(project_id)
      stack_entries = StackEntry.arel_table
      other_entries = stack_entries.alias
      StackEntry.select([other_entries[:project_id], 'COUNT(*) AS shared_stacks'])
                .similar_stack_entries(stack_entries, other_entries)
                .for_project_id(project_id)
                .where(other_entries[:deleted_at].eq(nil))
                .group(other_entries[:project_id]).to_sql
    end

    private

    def for_project_id_arel(project_id)
      joins(:stack).where(project_id: project_id).where(deleted_at: nil).merge(Stack.has_account)
    end

    def similar_stack_entries_arel(entries1, entries2)
      joins(entries1.join(entries2)
        .on(entries1[:stack_id].eq(entries2[:stack_id])
        .and(entries1[:project_id].not_eq(entries2[:project_id])))
        .join_sources)
    end
  end

  private

  def clean_up_ignores
    stack.stack_ignores.for_project(project).destroy_all
  end
end
