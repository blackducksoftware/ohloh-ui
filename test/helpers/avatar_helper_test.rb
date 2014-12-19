require 'test_helper'

class AvatarHelperTest < ActionView::TestCase
  include AvatarHelper
  fixtures :accounts, :people

  test 'avatar_img_path should handle accounts' do
    path = avatar_img_path(accounts(:admin))
    assert path.ends_with? '.gif'
  end

  test 'avatar_img_path should handle people' do
    path = avatar_img_path(people(:jason))
    assert path.ends_with? '.gif'
  end

  test 'avatar_img_path should handle garbage for who' do
    path = avatar_img_path('this was supported before for some reason')
    assert path.ends_with? '.gif'
  end

  test 'avatar_for should accept accounts' do
    link = avatar_for(accounts(:admin))
    assert link.starts_with? '<a'
  end

  test 'avatar_for should accept people' do
    link = avatar_for(people(:jason))
    assert link.starts_with? '<a'
  end

  test 'avatar_for should clamp sizes to 80' do
    link = avatar_for(accounts(:admin), size: 1_000)
    assert(/80/.match(link))
  end

  test 'avatar_for should allow overriding url' do
    link = avatar_for(accounts(:admin), url: 'http://cnn.com')
    assert(/cnn\.com/.match(link))
  end

  test 'avatar_for should allow inserting a title for an account' do
    link = avatar_for(accounts(:admin), title: true)
    assert(/title/.match(link))
  end

  test 'avatar_for should allow inserting a title for an person' do
    link = avatar_for(people(:jason), title: true)
    assert(/title/.match(link))
  end

  test 'avatar_for should allow inserting a title for garbage who' do
    link = avatar_for('this was supported before for some reason', url: 'http://cnn.com', title: true)
    assert link.starts_with? '<a'
  end
end
