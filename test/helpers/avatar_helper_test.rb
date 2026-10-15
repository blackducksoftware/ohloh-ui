# frozen_string_literal: true

require 'test_helper'

class AvatarHelperTest < ActionView::TestCase
  include AvatarHelper
  let(:person) { create(:account).person }

  it 'avatar_img_path should handle accounts' do
    path = avatar_img_path(create(:admin))
    _(path.ends_with?('.gif')).must_equal true
  end

  it 'avatar_img_path should handle people' do
    path = avatar_img_path(person)
    _(path.ends_with?('.gif')).must_equal true
  end

  it 'avatar_img_path should handle garbage for who' do
    path = avatar_img_path('this was supported before for some reason')
    _(path.ends_with?('.gif')).must_equal true
  end

  it 'avatar_for should accept accounts' do
    link = avatar_for(create(:admin))
    _(link.starts_with?('<a')).must_equal true
  end

  it 'avatar_for should accept people' do
    link = avatar_for(person)
    _(link.starts_with?('<a')).must_equal true
  end

  it 'avatar_for should clamp anon fallback size to 80' do
    _(avatar_default_size(1_000)).must_equal 80
  end

  it 'avatar_for should allow overriding url' do
    link = avatar_for(create(:admin), url: 'http://cnn.com')
    _(link).must_match(/cnn\.com/)
  end

  it 'avatar_for should allow inserting a title for an account' do
    link = avatar_for(create(:admin), title: true)
    _(link).must_match(/title/)
  end

  it 'avatar_for should allow inserting a title for an person' do
    link = avatar_for(person, title: true)
    _(link).must_match(/title/)
  end

  it 'avatar_for should allow inserting a title for garbage who' do
    link = avatar_for('this was supported before for some reason', url: 'http://cnn.com', title: true)
    _(link.starts_with?('<a')).must_equal true
  end

  describe 'gravatar_url' do
    it 'returns local anon gif path' do
      path = gravatar_url('any_md5', 12)
      _(path.ends_with?('.gif')).must_equal true
      _(path).must_include 'anon32'
    end

    it 'uses anon80 for sizes above 40' do
      path = gravatar_url('any_md5', 80)
      _(path).must_include 'anon80'
    end
  end
end
