require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  fixtures :accounts, :projects

  test '#first_review_for' do
    account = accounts(:user)
    project = projects(:linux)
    review = Review.create!(account_id: account.id, project_id: project.id)

    assert_equal review, project.first_review_for(account)
  end
end
