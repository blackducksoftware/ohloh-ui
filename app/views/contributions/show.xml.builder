# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status('success')
  xml.result do
    c_fact = @contribution.contributor_fact
    xml.contributor_fact do
      xml.contributor_id @contribution.id

      if @contribution.person.account_id
        xml.account_id        @contribution.person.account_id
        xml.account_name      @contribution.person.account.name
      end

      if c_fact
        c_lang_facts = c_fact.name_language_facts
        xml.analysis_id         c_fact.analysis_id
        xml.contributor_name    obfuscate_email(c_fact.name.name)
        xml.primary_language_id c_fact.primary_language_id
        xml.primary_language_nice_name c_fact.primary_language_id ? c_fact.primary_language.nice_name : ''
        xml.comment_ratio       c_fact.comment_ratio
        xml.first_commit_time   xml_date_to_time(c_fact.first_checkin)
        xml.last_commit_time    xml_date_to_time(c_fact.last_checkin)
        xml.man_months          c_fact.man_months
        xml.commits             c_fact.commits

        if c_lang_facts
          xml.contributor_language_facts do
            c_lang_facts.each do |contributor_language_fact|
              xml.contributor_language_fact do
                xml.analysis_id         contributor_language_fact.analysis_id
                xml.contributor_id      @contribution.id
                xml.contributor_name    obfuscate_email(contributor_language_fact.name.name)

                xml.language_id         contributor_language_fact.language_id
                xml.language_nice_name  contributor_language_fact.language.nice_name

                xml.comment_ratio       contributor_language_fact.comment_ratio
                xml.man_months          contributor_language_fact.total_months
                xml.commits             contributor_language_fact.total_commits
              end
            end
          end
        end
      end
    end
  end
end
