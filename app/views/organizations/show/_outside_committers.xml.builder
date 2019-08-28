# frozen_string_literal: true

xml = xml_instance

xml.outside_committers do
  @accounts.each do |acc|
    xml.contributor do
      xml.name acc.name
      xml.kudos acc.person.kudo_rank
      xml.level FOSSerBadge.new(acc, positions_count: acc.positions.count).level
      xml.affiliated_with(acc.organization.try(:name) || 'Unaffiliated')
      xml.contributions_to_portfolio_projects do
        xml.projects acc.projects.map(&:name).join(', ')
        xml.twelve_mo_commits acc.twelve_mo_commits
      end
    end
  end
  xml.detailed_page_url "/orgs/#{org.vanity_url}/outside_committers"
end
