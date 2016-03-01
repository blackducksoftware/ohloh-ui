FactoryGirl.define do
  factory :reverification_tracker do
    association :account
    message_id 0
    feedback ''
    phase 0
    status 0
    created_at DateTime.now.utc
    updated_at DateTime.now.utc
  end

  factory :initial_rev_tracker, parent: :reverification_tracker do
    association :account, :no_verification
  end

  factory :success_initial_rev_tracker, parent: :reverification_tracker do
    association :account, :success
  end

  factory :hard_bounce_initial_rev_tracker, parent: :reverification_tracker do
    association :account, :hard_bounce
  end

  factory :soft_bounce_initial_rev_tracker, parent: :reverification_tracker do
    association :account, :soft_bounce
  end

  factory :marked_for_spam_rev_tracker, parent: :reverification_tracker do
    association :account, :no_verification
    phase 1
  end

  factory :spam_rev_tracker, parent: :reverification_tracker do
    association :account, :spammer
    phase 2
  end

  factory :final_warning_rev_tracker, parent: :reverification_tracker do
    association :account, :spammer
    phase 3
  end

  factory :invalid_final_warning_rev_tracker, parent: :reverification_tracker do
    association :account, :invalid_spammer
    phase 3
  end
end
