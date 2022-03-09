# frozen_string_literal: true

require 'test_helper'

class CocomoTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:widget) { ProjectWidget::Cocomo.new(project_id: project.id) }

  describe 'height' do
    it 'should return 205' do
      _(widget.height).must_equal 205
    end
  end

  describe 'width' do
    it 'should return 350' do
      _(widget.width).must_equal 350
    end
  end

  describe 'position' do
    it 'should return 8' do
      _(widget.position).must_equal 8
    end
  end

  describe 'title' do
    it 'should return the title' do
      _(widget.title).must_equal I18n.t('project_widgets.cocomo.title')
    end
  end

  describe 'salary' do
    it 'should return 55000' do
      _(widget.salary).must_equal '55000'
    end
  end
end
