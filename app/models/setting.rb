# frozen_string_literal: true

class Setting < ApplicationRecord
  serialize :value
  class << self
    def get_value(key)
      where(key: key).pluck(:value).first
    end

    def update_worker(project_id, worker_id, url)
      key = get_project_enlistment_key(project_id)
      create_update_worker_object(key, url => worker_id)
    end

    def create_update_worker_object(key, value)
      object = find_or_create_by(key: key)
      object.value ||= {}
      object.value.merge!(value)
      object.save
    end

    def complete_enlistment_job(project_id, url)
      key = get_project_enlistment_key(project_id)
      object = find_by(key: key)
      return if object.nil?

      object.value.delete(url)
      object.save
      object.destroy if object.value.empty?
    end

    def get_project_enlistment_key(project_id)
      "sidekiq_enlistment_project_id_#{project_id}"
    end
  end
end
