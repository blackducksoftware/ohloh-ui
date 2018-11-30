xml.response do
  xml.status('success')
  xml.items_returned @contributions.length
  xml.items_available @contributions.total_entries
  xml.first_item_position @contributions.offset
  xml.result do
    @contributions.each do |contribution|
      contributor_fact = contribution.contributor_fact
      xml.contributor_fact do
        xml.contributor_id contribution.id
        if contribution.person.account_id
          xml.account_id contribution.person.account_id
          xml.account_name contribution.person.account.name
        end
        if contributor_fact
          xml.analysis_id contributor_fact.analysis_id
          xml.contributor_name obfuscate_email(contributor_fact.name.name)
          xml.primary_language_id contributor_fact.primary_language_id
          xml.primary_language_nice_name contributor_fact.primary_language.try(:nice_name).to_s
          xml.comment_ratio contributor_fact.comment_ratio
          xml.first_commit_time xml_date_to_time(contributor_fact.first_checkin)
          xml.last_commit_time xml_date_to_time(contributor_fact.last_checkin)
          xml.man_months contributor_fact.man_months
          xml.commits contributor_fact.commits
        end
      end
    end
  end
end
