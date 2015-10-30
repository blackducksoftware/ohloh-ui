ActiveAdmin.register SlaveLog do
  belongs_to :job
  remove_filter :job

  index do
    column :id
    column "Created" do |slave_log|
      time_ago_in_words(slave_log.created_on)
    end
    column "Host" do |slave_log|
      Slave.find(slave_log.slave_id).hostname
    end
    column "Job" do |slave_log|
      span link_to slave_log.job_id, admin_job_path(slave_log.job_id)
    end
    column :message
  end
end
