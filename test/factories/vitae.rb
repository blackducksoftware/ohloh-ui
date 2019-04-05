FactoryBot.define do
  factory :vita do
    association :account
  end

  factory :best_vita, parent: :vita do
    association :vita_fact

    after(:create) do |vita|
      vita.account.update(best_vita_id: vita.id)
    end
  end
end
