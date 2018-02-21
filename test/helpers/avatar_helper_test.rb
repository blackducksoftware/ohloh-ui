require 'test_helper'

class AvatarHelperTest < ActionView::TestCase
  include AvatarHelper
  let(:person) { create(:account).person }

  it 'avatar_img_path should handle accounts' do
    path = avatar_img_path(create(:admin))
    path.ends_with?('.gif').must_equal true
  end

  it 'avatar_img_path should handle people' do
    path = avatar_img_path(person)
    path.ends_with?('.gif').must_equal true
  end

  it 'avatar_img_path should handle garbage for who' do
    path = avatar_img_path('this was supported before for some reason')
    path.ends_with?('.gif').must_equal true
  end

  it 'avatar_for should accept accounts' do
    link = avatar_for(create(:admin))
    link.starts_with?('<a').must_equal true
  end

  it 'avatar_for should accept people' do
    link = avatar_for(person)
    link.starts_with?('<a').must_equal true
  end

  it 'avatar_for should clamp sizes to 80' do
    link = avatar_for(create(:admin), size: 1_000)
    link.must_match(/80/)
  end

  it 'avatar_for should allow overriding url' do
    link = avatar_for(create(:admin), url: 'http://cnn.com')
    link.must_match(/cnn\.com/)
  end

  it 'avatar_for should allow inserting a title for an account' do
    link = avatar_for(create(:admin), title: true)
    link.must_match(/title/)
  end

  it 'avatar_for should allow inserting a title for an person' do
    link = avatar_for(person, title: true)
    link.must_match(/title/)
  end

  it 'avatar_for should allow inserting a title for garbage who' do
    link = avatar_for('this was supported before for some reason', url: 'http://cnn.com', title: true)
    link.starts_with?('<a').must_equal true
  end

  describe 'gravatar_url' do
    it 'should have localhost host name' do
      ActionController::Base.stubs(:asset_host).returns('localhost')
      gravatar_url('123', 12).must_equal 'https://gravatar.com/avatar/123?&s=12&rating=PG&d=http%3a%2f%2flocalhost%2fanon32.gif'
    end

    it 'should contain openhub host name' do
      gravatar_url('123', 12).must_equal 'https://gravatar.com/avatar/123?&s=12&rating=PG&d=https%3a%2f%2fopenhub.net%2fanon32.gif'
    end
  end
end
