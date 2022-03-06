# frozen_string_literal: true

FactoryBot.define do
  factory :position do
    association :account
    association :project
    association :organization
    association :name
    after(:build) do |instance|
      unless NameFact.exists?(name_id: instance.name_id)
        best_analysis = instance.project.try(:best_analysis)
        best_analysis = nil if best_analysis.is_a?(NilAnalysis)
        create(:name_fact, analysis: best_analysis, name: instance.name)
      end
    end
  end

  factory :position_with_unverified_account, parent: :position do
    association :account, factory: :unverified_account
  end
end
