FactoryGirl.define do
  sequence :account_login do |n|
    "login-#{n}"
  end

  factory :account do
    sequence :email do |n|
      "someone#{n}@gmail.com"
    end
    email_confirmation { |account| account.send :email }
    url { Faker::Internet.url }
    login { generate(:account_login) }
    password { Faker::Internet.password }
    password_confirmation { |account| account.send(:password) }
    current_password { |account| account.send(:password) }
    twitter_account 'openhub'
    name { Faker::Name.name + rand(999_999).to_s }
    about_raw { Faker::Lorem.characters(10) }
    activated_at { Time.current }
    activation_code nil
    country_code 'us'
    email_master true
    email_kudos true
    email_posts true

    association :github_verification
  end

  factory :unactivated, parent: :account do
    activated_at nil
    activation_code '123456'
  end

  factory :admin, parent: :account do
    level Account::Access::ADMIN
  end

  factory :disabled_account, parent: :account do
    level Account::Access::DISABLED
  end

  factory :spammer, parent: :account do
    level Account::Access::SPAM
  end

  factory :account_with_markup, parent: :account do
    association :markup
  end

  factory :account_without_verifications, parent: :account do
    association :github_verification, strategy: :null
    association :account_reverification, strategy: :null

    trait :hard_bounce do
      email 'bounce@simulator.amazonses.com'
    end

    trait :soft_bounce do
      email 'ooto@simulator.amazonses.com'
    end

    trait :complaint do
      email 'complaint@simulator.amazonses.com'
    end

    trait :success do
      email 'success@simulator.amazonses.com'
    end
  end

  factory :account_with_an_initial_notification_and_no_verifications, parent: :account do
    association :github_verification, strategy: :null
    association :account_reverification
  end
end
