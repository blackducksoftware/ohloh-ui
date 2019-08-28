# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    association :target, factory: :project
    before(:create) { |instance| instance.editor_account = create(:admin) }
  end
end
