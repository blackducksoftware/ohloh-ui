FactoryBot.define do
  factory :create_edit do
    association :target, factory: :project, description: 'Linux'
    association :account, factory: :account
    association :project, factory: :project
    association :organization, factory: :organization
    ip { '0.0.0.0' }
    undone { false }
    undone_at { nil }
    undone_by { nil }
  end
end
