# frozen_string_literal: true

require 'test_helper'

class OrganizationJobTest < ActiveSupport::TestCase
  describe 'progress_message' do
    it 'should return required message' do
      job = OrganizationJob.create(organization: create(:organization))
      _(job.progress_message).must_equal "Analyzing organization #{job.organization.name}"
    end
  end
end
