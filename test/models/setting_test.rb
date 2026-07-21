# frozen_string_literal: true

require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  let(:project) { create(:project) }

  it 'should read a key value when a valid key is provided' do
    key = 'hello'
    value = 'there'
    Setting.create(key: key, value: value)
    _(Setting.get_value(key)).must_equal value
  end

  it 'should return nil when a invalid key is provided' do
    _(Setting.get_value('invalid_key')).must_be_nil
  end

  it 'should return the project enlistment key' do
    _(Setting.get_project_enlistment_key('4')).must_equal 'sidekiq_enlistment_project_id_4'
  end

  describe 'Project Enlistment Job' do
    it 'should create a worker record' do
      _(Setting.count).must_equal 0
      create_worker('1234', 'fontli')
      _(Setting.count).must_equal 1
      _(Setting.first.value.length).must_equal 1
    end

    it 'should update the new enlistment without a new record' do
      create_worker('4567', 'test')
      create_worker('1234', 'fontli')
      _(Setting.count).must_equal 1
      _(Setting.first.value.length).must_equal 2 # should have 2 hashes
    end

    it 'should remove the hash once the job is completed' do
      create_worker('4567', 'test')
      create_worker('1234', 'fontli')
      _(Setting.first.value.length).must_equal 2
      Setting.complete_enlistment_job(project.id, 'fontli')
      _(Setting.first.value.length).must_equal 1
    end
  end

  describe 'Theme Preference Settings' do
    let(:account) { create(:account) }
    let(:setting_key) { "account_#{account.id}_theme_preference" }

    it 'should store theme preference with account id key' do
      setting = Setting.create(key: setting_key, value: 'dark')

      _(setting).wont_be_nil
      _(setting.key).must_equal(setting_key)
      _(setting.value).must_equal('dark')
    end

    it 'should retrieve theme preference by key' do
      Setting.create(key: setting_key, value: 'light')

      preference = Setting.get_value(setting_key)

      _(preference).must_equal('light')
    end

    it 'should return nil for non-existent preference' do
      preference = Setting.get_value("non_existent_key_#{account.id}")

      _(preference).must_be_nil
    end

    it 'should support system, light, and dark theme values' do
      themes = %w[system light dark]

      themes.each do |theme|
        setting = Setting.create(key: "test_theme_#{theme}", value: theme)
        _(setting.value).must_equal(theme)
      end
    end

    it 'should update existing preference without creating duplicate' do
      Setting.create(key: setting_key, value: 'light')
      assert_equal(1, Setting.where(key: setting_key).count)

      Setting.find_by(key: setting_key).update(value: 'dark')

      assert_equal(1, Setting.where(key: setting_key).count)
      _(Setting.get_value(setting_key)).must_equal('dark')
    end

    it 'should support find_or_create_by for preferences' do
      initial_count = Setting.count

      setting1 = Setting.find_or_create_by(key: setting_key)
      setting1.update(value: 'dark')

      setting2 = Setting.find_or_create_by(key: setting_key)
      setting2.update(value: 'light')

      _(Setting.count).must_equal(initial_count + 1)
      _(Setting.get_value(setting_key)).must_equal('light')
    end
  end

  private

  def create_worker(worker_id, url)
    Setting.update_worker(project.id, worker_id, url)
  end
end
