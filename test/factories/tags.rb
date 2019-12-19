# frozen_string_literal: true

FactoryBot.define do
  sequence :tags_name do |n|
    "tags-#{n}"
  end

  factory :tag do
    name { generate(:tags_name) }
  end
end
