module JobApiHelper
  def current_step_at(step_at)
    step_at.to_datetime.strftime('%B %d, %Y %H:%M') if step_at
  end

  def last_updated(updated_at)
    time_ago_in_words(updated_at.to_datetime) if updated_at
  end

  def status_tag(status)
    case status
    when Job::STATUS_SCHEDULED  then ['scheduled', 'label-warning']
    when Job::STATUS_RUNNING    then ['running',   'label-primary']
    when Job::STATUS_FAILED     then ['failed',    'label-danger']
    when Job::STATUS_COMPLETED  then ['completed', 'label-success']
    end
  end

  def slave_host(slave_id)
    return unless slave_id
    "on #{link_to Slave.find(slave_id).hostname, admin_slafe_path(id: slave_id)}".html_safe
  end

  def job_progress(job)
    return unless [1, 3, 5].include?(job['status'])
    if job['status'] == 1
      css = ['progress progress-xs progress-striped active', 'progress-bar progress-bar-success']
    elsif job['status'] == 3
      css = ['progress progress-xs', 'progress-bar progress-bar-danger']
    elsif job['status'] == 5
      css = ['progress progress-xs', 'progress-bar progress-bar-success']
    end
    show_job_progress(job, css)
  end

  def show_job_progress(job, css)
    percent = percentage_completed(job)
    haml_tag(:div, class: css[0]) do
      haml_tag(:div, class: css[1], style: "width: #{percent}%") do
      end
    end
  end

  def percentage_completed(job)
    return unless job['current_step']
    ((job['current_step'].to_f / job['max_steps'].to_f) * 100).round
  end

  def step_message(job)
    return unless job['current_step']
    "Step #{job['current_step']} of #{job['max_steps']}"
  end
end
