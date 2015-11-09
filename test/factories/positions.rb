FactoryGirl.define do
  factory :position do
    association :account
    association :project
    association :organization
    association :name

    # Note: Changing the after method to build passes committer name validation
    # and should remove the need for positions helper in test_helper.rb
    after(:build) do |instance|
      unless NameFact.where(name_id: instance.name_id).exists?
        best_analysis = instance.project.try(:best_analysis)
        best_analysis = nil if best_analysis.is_a?(NilAnalysis)
        create(:name_fact, analysis: best_analysis, name: instance.name)
      end
    end
  end
end
