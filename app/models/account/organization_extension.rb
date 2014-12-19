class Account::OrganizationExtension < OhDelegator::Base
  belongs_to :organization

  def orgs_for_my_positions
    @orgs_positions ||= Organization.active.joins{projects.positions}.where{positions.account_id.eq my{id}}
                                    .order{id}.distinct
  end

  def affiliations_for_my_positions
    @affiliations_positions ||= orgs_for_my_positions.where{ positions.organization_id.not_eq(nil)}
  end

  def contributions_to_org_portfolio
    org_contributions_for.where{projects.organization_id.eq(accounts.organization_id)}.count
  end

  def contributions_outside_org
    org_contributions_for.where{(projects.organization_id.not_eq(accounts.organization_id) |
                                projects.organization_id.eq(nil))}.count
  end

  private
  def org_contributions_for
    Account.select{distinct(positions.project_id)}
           .joins{positions.project}
           .joins{['INNER JOIN name_facts ON name_facts.name_id = positions.name_id']}
           .where{projects.deleted.not_eq(true) & id.eq(my{id})}
           .where{name_facts.analysis_id.eq projects.best_analysis_id}
  end
end