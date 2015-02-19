FactoryGirl.define do
  factory :position do
    association :account
    association :project
    association :organization
    after(:create) do |instance|
      instance.update_attributes(name: create(:name)) unless instance.name_id
      unless NameFact.where(name_id: instance.name_id).count > 0
        if instance.project.nil?
          create(:name_fact, analysis: create(:analysis), name: instance.name)
        else
          best_analysis = instance.project.try(:best_analysis)
          best_analysis = nil if best_analysis.is_a?(NilAnalysis)
          create(:name_fact, analysis: best_analysis, name: instance.name)
        end
      end
    end
  end
end
