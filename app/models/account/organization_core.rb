class Account::OrganizationCore
  def initialize(account_id)
    @id = account_id
    @projects = Project.arel_table
    @positions = Position.arel_table
    @accounts = Account.arel_table
  end

  def orgs_for_my_positions
    @orgs_for_my_positions ||=
      Organization.active.joins(projects: :positions).where(@positions[:account_id].eq(@id))
                  .order(:id).distinct
  end

  def affiliations_for_my_positions
    @affiliations_for_my_positions ||= orgs_for_my_positions.where.not(@positions[:organization_id].eq(nil))
  end

  def contributions_to_org_portfolio
    org_contributions_for.where(@projects[:organization_id].eq(@accounts[:organization_id])).distinct.count
  end

  def contributions_outside_org
    org_contributions_for
      .where(@projects[:organization_id].not_eq(@accounts[:organization_id])
      .or(@projects[:organization_id].eq(nil))).distinct.count
  end

  private

  def org_contributions_for
    Account.select('positions.project_id')
           .joins(positions: :project)
           .joins('INNER JOIN name_facts ON name_facts.name_id = positions.name_id')
           .where.not(@projects[:deleted].eq(true))
           .where(id: @id)
           .where(NameFact.arel_table[:analysis_id].eq(@projects[:best_analysis_id]))
  end
end
