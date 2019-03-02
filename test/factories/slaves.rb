FactoryBot.define do
  factory :slave do
    hostname { Faker::Name.name }
    allow_deny { 'allow' }
    available_blocks { rand(999_999) }
    used_blocks { (rand(999_999) - rand(499_999)).abs }
    used_percent { used_blocks * 100 / available_blocks }
    updated_at { Time.current - 3.minutes }
    load_average { rand(10) }
    clump_dir { '/var/local/clumps' }
    clump_status { 'rw' }
    oldest_clump_timestamp { Time.current - 3.days }
    enable_profiling { false }
    blocked_types { nil }
  end
end
