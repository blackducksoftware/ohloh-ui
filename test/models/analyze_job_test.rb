# frozen_string_literal: true

require 'test_helper'

class ProjectAnalysisJobTest < ActiveSupport::TestCase
  describe 'progress_message' do
    it 'should return required message' do
      job = ProjectAnalysisJob.create(project: create(:project))
      _(job.progress_message).must_equal "Analyzing project #{job.project.name}"
    end
  end
end
