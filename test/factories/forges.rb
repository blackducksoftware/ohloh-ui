FactoryBot.define do
  factory :forge do
    name { 'Github' }
    url { 'git://github.com' }
    type { 'Forge::Github' }
  end
end
