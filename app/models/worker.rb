# frozen_string_literal: true

class Worker < ActiveRecord::Base
  has_many :jobs
  has_many :running_jobs, -> { worker_recent_jobs.running }, class_name: Job
  has_many :failed_jobs, -> { worker_recent_jobs.failed }, class_name: Job
end
