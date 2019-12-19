# frozen_string_literal: true

require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
  it 'should compute the  how many percentage are interested for knowing more info' do
    feedback = create(:feedback)
    Feedback.interested(feedback.project_id).must_equal '100%'
  end

  it 'should compute the rating scale and send as array output' do
    feedback = create(:feedback)
    Feedback.rating_scale(feedback.project_id).must_equal [[0, 0], [0, 0], [0, 0], [0, 0], [1, 100]]
  end

  it 'should set the project_id for based on project name when project_id is nil' do
    project = create(:project)
    feedback = create(:feedback, project_id: '', project_name: project.name)
    feedback.project_id.must_equal project.id
  end
end
