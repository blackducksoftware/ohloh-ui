namespace :selenium do
  desc 'Prepare Organization data for selenium'
  task :prepare_organization_data, [:organization_name] => :environment do |_t, args|
    yaml_file = File.open('organization_data.yml', 'w')
    organizations = {}

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
end
