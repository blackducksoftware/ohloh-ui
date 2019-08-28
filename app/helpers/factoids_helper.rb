# frozen_string_literal: true

module FactoidsHelper
  def get_factoid_display(fact)
    text, type, url = factiod_info(fact)
    haml_tag :span, class: type.to_s do
      haml_tag :a, href: url do
        concat text
      end
    end
  end

  private

  def get_factoid_type(fact)
    match = "Factoid#{fact.to_s.capitalize}"
    fact = @analysis.factoids.select { |f| f.type.starts_with?(match) }
    fact.empty? ? nil : fact.first
  end

  def factiod_info(fact)
    factoid = get_factoid_type(fact)
    if factoid
      [factoid.inline, factoid.category, project_factoids_path(@project, anchor: factoid.type)]
    else
      factoid_no_factoid_info(fact)
    end
  end

  def factoid_no_factoid_info(fact)
    case fact
    when :comments
      [t('factoids.comments_unknown_inline'), :warning, nil]
    when :activity
      [t('factoids.activity_unknown_inline'), :info, nil]
    when :team
      [t('factoids.team_size_unknown_inline'), :info, nil]
    when :age
      [t('factoids.age_unknown_inline'), :info, nil]
    end
  end
end
