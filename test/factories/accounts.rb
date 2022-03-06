# frozen_string_literal: true

FactoryBot.define do
  sequence :account_login do |n|
    "login-#{n}"
  end

  factory :account do
    sequence :email do |n|
      "someone#{n}@gmail.com"
    end
    url { Faker::Internet.url }
    login { generate(:account_login) }
    password { Faker::Internet.password }
    current_password { |account| account.send(:password) }
    twitter_account { 'openhub' }
    name { Faker::Name.name + rand(999_999).to_s }
    about_raw { Faker::Lorem.characters(number: 10) }
    activated_at { Time.current }
    activation_code { nil }
    country_code { 'us' }
    email_master { true }
    email_kudos { true }
    email_posts { true }

    association :github_verification

    trait :with_stacks do
      transient do
        number_of_stacks { 2 }
      end

      after(:create) do |account, evaluator|
        create_list(:stack, evaluator.number_of_stacks, account: account)
      end
    end
  end

  factory :unactivated, parent: :account do
    activated_at { nil }
    activation_code { '123456' }
  end

  factory :admin, parent: :account do
    level { Account::Access::ADMIN }
  end

  factory :disabled_account, parent: :account do
    level { Account::Access::DISABLED }
  end

  factory :spammer, parent: :account do
    level { Account::Access::SPAM }
  end

  factory :account_with_markup, parent: :account do
    association :markup
  end

  # NOTE: All code downard is for spammer cleanup/reverifications
  factory :unverified_account, parent: :account do
    association :github_verification, strategy: :null
    association :reverification_tracker, strategy: :null
  end

  trait :admin do
    level { Account::Access::ADMIN }
    association :github_verification, strategy: :null
  end

  trait :disabled_account do
    level { Account::Access::DISABLED }
    association :github_verification, strategy: :null
  end

  trait :spammer do
    level { Account::Access::SPAM }
    association :github_verification, strategy: :null
  end

  trait :no_verification do
    association :github_verification, strategy: :null
  end

  trait :invalid_spammer do
    level { Account::Access::SPAM }
    association :github_verification
  end

  trait :success do
    email { 'success@simulator.amazonses.com' }
  end

  trait :hard_bounce do
    email { 'bounce@simulator.amazonses.com' }
  end

  trait :soft_bounce do
    email { 'ooto@simulator.amazonses.com' }
  end

  trait :bounce_undetermined do
    email { 'someone@gmail.com' }
  end

  trait :complaint do
    email { 'complaint@simulator.amazonses.com' }
  end
end
