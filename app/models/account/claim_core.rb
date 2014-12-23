class Account::ClaimCore < OhDelegator::Base
  # FIXME: Replace claimed_email_ids with this.
  def email_ids
    # NameFact.select("array_agg(DISTINCT(NULLIF(array_to_string(email_address_ids, ','), '')))")
    #   does not produce the same results as NameFact.connection.select_one ...
    @name_fact_emails ||= Account.connection.select_one <<-SQL
      SELECT array_agg(DISTINCT(NULLIF(array_to_string(NF.email_address_ids, ','), ''))) AS email_ids
      FROM name_facts NF
      INNER JOIN projects P ON P.best_analysis_id = NF.analysis_id AND NOT P.deleted
      INNER JOIN positions PO ON PO.project_id = P.id AND PO.name_id IS NOT NULL AND PO.account_id = #{ id }
      LEFT OUTER JOIN aliases A ON A.project_id = P.id AND NOT A.deleted AND A.preferred_name_id = PO.name_id
      WHERE NF.name_id = PO.name_id OR NF.name_id = A.commit_name_id
    SQL

    @name_fact_emails['email_ids'].to_s.from_postgres_array
  end

  # FIXME: Replace claimed_emails with this.
  def emails
    return [] if email_ids.empty?
    EmailAddress.where(id: email_ids).pluck(:address)
  end

  # No of unclaimed persons based on account's claimed emails.
  def unclaimed_persons_count
    return 0 if emails.empty?
    Person.count_unclaimed(emails.join(' '), 'email')
  end
end
