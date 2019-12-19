# frozen_string_literal: true

class Organization::AccountFacts
  protected

  def account_facts_joins
    <<-SQL
      INNER JOIN positions PO ON PO.account_id = A.id AND PO.name_id IS NOT NULL
      INNER JOIN projects P ON PO.project_id = P.id AND NOT P.deleted
      INNER JOIN name_facts NF ON NF.name_id = PO.name_id AND NF.analysis_id = P.best_analysis_id
        AND NF.type = 'ContributorFact'
    SQL
  end
end
