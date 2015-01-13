require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  it '#top' do
    proj = create(:project)
    review1 = create(:review, project: proj)
    review2 = create(:review, project: proj)
    review3 = create(:review, project: proj)
    create(:helpful, review: review1, yes: true)
    create(:helpful, review: review2, yes: false)
    create(:helpful, review: review3, yes: true)
    Review.for_project(proj).top.map(&:id).sort.must_equal [review1.id, review3.id]
  end
end
