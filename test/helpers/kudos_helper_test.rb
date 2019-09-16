# frozen_string_literal: true

require 'test_helper'

class KudosHelperTest < ActionView::TestCase
  include KudosHelper

  describe 'kudos_aka_name' do
    it 'should return kudo name' do
      position = create(:position)
      kudo = create(:kudo, name_id: position.name_id, project_id: position.project_id)
      kudos_aka_name(kudo).must_match kudo.name.name
    end
  end
end
