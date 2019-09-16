# frozen_string_literal: true

class AccountWidget < Widget
  def initialize(vars = {})
    raise ArgumentError I18n.t('account_widgets.missing') unless vars[:account_id]

    super
  end

  def title
    I18n.t('account_widgets.title')
  end

  def border
    0
  end

  def account
    @account ||= Account.from_param(account_id).first
  end
  alias parent account

  def rank
    account.kudo_rank
  end

  def kudos
    account.kudos.length || 0
  end

  class << self
    def create_widgets(account_id)
      descendants.map { |widget| widget.new(account_id: account_id) }.sort_by(&:position)
    end
  end
end
