ActiveAdmin.register VitaJob do
  menu false
  config.sort_order = 'current_step_at_desc'

  belongs_to :account, finder: :find_by_login, optional: true

  permit_params :status, :priority, :wait_until, :current_step_at, :notes

  filter :slave, collection: proc { Slave.pluck(:hostname).sort }
  filter :job_status
  filter :account_login, as: :string, label: 'Account Login'

  actions :all, except: :new

  action_item :manually_schedule, only: :index do
    if params[:account_id]
      link_to 'Manually Create Vita Job', manually_schedule_admin_account_vita_jobs_path(account), method: :post
    end
  end

  index do
    column :type
    column :id do |job|
      link_to job.id, admin_job_path(job)
    end
    column 'Priority', :priority
    column :current_step_at
    column 'Last Updated' do |job|
      time_ago_in_words(job.current_step_at) if job.current_step_at
    end
    column 'Progress' do |job|
      "#{job.current_step? ? job.current_step : '-'} of #{job.max_steps? ? job.max_steps : '-'}"
    end
    column 'Owners' do |job|
      span link_to "Account #{job.account.login}", account_path(job.account) if job.account_id
    end
  end

  controller do
    def manually_schedule
      account = Account.find_by(login: params[:account_id])
      VitaJob.create(account: account, priority: 0)
      redirect_to admin_account_vita_jobs_path(account), flash: { success: 'Vita Job has been created manually.' }
    end
  end
end
