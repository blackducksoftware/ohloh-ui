#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'
require 'logger'

class FixTruncatedLinks
  def initialize
    @log = Logger.new('log/fix_truncated_links.log')
  end

  def execute
    Link.joins(:project, :edits).where(deleted: false, projects: { deleted: false })
        .where("edits.key = 'url' and links.url != edits.value").uniq
        .find_each do |link|
      old_url = link.url
      link.url = get_valid_link_url(link)
      link.editor_account = Account.hamster
      next unless link.changed? && link.save

      log_details(old_url, link)

      enable_sync_to_kb(link.project_id)
    end
  end

  private

  def get_valid_link_url(link)
    link.edits.where(key: 'url').last.value
  end

  def enable_sync_to_kb(project_id)
    ActiveRecord::Base.connection
                      .execute("UPDATE knowledge_base_statuses SET in_sync=false WHERE project_id = #{project_id};")
  end

  def log_details(old_url, link)
    @log.info "Changed link(#{link.id}) url from #{old_url} to #{link.url}"
  end
end

FixTruncatedLinks.new.execute
