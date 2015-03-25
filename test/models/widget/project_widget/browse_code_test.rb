require 'test_helper'

class BrowseCodeTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:widget) { ProjectWidget::BrowseCode.new(project_id: project.id) }

  describe 'height' do
    it 'should return 205' do
      widget.height.must_equal 205
    end
  end

  describe 'width' do
    it 'should return 350' do
      widget.width.must_equal 350
    end
  end

  describe 'can_display?' do
    it 'should return false' do
      project.stubs(:code_published_in_code_search?).returns(false)
      widget.can_display?.must_equal false
    end
  end

  describe 'position' do
    it 'should return 5' do
      widget.position.must_equal 5
    end
  end

  describe 'title' do
    it 'should return the title' do
      widget.title.must_equal I18n.t('project_widgets.browse_code.title')
    end
  end

  describe 'short_nice_name' do
    it 'should return the short_nice_name' do
      widget.short_nice_name.must_equal I18n.t('project_widgets.browse_code.short_nice_name')
    end
  end
end
