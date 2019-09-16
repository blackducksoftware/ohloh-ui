# frozen_string_literal: true

class Account::StackCore < OhDelegator::Base
  parent_scope do
    has_many :stacks, -> { order(updated_at: :desc).where(deleted_at: nil) }
  end

  def default
    stacks << Stack.new unless @default || stacks.present?
    @default ||= stacks[0]
  end
end
