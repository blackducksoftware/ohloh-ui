ActiveAdmin.register SlaveLog do
  remove_filter :job
  actions :index

  index do
    column :id
    column 'Created' do |slave_log|
      time_ago_in_words(slave_log.created_on)
    end
    column 'Host' do |slave_log|
      link_to slave_log.slave.hostname, admin_slafe_path(slave_log.slave) if slave_log.slave
    end
    column 'Job' do |slave_log|
      span link_to slave_log.job_id, admin_job_path(slave_log.job_id) if slave_log.job_id
    end
    column :message
  end

  controller do
    def scoped_collection
      if params[:code_location_id]
        Job.where(code_location_id: params[:code_location_id]).slave_logs
      elsif params[:job_id]
        SlaveLog.where(job_id: params[:job_id])
      else
        super
      end
    end
  end
end
