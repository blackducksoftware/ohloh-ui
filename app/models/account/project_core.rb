# frozen_string_literal: true

class Account::ProjectCore < OhDelegator::Base
  parent_scope do
    has_many :projects, -> { where(deleted: false) }, through: :manages, source: :target, source_type: 'Project'
  end

  def stacked?(project_id)
    stack = stacks.detect { |s| s.stacked_project?(project_id) }
    stack.present?
  end

  def used
    @used_projects ||=
      Project.active.joins(:stacks).where(stacks_account_id)
             .order(:user_count, :name).limit(15).distinct

    logo_ids = @used_projects.collect(&:logo_id).compact
    @used_proj_logos ||= logo_ids.any? ? Logo.find(logo_ids) : []
    [@used_projects, @used_proj_logos.index_by(&:id)]
  end

  def stacked_count
    @stacked_count ||=
      Project.active.joins(:stacks).where(stacks_account_id).distinct.count
  end

  private

  def stacks_account_id
    Stack.arel_table[:account_id].eq(id)
  end
end
