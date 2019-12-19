# frozen_string_literal: true

FactoryBot.define do
  sequence :link_title do |n|
    "link number #{n}"
  end

  sequence :link_url do |n|
    "http://example#{n}.com/"
  end

  factory :link_with_no_editor_account, class: Link do
    title { generate(:link_title) }
    url { generate(:link_url) }
    link_category_id { Link::CATEGORIES.values.last(6).sample }
    association :project
  end

  factory :link, parent: :link_with_no_editor_account do
    before(:create) { |instance| instance.editor_account = create(:admin) }
  end
end
