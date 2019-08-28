# frozen_string_literal: true

require 'test_helper'

class LanguagesTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:widget) { ProjectWidget::Languages.new(project_id: project.id) }

  describe 'height' do
    it 'should return 210' do
      widget.height.must_equal 210
    end
  end

  describe 'width' do
    it 'should return 350' do
      widget.width.must_equal 350
    end
  end

  describe 'title' do
    it 'should return the title' do
      widget.title.must_equal I18n.t('project_widgets.languages.title')
    end
  end

  describe 'position' do
    it 'should return 4' do
      widget.position.must_equal 4
    end
  end
end
