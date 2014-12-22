FactoryGirl.define do
  sequence :account_login do |n|
    "login-#{ n }"
  end

  factory :account do
    email_address = Faker::Internet.free_email
    email email_address
    email_confirmation email_address
    url Faker::Internet.url
    login { generate(:account_login) }
    crypted_password 'abc123456'
    salt 'xyz123456'
    password 'abc123456'
    password_confirmation 'abc123456'
    twitter_account 'openhub'
    name Faker::Name.name
    about_raw Faker::Lorem.characters(10)
  end
end
