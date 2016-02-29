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
    phase 0
  end

  factory :marked_for_spam_rev_tracker, parent: :reverification_tracker do
    # Note: ':no_verification' is a trait defined in factories/accounts
    association :account, :no_verification
    phase 1
  end

  factory :spam_rev_tracker, parent: :reverification_tracker do
    association :account, :spammer
    phase 2
  end

  factory :final_warning_rev_tracker, parent: :reverification_tracker do
    #  Note: ':spammer' is a trait defined in factories/accounts
    association :account, :spammer
    phase 3
  end

  factory :invalid_final_warning_rev_tracker, parent: :reverification_tracker do
    #  Note: ':invalid_spammer' is a trait defined in factories/accounts
    association :account, :invalid_spammer
    phase 3
  end
end
