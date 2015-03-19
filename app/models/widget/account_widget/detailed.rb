class AccountWidget::Detailed < AccountWidget
  def width
    AccountBadge::WIDTH
  end

  def height
    AccountBadge::HEIGHT
  end

  def image
    name = account.name || I18n.t('account_widgets.detailed.image_name')
    commits = account.best_vita.vita_fact.commits
    image = AccountBadge.create(kudo_rank: rank, name: name, kudos: kudos, commits: commits)
  end

  def position
    1
  end
end
