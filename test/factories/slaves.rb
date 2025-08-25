# frozen_string_literal: true

FactoryBot.define do
  factory :slave do
    hostname { Faker::Name.name }
    allow_deny { 'allow' }
    available_blocks { rand(999_999) }
    used_blocks { (rand(999_999) - rand(499_999)).abs }
    used_percent { used_blocks * 100 / available_blocks }
    updated_at { 3.minutes.ago }
    load_average { rand(10) }
    clump_dir { '/var/local/clumps' }
    clump_status { 'rw' }
    oldest_clump_timestamp { 3.days.ago }
    enable_profiling { false }
    blocked_types { nil }
  end
end
