# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

class KnowledgeBaseStatus < ActiveRecord::Base
  belongs_to :project

  scope :items_to_sync, -> { where(in_sync: false).order(:updated_at) }

  class << self
    def enable_sync!(*p_ids)
      p_ids.flatten.each do |project_id|
        kbs = where(project_id: project_id).first_or_initialize
        kbs.in_sync = false
        kbs.save
      end
    end
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def json_message
    message_hash = {
      ohloh_id: project_id,
      deleted: project.deleted?,
      ohloh_url: "https://www.openhub.net/p/#{project_id}",
      name: project.name,
      created_at: project.created_at.iso8601,
      updated_at: project.updated_at.iso8601,
      description: project.description,
      url_name: project.vanity_url,
      vanity_url: project.vanity_url,
      user_count: project.user_count,
      rating_average: project.rating_average,
      rating_count: project.ratings.count,
      review_count: project.reviews.count,
      tags: get_tags,
      logo: get_logo,
      enlistments: get_enlistments,
      links: get_links,
      licenses: get_licenses,
      best_analysis: get_best_analysis,
      organization: get_organization,

      project_activity_index: Analysis::ACTIVITY_LEVEL_INDEX_MAP[project.best_analysis.activity_level],
      project_activity_description: ProjectsController.helpers.project_activity_text(project, true)
    }
    message_hash[:forge] = get_forge_match(project.forge_match) if project.forge_match
    message_hash.to_json
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  private

  def get_tags
    logger.info("Converting #{project.name} - getting tags")
    return [] if project.tag_list.empty?

    project.tag_list.split
  end

  def get_logo
    logger.info("Converting #{project.name} - getting logo")
    logo_hash = {}
    logo = project.logo

    if logo
      logo_hash.merge!(id: logo.id, filename: logo.filename, content_type: logo.content_type)
      logo_hash[:urls] = [{ type: 'medium', url: logo.attachment.url(:med) },
                          { type: 'small', url: logo.attachment.url(:small) }]
    end
    logo_hash
  end

  def get_enlistments
    logger.info("Converting #{project.name} - getting enlistments")
    enlistments = []
    project.enlistments.each do |enlistment|
      enlistments << enlistment_hash(enlistment)
    end
    enlistments
  end

  def get_links
    logger.info("Converting #{project.name} - getting links")
    llist = []
    project.links.each do |link|
      llist << { id: link.id, title: link.title, category: link.category, url: link.url }
    end
    llist
  end

  def get_licenses
    logger.info("Converting #{project.name} - getting licenses")
    llist = []
    project.licenses.each do |license|
      llist << { id: license.id, name: license.name, vanity_url: license.vanity_url }
    end
    llist
  end

  # rubocop:disable Metrics/AbcSize
  def enlistment_hash(enlistment)
    el_hash = { enlistment_id: enlistment.id, repository_id: get_repository_id(enlistment.code_location_id),
                code_location_id: enlistment.code_location_id,
                type: enlistment.code_location.scm_type.titleize + 'Repository', url: enlistment.code_location.url,
                module_branch_name: enlistment.code_location.branch,
                user_name: enlistment.code_location.username, password: enlistment.code_location.password }
    forge_match = Forge::Match.first(enlistment.code_location.url)
    el_hash[:forge] = get_forge_match(forge_match) if forge_match
    el_hash
  end

  def get_best_analysis
    logger.info("Converting #{project.name} - getting best_analysis")
    analysis = project.best_analysis
    return {} if analysis.blank?

    ba = { updated_on: analysis.updated_on, logged_at: analysis.oldest_code_set_time,
           factoids: get_factoids(analysis), language_breakdown: analysis.language_breakdown }
    ba.merge!(analysis_commit_data(analysis))
    ba.merge!(analysis_committer_data(analysis))
    ba[:main_language] = analysis_main_language_details(analysis)
    ba[:commit_count_12mo] = analysis.twelve_month_summary.commits_count if analysis.twelve_month_summary
    ba
  end
  # rubocop:enable Metrics/AbcSize

  def analysis_main_language_details(analysis)
    { name: analysis.main_language.name,
      nice_name: analysis.main_language.nice_name,
      category: analysis.main_language.category }
  end

  def analysis_commit_data(analysis)
    {
      first_commit_time: analysis.first_commit_time,
      last_commit_time: analysis.last_commit_time,
      commit_count_all_time: analysis.commit_count,
      lines_of_code: analysis.code_total,
      commit_activity: get_commit_activity(analysis)
    }
  end

  def analysis_committer_data(analysis)
    { committer_count_12mo: analysis.headcount,
      committer_count_all_time: analysis.committers_all_time,
      contributor_activity: get_contributor_activity(analysis) }
  end

  def get_repository_id(code_location_id)
    SecondBase::Base.connection
                    .execute("select repository_id from code_locations where id= #{code_location_id}")
                    .values[0].try(:first).to_i
  end

  def get_forge_match(forge_match)
    logger.info('Converting - getting forge_match')

    { forge_id: forge_match.forge.id, forge_name: forge_match.forge.name,
      owner_at_forge: forge_match.owner_at_forge,
      name_at_forge: forge_match.name_at_forge }
  end

  def get_factoids(analysis)
    logger.info('Converting - getting factoids')
    facts = {}
    fact_types = [FactoidAge, FactoidTeamSize, FactoidActivity]
    fact_types.each do |fact_type|
      fact = analysis.factoids.select { |f| f if f.is_a? fact_type }
      facts[fact_type.name.underscore] = fact.first.type if fact&.any?
    end
    facts
  end

  def get_contributor_activity(analysis)
    logger.info('Converting - getting contributor_activity')
    start_date = analysis.first_commit_time.strftime('%Y-%m-01')
    end_date = analysis.updated_on.strftime('%Y-%m-01')

    { frequency: 'monthly',
      data: analysis.contributor_history(start_date, end_date).map do |e|
        e['contributors'] = e['contributors'].to_i
        e
      end }
  end

  def get_commit_activity(analysis)
    logger.info('Converting - getting commit_activity')
    start_date = analysis.first_commit_time.strftime('%Y-%m-01')
    end_date = analysis.updated_on.strftime('%Y-%m-01')

    { frequency: 'monthly',
      data: analysis.commit_history(start_date, end_date).map do |e|
        e['commits'] = e['commits'].to_i
        e
      end }
  end

  def get_organization
    return unless project.organization

    org_hash = {}
    Organization::KB_SYNC_ATTRS.map { |attr| org_hash[attr] = project.organization.send(attr) }
    org_hash['url'] = "https://www.openhub.net/orgs/#{project.organization.id}"
    org_hash
  end
end
# rubocop:enable Metrics/ClassLength
