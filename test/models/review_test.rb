require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  let(:review) { create(:review) }

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

  describe 'score' do
    it 'score' do
      create(:rating, account: review.account, project: review.project)
      review.score.must_equal 3
    end

    it 'should return zero if ratings not found' do
      review.score.must_equal 0
    end
  end

  describe '#find_by_comment_or_title_or_accounts_login' do
    it 'find by comment' do
      review1 = create(:review, comment: 'search_by_comment')
      search_result = Review.find_by_comment_or_title_or_accounts_login('search_by_comment')
      search_result.count.must_equal 1
      search_result.first.must_equal review1
    end

    it 'find by title' do
      review1 = create(:review, title: 'search_by_title')
      search_result = Review.find_by_comment_or_title_or_accounts_login('search_by_title')
      search_result.count.must_equal 1
      search_result.first.must_equal review1
    end

    it 'find by accounts login' do
      search_result = Review.find_by_comment_or_title_or_accounts_login(review.account.login)
      search_result.count.must_equal 1
      search_result.first.must_equal review
    end
  end

  describe 'helpful_to_account?' do
    it 'should return true if review helpful to account' do
      helpful_account = create(:helpful, review: review).account
      review.helpful_to_account?(helpful_account).must_equal true
    end

    it 'should return false if review not helpful' do
      helpful_account = create(:helpful, review: review, yes: false).account
      review.helpful_to_account?(helpful_account).must_equal false
    end
  end

  describe '#sort_by' do
    it 'helpful' do
      create_reviews_for_sort_by
      Review.sort_by.pluck(:id).must_equal [@review1.id, @review2.id]
    end

    it 'highest_rated' do
      create_reviews_for_sort_by
      Review.sort_by('highest_rated').pluck(:id).must_equal [@review2.id, @review1.id]
    end

    it 'lowest_rated' do
      create_reviews_for_sort_by
      Review.sort_by('highest_rated').pluck(:id).must_equal [@review2.id, @review1.id]
    end

    it 'recently_added' do
      create_reviews_for_sort_by
      Review.sort_by('recently_added').pluck(:id).must_equal [@review2.id, @review1.id]
    end

    it 'author' do
      create_reviews_for_sort_by
      Review.sort_by('recently_added').pluck(:id).must_equal [@review2.id, @review1.id]
    end

    it 'project' do
      create_reviews_for_sort_by
      Review.sort_by('recently_added').pluck(:id).must_equal [@review2.id, @review1.id]
    end
  end

  private

  def create_reviews_for_sort_by
    @review1 = create(:review)
    @review2 = create(:review)
    create(:helpful, review: @review1)
    create(:helpful, review: @review2, yes: false)
  end
end
