class AccountWidget::Detailed < AccountWidget
  def width
    230
  end

  def height
    35
  end

  # TODO: Impement after taking care of mini_magick
  def image
    # name = account.name || I18n.t('account_widgets.detailed.image_name')
    # commits = account.best_vita.vita_fact.commits
    # image = AccountBadge.create(kudo_rank: rank, name: name, kudos: kudos, commits: commits)
  end

  def position
    1
  end
end
