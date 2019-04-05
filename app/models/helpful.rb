class Helpful < ActiveRecord::Base
  belongs_to :review
  belongs_to :account

  validate :cant_moderate_own_reviews

  scope :positive, -> { where(yes: true) }
  scope :negative, -> { where(yes: false) }
  scope :for_account, ->(account) { where(account_id: account.id) }

  after_save :update_review_score

  private

  def cant_moderate_own_reviews
    return unless account_id == review.account_id

    errors.add :account, I18n.t('helpfuls.cant_moderate_own_reviews')
  end

  def update_review_score
    review.update(helpful_score: review.helpfuls.positive.count - review.helpfuls.negative.count)
  end
end
