class Account::ClaimCore < OhDelegator::Base
  def email_ids
    email_ids_query.pluck(:email_address_ids).flatten.uniq
  end

  def emails
    return [] if email_ids.empty?
    EmailAddress.where(id: email_ids).pluck(:address)
  end

  def unclaimed_persons_count
    return 0 if emails.empty?
    Person::Count.unclaimed_by(emails.join(' '), 'email')
  end

  private

  def email_ids_query
    NameFact.select(:email_address_ids)
      .joins(project: :positions)
      .joins(email_ids_joins)
      .where.not(positions_name_id.eq(nil))
      .where(Position.arel_table[:account_id].eq(id))
      .where(name_fact_conditions)
  end

  def email_ids_joins
    Project.arel_table.join(alias_arel_table, Arel::Nodes::OuterJoin).on(aliases_on_clause).join_sources
  end

  def name_fact_conditions
    NameFact.arel_table[:name_id].eq(positions_name_id)
      .or(NameFact.arel_table[:name_id].eq(alias_arel_table[:commit_name_id]))
  end

  def positions_name_id
    Position.arel_table[:name_id]
  end

  def alias_arel_table
    Alias.arel_table
  end

  def aliases_on_clause
    alias_arel_table[:project_id].eq(Project.arel_table[:id])
      .and(alias_arel_table[:deleted].eq(false))
      .and(aliases_names_conditions)
  end

  def aliases_names_conditions
    alias_arel_table[:preferred_name_id].eq(positions_name_id)
      .and(alias_arel_table[:commit_name_id].eq(NameFact.arel_table[:name_id]))
  end
end
