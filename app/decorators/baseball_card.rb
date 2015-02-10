class BaseballCard < Draper::Decorator
  ROW_NAMES = [:first_checkin, :last_checkin, :commits, :joined_at, :contributions, :orgs, :affiliations]

  decorates :account
  delegate_all

  def initialize(*args)
    super
    @vita_fact = best_vita.vita_fact
    @organization_core = Account::OrganizationCore.new(object.id)
  end

  def rows
    ROW_NAMES.map { |row| send(row) }.compact.map { |row| row.reverse_merge(css: {}) }
  end

  private

  def first_checkin
    return unless @vita_fact.first_checkin
    { label: h.t('.first_checkin'),
      value: h.t('.duration', date: h.distance_of_time_in_words_to_now(@vita_fact.first_checkin)) }
  end

  def last_checkin
    return unless @vita_fact.last_checkin
    { label: h.t('.last_checkin'),
      value: h.t('.duration', date: h.distance_of_time_in_words_to_now(@vita_fact.last_checkin)) }
  end

  def commits
    return if best_vita.nil?
    { label: h.t('.commits.label'),
      value: h.t('.commits.value', count: @vita_fact.commits) }
  end

  def joined_at
    { label: h.t('.joined_at'),
      value: h.t('.duration', date: h.distance_of_time_in_words_to_now(created_at)) }
  end

  def contributions
    return if positions.count == 0
    link = h.link_to h.pluralize(positions.count, 'project'), h.account_positions_path(object)
    { label: h.t('.contribution'),
      value: link }
  end

  def orgs
    orgs_for_positions = @organization_core.orgs_for_my_positions
    return if orgs_for_positions.empty?
    { css: { style: 'min-height:38px;' },
      label: h.t('.contibuted_to'),
      value: h.render(partial: 'accounts/show/orgs', locals: { orgs: orgs_for_positions }) }
  end

  def affiliations
    affiliated_orgs = @organization_core.affiliations_for_my_positions
    return if affiliated_orgs.empty?
    { css: { style: 'min-height:38px;' },
      label: h.t('.contibuted_for'),
      value: h.render(partial: 'accounts/show/orgs', locals: { orgs: affiliated_orgs }) }
  end
end
