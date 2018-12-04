xml.response do
  xml.status('success')
  xml.items_returned @outside_committers.length
  xml.items_available @outside_committers.total_entries
  xml.first_item_position @outside_committers.offset
  xml.result do
    xml.outside_committers do
      @outside_committers.each do |outside_committer|
        projects = Project.where(id: outside_committer.projs) if outside_committer.projs.present?
        xml.contributor do
          xml.name outside_committer.name
          xml.kudos outside_committer.person.kudo_rank
          xml.level FOSSerBadge.new(outside_committer, positions_count: outside_committer.positions.count).level
          xml.affiliated_with outside_committer.organization.try(:name) || 'Unaffiliated'
          xml.contributions_to_portfolio_projects do
            xml.projects projects.map(&:name).join(', ')
            xml.twelve_mo_commits outside_committer.twelve_mo_commits
          end
        end
      end
      xml.detailed_page_url "/orgs/#{@organization.vanity_url}/outside_committers"
    end
  end
end
