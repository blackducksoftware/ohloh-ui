FactoryGirl.define do
  factory :release do
    kb_release_id { Faker::Lorem.word }
    association :project_security_set
    released_on 6.months.ago
    after(:create) do |release|
      pss_id = release.project_security_set_id
      project = release.project_security_set.project
      project.update_column('best_project_security_set_id', pss_id)
    end
  end
end
