def random_repository_name
  chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + ['_', '-', '+', '/', '.']
  (0...16).map { chars[rand(chars.length)] }.join
end

FactoryGirl.define do
  factory :code_location do
    association :repository
    branch_name { random_repository_name }
  end
end
