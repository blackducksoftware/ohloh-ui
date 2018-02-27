require 'test_helper'

class JobDecoratorTest < ActiveSupport::TestCase
  describe 'tool_tip' do
    it 'must print the correct value' do
      WebMocker.get_code_location
      project = create(:project)
      enlistment = create_enlistment_with_code_location
      code_location = enlistment.code_location
      job = create(:fetch_job, code_location_id: enlistment.code_location_id, current_step: 5, max_steps: 12,
                               project: project)
      text = "(5/12)\n#{project.name}\n#{code_location.url} #{code_location.branch}"
      JobDecorator.new(job).tool_tip.must_equal text
    end
  end
end
