FactoryGirl.define do
  factory :clump do
    association :code_set
  end

  factory :git_clump, parent: :clump, class: 'GitClump' do
    type 'GitClump'
  end
end
