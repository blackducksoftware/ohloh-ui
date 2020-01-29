# frozen_string_literal: true

FactoryBot.define do
  factory :account_analysis do
    association :account
  end

  factory :best_account_analysis, parent: :account_analysis do
    association :account_analysis_fact

    after(:create) do |account_analysis|
      account_analysis.account.update(best_vita_id: account_analysis.id)
    end
  end
end
