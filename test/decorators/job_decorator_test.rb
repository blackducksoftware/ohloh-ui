require 'test_helper'

class JobDecoratorTest < ActiveSupport::TestCase
  describe 'tool_tip' do
    it 'must print the correct value' do
      project = create(:project)
      job = create(:fetch_job, current_step: 5, max_steps: 12, project: project)
      code_location = job.code_location
      text = "(5/12)\n#{project.name}\n#{code_location.repository.url} #{code_location.module_branch_name}"
      JobDecorator.new(job).tool_tip.must_equal text
    end
  end
end
