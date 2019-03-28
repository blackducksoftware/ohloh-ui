FactoryBot.define do
  factory :logo do
    type { 'Logo' }
    filename { 'test_logo.png' }
    content_type { 'image/png' }
    size { 12_000 }
    width { 20 }
    height { 20 }
  end
end
