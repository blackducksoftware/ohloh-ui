# frozen_string_literal: true

# Usage:
# rake selenium:prepare_organization_data[mozilla]

require 'action_view'

namespace :selenium do
  include ActionView::Helpers::NumberHelper

  desc 'Prepare Organization data for selenium'
  task :prepare_organization_data, [:organization_name] => :environment do |_t, args|
    yaml_file = File.open('organization_data.yml', 'w')
    organizations = {}

    # Organization explore page data
    organizations.merge!(
      'most_active_orgs' => OrgThirtyDayActivity.most_active_orgs
      .collect { |o| [o.organization.name.truncate(24), o.commits_per_affiliate] },
      'most_active_last_calc' => time_ago_in_words(OrgThirtyDayActivity.most_active_orgs.first.created_at) + ' ago',
      'newest_orgs' => Organization.active.order(created_at: :desc).limit(3)
      .collect { |o| [o.name.truncate(24), o.projects_count, time_ago_in_words(o.updated_at) + ' ago'] },
      'stats_by_sector' => OrgStatsBySector.recent
        .collect { |o| [get_org_type(o), o.average_commits, o.organization_count] },
      '30_day_commmits' => collect_30_days_commit_volume
    )

    # Organization show page data
    args[:organization_name].to_s.split(' ').each do |org_name|
      org = Organization.from_param(org_name).take
      if org.blank?
        puts "Organization[#{org_name}] does not exist"
        next
      end

      organization = org.attributes.except('vector', 'popularity_factor')
      managers = org.managers.order(name: :desc).map(&:name)

      organization.merge!(
        'org_type' => get_org_type(org),
        'manager' => { 'names' => managers, 'count' => managers.count },
        'portfolio_count' => org.projects_count,
        'affiliated_committers_count' => org.affiliators_count,
        'outside_committers_stats' => org.outside_committers_stats,
        'outside_projects_stats' => org.affiliated_committers_stats,
        'claim_this_project' => Project.where.not(id: org.projects.ids).take.name
      )

      organization['widgets'] = {
        'open_source_activity' => {
          'affiliates' => number_with_delimiter(org.affiliators_count),
          'commits' => number_with_delimiter(org.affiliated_committers_stats['affl_commits_out'].to_i +
                       org.affiliated_committers_stats['affl_commits'].to_i),
          'projects' => number_with_delimiter(org.projects.count +
                        org.affiliated_committers_stats['affl_projects_out'].to_i)
        },
        'portfolio_activity' => {
          'people' => number_with_delimiter(org.affiliated_committers_stats['affl_committers'].to_i +
                      org.outside_committers_stats['out_committers'].to_i),
          'commits' => number_with_delimiter(org.affiliated_committers_stats['affl_commits'].to_i +
                       org.outside_committers_stats['out_commits'].to_i),
          'projects' => number_with_delimiter(org.projects.count)
        },
        'affiliated_activity' => {
          'affiliates' => number_with_delimiter(org.affiliators_count),
          'commits' => number_with_delimiter(org.affiliated_committers_stats['affl_commits'].to_i),
          'projects' => number_with_delimiter(org.projects.count)
        }
      }

      organizations[org.vanity_url] = organization
    end
    yaml_file.puts YAML.dump('organizations' => organizations)
  end

  def collect_30_days_commit_volume
    {}.tap do |org_by_sector|
      OrgThirtyDayActivity::FILTER_TYPES.keys.each do |key|
        org_by_sector[key.to_s] = OrgThirtyDayActivity.filter(key).collect do |o|
          [o.name.truncate(14), get_org_type(o), o.organization.projects_count,
           o.affiliate_count, o.thirty_day_commit_count]
        end
      end
    end
  end

  def get_org_type(organization)
    Organization::ORG_TYPES.key(organization.org_type)
  end
end
