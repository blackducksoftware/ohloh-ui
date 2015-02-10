class Account::ClaimCore < OhDelegator::Base
  # FIXME: Replace claimed_email_ids with this.
  # rubocop:disable Metrics/AbcSize
  def email_ids
    NameFact.select { email_address_ids }
      .joins { [project.positions, project.aliases_with_positions_name.outer] }
      .where do
        positions.name_id.not_eq(nil) & positions.account_id.eq(my { id }) &
          (name_facts.name_id.eq(positions.name_id) |
            name_facts.name_id.eq(aliases.commit_name_id)
          )
      end.pluck(:email_address_ids).flatten.uniq
  end

  # rubocop:enable Metrics/AbcSize
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
end
