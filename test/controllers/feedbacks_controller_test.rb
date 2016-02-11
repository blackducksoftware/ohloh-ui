require 'test_helper'

describe 'FeedbacksController' do
  it 'creates feedback' do
    assert_difference('Feedback.count') do
      post :create, feedback: { rating: 5, uuid: 'e91fc264-12345', more_info: 1, project_name: 'Ruby On Rails' }
    end
    assert_response :success
  end
end
