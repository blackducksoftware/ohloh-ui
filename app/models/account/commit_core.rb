class Account::CommitCore
  attr_accessor :account_ids

  def initialize(account_ids)
    @account_ids = account_ids
  end

  # TODO Replaces most_and_recent_commits_data(account_ids)
  def most_and_recent_data
    return {} if @account_ids.blank?
    stats = Account.select{[accounts.id.as(account_id), projects.id.as(project_id), projects.name, projects.url_name, max(name_facts.commits).as(max_commits),
                            max(name_facts.last_checkin).as(last_checkin)]}.facts_joins
    .where{accounts.id.in(my{account_ids})}.group{[accounts.id, projects.id, projects.name, projects.url_name]}
    stats.group_by { |hsh| hsh['account_id'].to_i }
  end
end