# frozen_string_literal: true

ActiveAdmin.register OrganizationJob do
  menu false
  belongs_to :organization, finder: :find_by_vanity_url!, optional: true
  config.sort_order = 'current_step_at_desc'
  permit_params :status, :priority, :wait_until, :current_step_at, :notes

  filter :slave, collection: proc { Slave.pluck(:hostname).sort }
  filter :job_status
  filter :organization_vanity_url, as: :string, label: 'ORGANIZATION VANITY URL'
  actions :all, except: :new

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
    column :status do |job|
      span job.job_status.try(:name)
    end
    column 'Owners' do |job|
      span link_to "Organization #{job.organization.name}", project_path(job.organization) if job.organization_id
    end
    column 'Log' do |job|
      span link_to 'Slave Log', admin_job_slave_logs_path(job)
    end
  end
end
