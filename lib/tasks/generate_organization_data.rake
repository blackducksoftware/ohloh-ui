namespace :selenium do
  desc 'Prepare Organization data for selenium'
  task :prepare_organization_data, [:organization_name] => :environment do |_t, args|
    yaml_file = File.open('organization_data.yml', 'w')
    organizations = {}

    # Organization explore page data
    organizations.merge!(
      'most_active_orgs' => OrgThirtyDayActivity.most_active_orgs
        .collect { |o| [o.organization.name, o.commits_per_affiliate] },
      'newest_orgs' => Organization.active.order(created_at: :desc).limit(3).pluck(:name, :projects_count),
      'stats_by_sector' => OrgStatsBySector.recent
        .collect { |o| [Organization::ORG_TYPES.key(o.org_type), o.average_commits, o.organization_count] },
      '30_day_commmits' => collect_30_days_commit_volume
    )

    # Organization show page data
    args[:organization_name].split(' ').each do |org_name|
      org = Organization.from_param(org_name).take
      if org.blank?
        puts "Organization[#{org_name}] does not exist"
        next
      end

      organization = org.attributes.except('vector', 'popularity_factor')
      managers = org.managers.pluck(:name)

      organization.merge!(
        'org_type' => Organization::ORG_TYPES.key(org.org_type),
        'manager' => { 'names' => managers, 'count' => managers.count },
        'portfolio_count' => org.projects_count,
        'affiliated_committers_count' => org.affiliators_count,
        'outside_committers_stats' => org.outside_committers_stats,
        'outside_projects_stats' => org.affiliated_committers_stats
      )

      organization.merge!(
        'widgets' => {
          'open_source_activity' => {
            'affiliates' => org.affiliators_count,
            'commits' => org.affiliated_committers_stats['affl_commits_out'].to_i +
                         org.affiliated_committers_stats['affl_commits'].to_i,
            'projects' => org.projects.count + org.affiliated_committers_stats['affl_projects_out'].to_i
          },
          'portfolio_activity' => {
            'people' => org.affiliated_committers_stats['affl_committers'].to_i +
                        org.outside_committers_stats['out_committers'].to_i,
            'commits' => org.affiliated_committers_stats['affl_commits'].to_i +
                         org.outside_committers_stats['out_commits'].to_i,
            'projects' => org.projects.count
          },
          'affiliated_activity' => {
            'affiliates' => org.affiliators_count,
            'commits' => org.affiliated_committers_stats['affl_commits'].to_i,
            'projects' => org.projects.count
          }
        }
      )

      organizations[org.url_name] = organization
    end
    yaml_file.puts YAML.dump('organizations' => organizations)
  end

  def collect_30_days_commit_volume
    {}.tap do |org_by_sector|
      OrgThirtyDayActivity::FILTER_TYPES.keys.each do |key|
        org_by_sector[key.to_s] = OrgThirtyDayActivity.filter(key).collect do |o|
          [o.name, o.organization.projects_count, o.affiliate_count, o.thirty_day_commit_count]
        end
      end
    end
  end
end
