FactoryGirl.define do
  sequence :account_login do |n|
    "login-#{ n }"
  end

  factory :account do
    sequence :email do |n|
      "someone#{n}@gmail.com"
    end
    email_confirmation { |account| account.send :email }
    url { Faker::Internet.url }
    login { generate(:account_login) }
    password 'abc123456'
    password_confirmation 'abc123456'
    twitter_account 'openhub'
    name { Faker::Name.name }
    about_raw { Faker::Lorem.characters(10) }
    activated_at { Time.now.utc }
    activation_code nil
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
end
