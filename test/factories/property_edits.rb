# frozen_string_literal: true

FactoryBot.define do
  factory :property_edit do
    type { 'PropertyEdit' }
    association :target, factory: :project, description: 'Linux'
    key { 'description' }
    value { 'Linux 2: Electric Boogaloo' }
    account_id { Account.first.id }
    project_id { Project.first.id }
    organization_id { nil }
    ip { '0.0.0.0' }
    undone { false }
    undone_at { nil }
    undone_by { nil }
  end
end
