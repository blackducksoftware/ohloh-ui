# frozen_string_literal: true

require 'test_helper'

class RatingTest < ActiveSupport::TestCase
  before do
    @project = create(:project)
    @account = create(:account)
  end

  it 'does not allow nil score' do
    _(Rating.new(project: @project, account: @account, score: nil).valid?).must_equal false
  end

  it 'allows score of 1' do
    _(Rating.new(project: @project, account: @account, score: 1).valid?).must_equal true
  end

  it 'allows score of 5' do
    _(Rating.new(project: @project, account: @account, score: 5).valid?).must_equal true
  end

  it 'does not allow score of 0' do
    _(Rating.new(project: @project, account: @account, score: 0).valid?).must_equal false
  end

  it 'does not allow score of 6' do
    _(Rating.new(project: @project, account: @account, score: 6).valid?).must_equal false
  end

  it 'recalculates project rating_average on save and delete' do
    rating = create(:rating, project: @project, score: 1)
    @project.reload
    _(@project.rating_average).must_equal 1.0
    create(:rating, project: @project, score: 5)
    @project.reload
    _(@project.rating_average).must_equal 3.0
    rating.destroy
    @project.reload
    _(@project.rating_average).must_equal 5.0
  end
end
