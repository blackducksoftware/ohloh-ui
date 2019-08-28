# frozen_string_literal: true

require 'test_helper'

class FactoidsTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:widget) { ProjectWidget::Factoids.new(project_id: project.id) }

  describe 'height' do
    it 'should return 175' do
      widget.height.must_equal 175
    end
  end

  describe 'width' do
    it 'should return 350' do
      widget.width.must_equal 350
    end
  end

  describe 'title' do
    it 'should return the title' do
      widget.title.must_equal I18n.t('project_widgets.factoids.title')
    end
  end

  describe 'position' do
    it 'should return 2' do
      widget.position.must_equal 2
    end
  end
end
