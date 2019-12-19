# frozen_string_literal: true

class Account::CommitCore
  def initialize(account_ids)
    @account_ids = account_ids
    @accounts_id = Account.arel_table[:id]
    @projects = Project.arel_table
    @name_facts = NameFact.arel_table
  end

  def most_and_recent_data
    return {} if @account_ids.blank?

    stats = Account.select(select_clause)
                   .with_facts
                   .where(@accounts_id.in(@account_ids))
                   .group(@accounts_id, @projects[:id], @projects[:name], @projects[:vanity_url])
    stats.group_by { |hsh| hsh['account_id'].to_i }
  end

  private

  def select_clause
    [@accounts_id.as('account_id'), @projects[:id].as('project_id'), @projects[:name], @projects[:vanity_url],
     @name_facts[:commits].maximum.as('max_commits'),
     @name_facts[:last_checkin].maximum.as('last_checkin')]
  end
end
