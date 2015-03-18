FactoryGirl.define do
  factory :position do
    association :account
    association :project
    association :organization
    association :name
    after(:create) do |instance|
      unless NameFact.where(name_id: instance.name_id).exists?
        best_analysis = instance.project.try(:best_analysis)
        best_analysis = nil if best_analysis.is_a?(NilAnalysis)
        create(:name_fact, analysis: best_analysis, name: instance.name)
      end
    end
  end
end
