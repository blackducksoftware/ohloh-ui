class Account::ClaimCore < OhDelegator::Base
  def email_ids
    NameFact.from("(#{email_ids_from_position.to_sql} union #{email_ids_from_aliases.to_sql}) name_facts")
            .pluck(:email_address_ids).flatten.uniq
  end

  def emails
    return [] if email_ids.empty?

    EmailAddress.where(id: email_ids).map(&:address)
  end

  def unclaimed_persons_count
    return 0 if emails.empty?

    Person::Count.unclaimed_by(emails.join(' '), 'email')
  end

  private

  def email_ids_from_position
    email_ids_query
      .where(name_fact_position_condition)
  end

  def email_ids_from_aliases
    email_ids_query
      .joins(project: :aliases)
      .where(name_fact_aliases_condition)
  end

  def email_ids_query
    NameFact.select(:email_address_ids)
            .joins(project: :positions)
            .where.not(positions_name_id.eq(nil))
            .where(Position.arel_table[:account_id].eq(id))
            .select(:email_address_ids)
  end

  def name_fact_position_condition
    NameFact.arel_table[:name_id].eq(positions_name_id)
  end

  def name_fact_aliases_condition
    NameFact
      .arel_table[:name_id]
      .eq(alias_arel_table[:commit_name_id])
      .and(alias_arel_table[:preferred_name_id].eq(positions_name_id))
  end

  def positions_name_id
    Position.arel_table[:name_id]
  end

  def alias_arel_table
    Alias.arel_table
  end
end
