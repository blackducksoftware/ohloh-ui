module OrganizationsHelper
  def org_pretty_display(value)
    return 'N/A' if value.blank?
    return '&mdash;'.html_safe if value.to_i.zero?
    value
  end

  def org_ticker_markup(diff, previous, klass = nil)
    haml_tag :span, class: "delta #{ diff > 0 ? 'good' : 'bad' } #{klass}" do
      percentage = diff.abs.to_f / previous.abs.to_f * 100
      concat "#{'+' if diff > 0}#{diff}"
      concat " (#{percentage.floor}%)" if previous > 0
    end
  end
end
