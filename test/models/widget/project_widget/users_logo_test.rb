# frozen_string_literal: true

require 'test_helper'

class UsersLogoTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:widget) { ProjectWidget::UsersLogo.new(project_id: project.id) }

  describe 'height' do
    it 'should return 40' do
      widget.height.must_equal 40
    end
  end

  describe 'width' do
    it 'should return 150' do
      widget.width.must_equal 150
    end
  end

  describe 'position' do
    it 'should return 11' do
      widget.position.must_equal 11
    end
  end

  describe 'title' do
    it 'should return the title' do
      widget.title.must_equal I18n.t('project_widgets.users_logo.title')
    end
  end

  describe 'short_nice_name' do
    it 'should return the short_nice_name' do
      widget.short_nice_name.must_equal I18n.t('project_widgets.users_logo.short_nice_name')
    end
  end
end
