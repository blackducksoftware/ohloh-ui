# frozen_string_literal: true

class Widget::AccountWidget::Detailed < Widget::AccountWidget
  def width
    230
  end

  def height
    35
  end

  def image
    name = account.name || I18n.t('account_widgets.account_detailed.image_name')
    commits = account.best_account_analysis.account_analysis_fact.commits
    WidgetBadge::Account.create(kudo_rank: rank, name: name, kudos: kudos, commits: commits)
  end

  def position
    1
  end
end
