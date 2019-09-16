# frozen_string_literal: true

require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  let(:project) { create(:project) }

  it 'should read a key value when a valid key is provided' do
    key = 'hello'
    value = 'there'
    Setting.create(key: key, value: value)
    Setting.get_value(key).must_equal value
  end

  it 'should return nil when a invalid key is provided' do
    assert_nil Setting.get_value('invalid_key')
  end

  it 'should return the project enlistment key' do
    Setting.get_project_enlistment_key('4').must_equal 'sidekiq_enlistment_project_id_4'
  end

  describe 'Project Enlistment Job' do
    it 'should create a worker record' do
      Setting.count.must_equal 0
      create_worker('1234', 'fontli')
      Setting.count.must_equal 1
      Setting.first.value.length.must_equal 1
    end

    it 'should update the new enlistment without a new record' do
      create_worker('4567', 'test')
      create_worker('1234', 'fontli')
      Setting.count.must_equal 1
      Setting.first.value.length.must_equal 2 # should have 2 hashes
    end

    it 'should remove the hash once the job is completed' do
      create_worker('4567', 'test')
      create_worker('1234', 'fontli')
      Setting.first.value.length.must_equal 2
      Setting.complete_enlistment_job(project.id, 'fontli')
      Setting.first.value.length.must_equal 1
    end
  end

  private

  def create_worker(worker_id, url)
    Setting.update_worker(project.id, worker_id, url)
  end
end
