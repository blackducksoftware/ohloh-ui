FactoryGirl.define do
  factory :position do
    association :account
    association :project
    association :organization
    after(:create) do |instance|
      instance.update_attributes(name: create(:name)) unless instance.name_id
      unless NameFact.where(name_id: instance.name_id).count > 0
        analysis = instance.project ? instance.project.original_best_analysis : create(:analysis)
        create(:name_fact, analysis: analysis, name: instance.name)
      end
    end
  end
end
