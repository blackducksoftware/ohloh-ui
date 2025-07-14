# frozen_string_literal: true

require 'forwardable'

class Account::StackCore
  extend Forwardable
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def_delegators :account, :stacks

  def default
    stacks << Stack.new unless @default || stacks.present?
    @default ||= stacks[0]
  end
end
