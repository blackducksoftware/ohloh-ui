# frozen_string_literal: true

FactoryBot.define do
  factory :alias do
    association :project
    association :commit_name, factory: :name
    association :preferred_name, factory: :name
    before(:create) { |instance| instance.editor_account = create(:admin) }
  end
end
