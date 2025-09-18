# frozen_string_literal: true

require 'forwardable'

class Account::ProjectCore
  extend Forwardable
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def_delegators :account, :id, :stacks, :manages

  def stacked?(project_id)
    stacks = account.stacks
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
    Stack.arel_table[:account_id].eq(account.id)
  end
end
