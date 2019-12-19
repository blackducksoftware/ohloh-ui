# frozen_string_literal: true

FactoryBot.define do
  factory :reverification_tracker do
    association :account
    message_id { 'XYZ0-1234-AB56-67GJ' }
    feedback { '' }
    phase { 0 }
    status { 0 }
    attempts { 1 }
    sent_at { DateTime.now.utc }
    created_at { DateTime.now.utc }
    updated_at { DateTime.now.utc }
  end

  factory :initial_rev_tracker, parent: :reverification_tracker do
    association :account, :no_verification
  end

  factory :success_initial_rev_tracker, parent: :reverification_tracker do
    association :account, :success, :no_verification
    status { 1 }
  end

  factory :hard_bounce_initial_rev_tracker, parent: :reverification_tracker do
    association :account, :hard_bounce, :no_verification
  end

  factory :soft_bounce_initial_rev_tracker, parent: :reverification_tracker do
    association :account, :soft_bounce, :no_verification
    status { 2 }
  end

  factory :complained_initial_rev_tracker, parent: :reverification_tracker do
    association :account, :complaint, :no_verification
    status { 3 }
  end

  factory :marked_for_disable_rev_tracker, parent: :reverification_tracker do
    association :account, :no_verification
    phase { 1 }
  end

  factory :rev_tracker_needs_disabling, parent: :reverification_tracker do
    association :account, :no_verification
    phase { 2 }
  end

  factory :disable_rev_tracker, parent: :reverification_tracker do
    association :account, :disabled_account, :no_verification
    phase { 2 }
  end

  factory :final_warning_rev_tracker, parent: :reverification_tracker do
    association :account, :disabled_account, :no_verification
    phase { 3 }
  end

  factory :invalid_final_warning_rev_tracker, parent: :reverification_tracker do
    association :account, :invalid_spammer, :no_verification
    phase { 3 }
  end

  trait :soft_bounced do
    status { 2 }
  end

  trait :complained do
    status { 3 }
  end

  trait :delivered do
    status { 1 }
  end
end
