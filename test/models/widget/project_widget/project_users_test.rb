require 'test_helper'

class UsersTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:widget) { ProjectWidget::Users.new(project_id: project.id, style: 'blue') }

  describe 'height' do
    it 'should return 115' do
      widget.height.must_equal 115
    end
  end

  describe 'width' do
    it 'should return 95' do
      widget.width.must_equal 95
    end
  end

  describe 'position' do
    it 'should return 16' do
      widget.position.must_equal 16
    end
  end

  describe 'background_color' do
    it 'should return a blue color code' do
      widget.background_color.must_equal '#036CB6'
    end
  end

  describe 'title' do
    it 'should return the title' do
      widget.title.must_equal I18n.t('project_widgets.users.title')
    end
  end

  describe 'short_nice_name' do
    it 'should return the short_nice_name' do
      widget.short_nice_name.must_equal I18n.t('project_widgets.project_users.short_nice_name',
                                               text: widget.style.capitalize)
    end
  end

  describe 'instantiate_styled_badges' do
    it 'should return badges of all possible colors' do
      users_widgets = ProjectWidget::Users.instantiate_styled_badges(project_id: project.id)
      users_widgets.map(&:position).must_equal [13, 17, 14, 15, 16, 12]
      users_widgets.map(&:style).must_equal ['gray', 'rainbow', 'green', 'red', 'blue', nil]
      users_widgets.map(&:background_color).must_equal ['#525456', nil, '#197B30', '#E11717', '#036CB6', nil]
    end
  end
end
