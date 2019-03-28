FactoryBot.define do
  factory :verification do
    token { Faker::Internet.password }
    unique_id { Faker::Name.first_name + rand(999_999).to_s }
  end

  factory :github_verification, parent: :verification, class: :GithubVerification do
    type { 'GithubVerification' }
  end

  factory :firebase_verification, parent: :verification, class: :FirebaseVerification do
    type { 'FirebaseVerification' }
    credentials { Faker::Internet.password }
  end
end
