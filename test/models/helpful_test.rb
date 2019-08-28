# frozen_string_literal: true

require 'test_helper'

class HelpfulTest < ActiveSupport::TestCase
  let(:review) do
    Review.create!(account_id: create(:admin).id, project: create(:project),
                   comment: 'Dummy Comment', title: 'Dummy Title')
  end

  it 'test cant helpful your own review' do
    h = review.helpfuls.create(account_id: review.account_id)
    h.wont_be :valid?
    h.errors[:account].must_equal ["can't moderate your own review"]
  end

  it 'test target' do
    h = review.helpfuls.create!(account_id: create(:account).id)
    h.review.must_equal review
  end

  it 'test after save updates helpful score' do
    assert_difference('review.reload.helpful_score', 1) do
      review.helpfuls.create!(account_id: create(:account).id, yes: true)
    end
  end
end
