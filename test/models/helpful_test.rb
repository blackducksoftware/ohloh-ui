require 'test_helper'

class HelpfulTest < ActiveSupport::TestCase
  def setup
    @review = Review.create!(account_id: accounts(:admin).id, project: projects(:linux),
                             comment: 'Dummy Comment', title: 'Dummy Title')
  end

  def test_cant_helpful_your_own_review
    h = @review.helpfuls.create(account_id: @review.account_id)
    assert !h.valid?
    assert_equal ["can't moderate your own review"], h.errors[:account]
  end

  def test_target
    h = @review.helpfuls.create!(account_id: accounts(:user).id)
    assert_equal @review, h.review
  end

  def test_after_save_updates_helpful_score
    assert_difference('@review.reload.helpful_score', 1) do
      @review.helpfuls.create!(account_id: accounts(:user).id, yes: true)
    end
  end
end
