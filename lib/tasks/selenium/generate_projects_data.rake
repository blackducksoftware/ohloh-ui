# frozen_string_literal: true

# Usage:
# rake selenium:prepare_projects_data[firefox]
# FDW: uses several FDW tables. Research further if we need this task.

require 'action_view'

namespace :selenium do
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper

  desc 'Prepare Projects data for selenium'
  task :prepare_projects_data, [:project_name] => :environment do |_t, args|
    include AnalysesHelper
    include ProjectsHelper
    include EmailObfuscation
    include ProjectVulnerabilityReportsHelper
    yaml_file = File.open('projects_data.yml', 'w')
    projects = {}

    args[:project_name].split(' ').each do |project_name|
      project = Project.from_param(project_name).take
      if project.blank?
        puts "Project[#{project_name}] does not exist"
        next
      end

      analysis = project.best_analysis
      languages_percentage = Analysis::LanguagePercentages.new(analysis).collection
      languages_breakdown = Analysis::LanguagesBreakdown.new(analysis: analysis).collection
      total_lines = analysis_total_lines(languages_breakdown)
      code_lines = analysis_total_detail(languages_breakdown, 'code_total')
      comment_lines = analysis_total_detail(languages_breakdown, 'comments_total')
      blank_lines = analysis_total_detail(languages_breakdown, 'blanks_total')
      pvr = project.project_vulnerability_report

      project_data = project.attributes.except('vector', 'popularity_factor')
      project_data.merge!(
        'pai' => get_pai_values,
        'hot_projects' => get_hot_projects,
        'i_use_this' => number_with_delimiter(project.user_count),
        'description' => project.description.squish,
        'organization_name' => project.organization.try(:name),
        'tags' => project.tags.order(:name).map(&:name),
        'links' => project.links.collect { |v| [v.category, v.title, v.url] }.group_by(&:first),
        'code_location_count' => project.enlistments.size,
        'licenses' => project.licenses.pluck(:abbreviation, :name),
        'managers' => project.managers.map(&:name),
        'activity_text' => project_activity_text(project, true),
        'permission' => project.permission.try(:remainder) ? 'Mangers Only' : 'Everyone'
      )

      if analysis.present?
        project_data.merge!(
          'main_language' => analysis.main_language.nice_name,
          'activity' => {
            '30_day_summary' => thirty_day_summary(analysis),
            '12_month_summary' => twelve_month_summary(analysis)
          },
          'recent_contributors' => analysis.all_time_summary.recent_contribution_persons.map(&:effective_name),
          'commits' => get_commits_stats(analysis).merge!('list' => get_commits(project)),
          'total_lines_of_code' => number_with_delimiter(analysis.logic_total)
        )
      end

      if pvr.present?
        project_data['pss'] = pss_content(pvr)
        project_data['pvs'] = pvs_content(pvr)
      end

      project_data.merge!(
        'community' => { 'user_count' => project.ratings.count, 'rating_avg' => project.rating_average.to_f.round(1) },
        'similar_projects_by_tag' => collect_license_and_languages(project.related_by_tags(10)),
        'similar_projects_by_stack' => collect_license_and_languages(project.related_by_stacks(10))
      )

      if analysis.present?
        project_data['languages'] = {
          'summary' => languages_percentage.collect { |v| [v.second, v.third[:percent]] },
          'total_lines' => number_with_delimiter(total_lines),
          'code_lines' => number_with_delimiter(code_lines),
          'percentage_lines' => analysis_total_percent_detail(code_lines, total_lines),
          'total_languages' => languages_breakdown.size,
          'total_comments' => number_with_delimiter(comment_lines),
          'percentage_comments' => analysis_total_percent_detail(comment_lines, total_lines),
          'total_blanks' => number_with_delimiter(blank_lines),
          'percentage_blanks' => analysis_total_percent_detail(blank_lines, total_lines),
          'list' => get_language_stats(languages_breakdown)
        }
      end

      project_data['contributors'] = {
        'newest_contributions' => newest_contributions(project),
        'top_contributions' => project.top_contributions.collect do |contribution|
          fact = contribution.contributor_fact
          [contribution.person.person_name, fact.twelve_month_commits,
           fact.commits, fact.primary_language.nice_name, time_ago_in_words(fact.first_checkin) + ' ago',
           time_ago_in_words(fact.last_checkin) + ' ago']
        end
      }

      project_data.merge!(
        'users' => get_users(project),
        'reviews_count' => project.reviews.count,
        'reviews' => get_reviews(project),
        'rss_feeds' => project.rss_subscriptions.collect { |v| v.rss_feed.url },
        'rss_articles' => project.rss_articles.first(10).map(&:title),
        'enlistments' => get_enlistments(project),
        'aliases' => get_aliases(project),
        'new_alias' => get_new_alias(project),
        'new_license' => License.where.not(id: project.licenses.ids).limit(1).pluck(:name, :abbreviation).flatten,
        'new_tag' => Tag.where.not(id: project.tags).first.name
      )

      projects[project.vanity_url] = project_data
    end
    yaml_file.puts YAML.dump('projects' => projects)
  end

  def twelve_month_summary(analysis)
    { 'date' => "#{pretty_date(analysis.oldest_code_set_time - 12.months)} -
                  #{pretty_date(analysis.oldest_code_set_time)}",
      'commits' => analysis.twelve_month_summary.commits_count,
      'previous_commits' => previous_12_month_summary(analysis.previous_twelve_month_summary,
                                                      'commits_difference', 'commits_count'),
      'contributors' => analysis.twelve_month_summary.committer_count,
      'previous_contributors' => previous_12_month_summary(analysis.previous_twelve_month_summary,
                                                           'committers_difference', 'committer_count') }
  end

  def thirty_day_summary(analysis)
    { 'date' => "#{pretty_date(analysis.oldest_code_set_time - 30.days)} -
                  #{pretty_date(analysis.oldest_code_set_time)}",
      'commits' => analysis.thirty_day_summary.commits_count,
      'contributors' => analysis.thirty_day_summary.committer_count,
      'new_contributors' => analysis.thirty_day_summary.new_contributors_count }
  end

  def newest_contributions(project)
    project.newest_contributions.collect do |contribution|
      [contribution.person.try(:person_name), contribution.contributor_fact.commits,
       time_ago_in_words(contribution.contributor_fact.first_checkin) + ' ago']
    end
  end

  def get_language_stats(languages_breakdown)
    languages_breakdown.collect do |l|
      [l.language_nice_name, number_with_delimiter(l.code_total), number_with_delimiter(l.comments_total),
       comments_ratio_from_lanaguage_breakdown(l), number_with_delimiter(l.blanks_total),
       number_with_delimiter(total_code(l)), total_percent(languages_breakdown, l)]
    end
  end

  def total_code(language)
    language.code_total + language.comments_total + language.blanks_total
  end

  def get_users(project)
    project.users.first(30).collect do |user|
      contribution_count = user.person.decorate.contributions.count
      [user.name, get_contributions(user), contribution_count > 3 ? contribution_count - 3 : nil]
    end
  end

  def get_contributions(user)
    user.person.decorate.contributions.first(3).collect do |c|
      "Contributes to #{c.project.name}#{get_committer_name(c.committer_name, user.person.effective_name)}"
    end
  end

  def get_committer_name(committer_name, effective_name)
    " as #{obfuscate_email(committer_name)}" if committer_name != effective_name
  end

  def pretty_date(date)
    date.strftime('%b %e %Y')
  end

  def previous_12_month_summary(summary, diff, count)
    return 'This project is less than 12 months old.' unless summary.data?

    commits_diff = summary.send(diff)
    commits_count = summary.send(count)
    str = (commits_diff.positive? ? 'Up + ' : 'Down ') + commits_diff.to_s
    str += calc_percentage(commits_diff, commits_count).to_s
    str.concat(' from previous 12 months')
  end

  def calc_percentage(commits_diff, commits_count)
    " (#{(commits_diff.abs.fdiv(commits_count.abs) * 100).floor}%)" if commits_count.positive?
  end

  def get_commits_stats(analysis)
    all_time_summary = analysis.all_time_summary || NilAnalysisSummaryWithNa.new
    twelve_month_summary = analysis.twelve_month_summary || NilAnalysisSummaryWithNa.new
    thirty_day_summary = analysis.thirty_day_summary || NilAnalysisSummaryWithNa.new

    commits_summary = [all_time_summary, twelve_month_summary, thirty_day_summary]
    %w[commits_count committer_count files_modified lines_added lines_removed].each_with_object({}) do |key, hsh|
      hsh[key] = commits_summary.map(&key.to_sym)
    end
  end

  def get_commits(project)
    analysis = project.best_analysis
    code_set_id = project.analysis_sloc_sets.joins(sloc_set: :code_set).pluck('code_sets.id').last
    commits = Commit.joins(:analysis_aliases).where(code_set_id: code_set_id)
                    .where(analysis_aliases: { analysis_id: analysis.id }).order(time: :desc).first(60)

    commits.collect do |commit|
      get_commit_data(commit, analysis)
    end
  end

  def get_commit_data(commit, analysis)
    [get_email(commit.comment), get_email(get_commit_contributor(commit, analysis).try(:person)),
     commit.diffs.count, commit.lines_added_and_removed(analysis.id),
     commit.code_set.repository.url].flatten
  end

  def get_commit_contributor(commit, analysis)
    CommitContributor.where(analysis_id: analysis.id, name_id: commit.name_id).first
  end

  def get_email(attr)
    obfuscate_email(attr).split("\n").first
  end

  def get_reviews(project)
    %w[helpful recently_added highest_rated lowest_rated].each_with_object({}) do |sort_by, hsh|
      hsh[sort_by] = project.reviews.sort_by(sort_by).map(&:title).first(20)
    end.merge!('most_helpful' => project.reviews.top.map(&:title).first(20))
  end

  def get_enlistments(project)
    %w[by_url by_project by_type].each_with_object({}) do |sort_by, hsh|
      hsh[sort_by] = project.enlistments.includes(:project, :repository).send(sort_by).first(20).collect do |e|
        [e.code_location.nice_url, e.repository.name_in_english, CodeLocationJobProgress.new(e).message]
      end
    end
  end

  def get_new_alias(project)
    committer_name = Alias.committer_names(project).take
    return if committer_name.nil?

    [committer_name.name, Alias.preferred_names(project, committer_name).take.name]
  end

  def get_aliases(project)
    best_analysis_aliases = Alias.best_analysis_aliases(project).pluck(:commit_name_id, :preferred_name_id)
    project.aliases.includes(:commit_name, :preferred_name).collect do |alias_obj|
      [alias_obj.commit_name.name, alias_obj.preferred_name.name,
       best_analysis_aliases.include?([alias_obj.commit_name_id, alias_obj.preferred_name_id])]
    end
  end

  def get_pai_values
    project_activity_index = Project.group(:activity_level_index).with_pai_available
    total_count = project_activity_index.values.sum
    project_activity_index.each_with_object({}) do |data, hsh|
      hsh[Project::ACTIVITY_LEVEL.invert[data.first]] = "#{(data.second.fdiv(total_count) * 100).round(1)} %"
    end
  end

  def get_hot_projects
    Project.hot.limit(10).collect do |project|
      [project.name.to_s.truncate(26), project.organization.try(:name).to_s.truncate(30),
       project_activity_text(project, true), project.best_analysis.angle.round(3)]
    end
  end

  def collect_license_and_languages(projects)
    projects.each_with_object({}) do |p, hsh|
      hsh[p.name] = {
        'licenses' => p.licenses.map(&:abbreviation), 'language' => p.best_analysis.main_language.try(:nice_name),
        'tags' => p.tags.order(:name).map(&:name), 'activity_text' => project_activity_text(p, true)
      }
    end
  end
end
