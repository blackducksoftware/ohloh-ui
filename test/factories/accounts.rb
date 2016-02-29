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

  # Note: All code downard is for spammer cleanup/reverifications
  trait :spammer do
    level Account::Access::SPAM
    association :github_verification, strategy: :null
  end

  trait :no_verification do
    association :github_verification, strategy: :null
  end

  trait :invalid_spammer do
    level Account::Access::SPAM
    association :github_verification
  end

  # factory :validated_account_with_left_over_tracker, parent: :account do
  #   association :reverification_tracker
  # end

  factory :unverified_account, parent: :account do
    association :github_verification, strategy: :null
    association :reverification_tracker, strategy: :null

  #   trait :hard_bounce do
  #     email 'bounce@simulator.amazonses.com'
  #   end

  #   trait :soft_bounce do
  #     email 'ooto@simulator.amazonses.com'
  #   end

  #   trait :complaint do
  #     email 'complaint@simulator.amazonses.com'
  #   end

  #   trait :success do
  #     email 'success@simulator.amazonses.com'
  #   end
  end

  # factory :initial_phase_account, parent: :account do
  #   association :github_verification, strategy: :null
  #   association :reverification_tracker
  # end

  # factory :marked_for_spam_phase_account, parent: :account do
  #   association :github_verification, strategy: :null
  #   association :reverification_tracker, phase: 1
  # end

  # factory :spam_phase_account, parent: :account do
  #   association :github_verification, strategy: :null
  #   association :reverification_tracker, phase: 2
  # end

  # factory :final_warning_phase_account, parent: :account do
  #   association :github_verification, strategy: :null
  #   association :reverification_tracker, phase: 3
  # end
end

