require 'test_helper'

class AnlysisDecoratorTest < ActiveSupport::TestCase
  describe '#tool_tip' do
    it 'should return the tool_tip with brief information' do
      job = create(:complete_job, current_step: 6, max_steps: 6)
      step_text = "(#{job.current_step}/#{job.max_steps})"
      code_location_text = "#{job.code_location.repository.url} #{job.code_location.module_branch_name}"
      tool_tip = "#{step_text}\n#{code_location_text}"
      JobDecorator.new(job).tool_tip.must_equal tool_tip
    end
  end
end
