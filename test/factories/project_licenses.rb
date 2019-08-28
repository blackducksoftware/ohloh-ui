# frozen_string_literal: true

FactoryBot.define do
  factory :project_license do
    association :project
    association :license
    before(:create) { |instance| instance.editor_account = create(:admin) }
  end
end
