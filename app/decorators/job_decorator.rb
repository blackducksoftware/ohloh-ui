class JobDecorator < Cherry::Decorator
  include ActionView::Helpers::DateHelper
  delegate :current_step, :max_steps, :current_step_at, :project, :account,
           :repository, :exception, :failed?, to: :object

  def tool_tip
    step_text + current_step_text + project_name + account_name + repository_text + exception_text
  end

  private

  def step_text
    "(#{current_step || '-'}/#{max_steps || '-'})"
  end

  def current_step_text
    current_step_at ? " (#{time_ago_in_words(current_step_at)})" : ''
  end

  def project_name
    project ? "\n#{project.name}" : ''
  end

  def account_name
    account ? "\n#{account.name}" : ''
  end

  def repository_text
    repository ? "\n#{repository.url} #{repository.module_name}" : ''
  end

  def exception_text
    failed? ? "\n\n#{exception}" : ''
  end
end
