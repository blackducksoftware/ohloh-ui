class Account::ClaimCore < OhDelegator::Base
  # FIXME: Replace claimed_email_ids with this.
  def email_ids
    email_ids_query.pluck(:email_address_ids).flatten.uniq
  end

  # FIXME: Replace claimed_emails with this.
  def emails
    return [] if email_ids.empty?
    EmailAddress.where(id: email_ids).pluck(:address)
  end

  # No of unclaimed persons based on account's claimed emails.
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
    Project.arel_table.join(Alias.arel_table, Arel::Nodes::OuterJoin).on(aliases_on_clause).join_sources
  end

  def name_fact_conditions
    NameFact.arel_table[:name_id].eq(positions_name_id)
      .or(NameFact.arel_table[:name_id].eq(Alias.arel_table[:commit_name_id]))
  end

  def positions_name_id
    Position.arel_table[:name_id]
  end

  def aliases_on_clause
    aliases = Alias.arel_table
    aliases[:project_id].eq(Project.arel_table[:id])
      .and(aliases[:deleted].eq(false))
      .and(aliases[:preferred_name_id].eq(positions_name_id))
  end
end
