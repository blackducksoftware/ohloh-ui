FactoryBot.define do
  factory :clump do
    association :code_set
    association :slave
    type { 'GitClump' }
  end
end
