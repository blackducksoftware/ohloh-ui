# frozen_string_literal: true

require 'test_helper'

class EditHistoryTest < ActionDispatch::IntegrationTest
  include EditsHelper
  let(:project) { create(:project) }

  describe 'Edit' do
    describe 'show' do
      it 'should have more/less hyperlink for lengthier value' do
        login_as create(:account)
        @parent = project
        project.update_attribute :description, Faker::Lorem.sentence(100)
        xhr :get, show_edit_path(project.edits.where(key: 'description').last)
        assert_response :success
        assert response.body.match(/\[More\]/)
        assert response.body.match(/\[Less\]/)
      end
    end
  end
end
