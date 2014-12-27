require 'test_helper'

class AvatarHelperTest < ActionView::TestCase
  include AvatarHelper
  fixtures :accounts, :people

  it 'avatar_img_path should handle accounts' do
    path = avatar_img_path(accounts(:admin))
    path.ends_with?('.gif').must_equal true
  end

  it 'avatar_img_path should handle people' do
    path = avatar_img_path(people(:jason))
    path.ends_with?('.gif').must_equal true
  end

  it 'avatar_img_path should handle garbage for who' do
    path = avatar_img_path('this was supported before for some reason')
    path.ends_with?('.gif').must_equal true
  end

  it 'avatar_for should accept accounts' do
    link = avatar_for(accounts(:admin))
    link.starts_with?('<a').must_equal true
  end

  it 'avatar_for should accept people' do
    link = avatar_for(people(:jason))
    link.starts_with?('<a').must_equal true
  end

  it 'avatar_for should clamp sizes to 80' do
    link = avatar_for(accounts(:admin), size: 1_000)
    link.must_match(/80/)
  end

  it 'avatar_for should allow overriding url' do
    link = avatar_for(accounts(:admin), url: 'http://cnn.com')
    link.must_match(/cnn\.com/)
  end

  it 'avatar_for should allow inserting a title for an account' do
    link = avatar_for(accounts(:admin), title: true)
    link.must_match(/title/)
  end

  it 'avatar_for should allow inserting a title for an person' do
    link = avatar_for(people(:jason), title: true)
    link.must_match(/title/)
  end

  it 'avatar_for should allow inserting a title for garbage who' do
    link = avatar_for('this was supported before for some reason', url: 'http://cnn.com', title: true)
    link.starts_with?('<a').must_equal true
  end
end
