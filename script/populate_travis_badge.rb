#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'
require 'open-uri'
require 'net/http'
require 'uri'

class String
  def string_between_markers(marker1, marker2)
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end
end

class PopulateTravis
  def initialize
    @repo_with_travis_badge = 0
    @total_badges_created = 0
  end

  def populate
    travis_fyles_of_best_code_sets.find_each do |fyle|
      repository = fyle.code_set.code_location.repository
      formatted_repo_url = ensure_proper_url_format(fyle.code_set.code_location)
      next unless formatted_repo_url

      travis_badge = extract_badge_image(formatted_repo_url)
      next unless travis_badge

      @repo_with_travis_badge += 1
      create_travis_badge(repository, travis_badge)
    end
    print_stat
  end

  def print_stat
    puts "repo_with_travis_badge: #{@repo_with_travis_badge}"
    puts "total_badges_created:  #{@total_badges_created}"
  end

  def ensure_proper_url_format(code_location)
    code_location.repository.url.gsub(/(git:\/\/|.git)/, 'git://' => 'http://', '.git' => '')
  end

  def extract_badge_image(repo_url)
    repo_page = Nokogiri::HTML(URI.parse(handle_url_redirect(repo_url)).open)
    return unless repo_page

    badge_url = repo_page.xpath('//img').collect { |a| a['data-canonical-src'] }
                         .uniq.compact
                         .select { |b| b.match('travis') }
    badge_url.first
  rescue StandardError
    nil
  end

  def handle_url_redirect(repo_url)
    res = Net::HTTP.get_response(URI(repo_url))
    res['location'] || repo_url
  end

  def create_travis_badge(repo, badge_url)
    manipulated_url = manipulate_badge_url(badge_url)
    repo.enlistments.each do |enlistment|
      next if enlistment.travis_badges.any?
      next unless enlistment.travis_badges.create(identifier: manipulated_url)

      puts "Succefully created badge: #{@total_badges_created += 1}"
    end
  end

  def manipulate_badge_url(badge_url)
    if badge_url.include? 'img.shields.io'
      map_shields_to_travis_url(badge_url)
    else
      badge_url.gsub!(/.*?(travis-ci.org\/)/, '')
    end
  end

  def travis_fyles_of_best_code_sets
    Fyle.includes(code_set: { best_code_location: :repository })
        .joins(code_set: { best_code_location: :repository })
        .where(name: '.travis.yml')
  end

  def map_shields_to_travis_url(badge_url)
    case badge_url.strip
    when /(.*)\/img.shields.io\/(travis|travis-ci)\/(.*)\/(.*)\.(svg|png)/
      total_attributes = $3.split('/').size
      total_attributes == 1 ? "#{$3}/#{$4}.#{$5}" : "#{$3}.#{$5}?branch=#{$4}"
    else
      badge_url
    end
  end
end

PopulateTravis.new.populate
