class ReverificationPilotAccount < ActiveRecord::Base
  belongs_to :account
  TOTAL_SAMPLES = 5000

  before_create :check_for_duplicate

  def self.copy_accounts(size = TOTAL_SAMPLES)
    accounts_hash = Account.reverification_not_initiated(size).map(&:id).map { |a| { account_id: a } }
    create accounts_hash
  end

  private

  def check_for_duplicate
    self.class.where(account_id: account_id).empty?
  end
end
