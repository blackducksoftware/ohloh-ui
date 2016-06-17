class Setting < ActiveRecord::Base
  serialize :value
  class << self
    def get_value(key)
      where(key: key).pluck(:value).first
    end

    def update_worker(project_id, worker_id, url)
      key = get_project_enlistment_key(project_id)
      value = { url => worker_id }
      create_update_worker_object(key, value)
    end

    def create_update_worker_object(key, value)
      object = find_by(key: key)
      if object
        object.value.merge!(value)
        object.save
      else
        create(key: key, value: value)
      end
    end

    def complete_enlistment_job(project_id, url)
      key = get_project_enlistment_key(project_id)
      object = find_by(key: key)
      object.value.delete(url)
      object.save
    end

    def get_project_enlistment_key(project_id)
      "project_#{project_id}_enlistment_jobs"
    end
  end
end
