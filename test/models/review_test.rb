# frozen_string_literal: true

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
    _(Review.for_project(proj).top.map(&:id).sort).must_equal [review1.id, review3.id]
  end

  describe 'score' do
    it 'score' do
      create(:rating, account: review.account, project: review.project)
      _(review.score).must_equal 3
    end

    it 'should return zero if ratings not found' do
      _(review.score).must_equal 0
    end
  end

  describe 'validate comment' do
    it 'should fail if comment is empty' do
      review = Review.new(title: 'title', comment: '')
      _(review.valid?).must_equal false
      _(review.errors.count).must_equal 2
      _(review.errors[:comment]).must_equal ["can't be blank"]
    end

    it 'should be between 1 and 5000 characters' do
      review = Review.new(title: 'title', comment: Faker::Lorem.characters(number: 5001))
      _(review.valid?).must_equal false
      _(review.errors.count).must_equal 2
      _(review.errors[:comment]).must_equal ['is too long (maximum is 5000 characters)']
    end
  end

  describe '#find_by_comment_or_title_or_accounts_login' do
    it 'find by comment' do
      review1 = create(:review, comment: 'search_by_comment')
      search_result = Review.find_by_comment_or_title_or_accounts_login('search_by_comment')
      _(search_result.count).must_equal 1
      _(search_result.first).must_equal review1
    end

    it 'find by title' do
      review1 = create(:review, title: 'search_by_title')
      search_result = Review.find_by_comment_or_title_or_accounts_login('search_by_title')
      _(search_result.count).must_equal 1
      _(search_result.first).must_equal review1
    end

    it 'find by accounts login' do
      search_result = Review.find_by_comment_or_title_or_accounts_login(review.account.login)
      _(search_result.count).must_equal 1
      _(search_result.first).must_equal review
    end
  end

  describe 'helpful_to_account?' do
    it 'should return true if review helpful to account' do
      helpful_account = create(:helpful, review: review).account
      _(review.helpful_to_account?(helpful_account)).must_equal true
    end

    it 'should return false if review not helpful' do
      helpful_account = create(:helpful, review: review, yes: false).account
      _(review.helpful_to_account?(helpful_account)).must_equal false
    end
  end

  describe '#sort_by' do
    let(:review_1) { create(:review) }
    let(:review_2) { create(:review) }
    let(:review_3) { create(:review) }

    it 'helpful' do
      create(:helpful, review: review_1)
      create(:helpful, review: review_2, yes: false)

      _(Review.order_by.pluck(:id)).must_equal [review_1.id, review_2.id]
    end

    it 'highest_rated' do
      create(:rating, account: review_1.account, project: review_1.project, score: 3)
      create(:rating, account: review_2.account, project: review_2.project, score: 4)
      create(:rating, account: review_3.account, project: review_3.project, score: 1)

      _(Review.order_by('highest_rated')).must_equal [review_2, review_1, review_3]
    end

    it 'lowest_rated' do
      create(:rating, account: review_1.account, project: review_1.project, score: 5)
      create(:rating, account: review_2.account, project: review_2.project, score: 4)
      create(:rating, account: review_3.account, project: review_2.project, score: 3)

      _(Review.order_by('lowest_rated')).must_equal [review_3, review_2, review_1]
    end

    it 'recently_added: must sort by review.created_at desc' do
      date_sorted_reviews = [review_1, review_2].sort_by(&:created_at).reverse

      _(Review.order_by('recently_added')).must_equal date_sorted_reviews
    end

    it 'author: must sort by account.login' do
      account_sorted_reviews = [review_1, review_2].sort_by { |review| review.account.login }

      _(Review.order_by('author')).must_equal account_sorted_reviews
    end

    it 'project: must sort by project.name' do
      project_sorted_reviews = [review_1, review_2].sort_by { |review| review.project.name }

      _(Review.order_by('project')).must_equal project_sorted_reviews
    end
  end
end
