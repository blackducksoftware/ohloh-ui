require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  it '#first_review_for' do
    account = accounts(:user)
    project = projects(:linux)
    review = Review.create!(account_id: account.id, project_id: project.id)

    project.first_review_for(account).must_equal review
  end
end
