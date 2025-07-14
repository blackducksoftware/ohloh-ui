#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'
require 'csv'
require 'logger'

class InsertKbProjects
  def initialize(filename)
    @log = Logger.new('log/kbIngestion.log')
    @projects_csv = filename

    editor = Account.find_by(login: 'ohloh_slave')
    @project_builder = ProjectParamsBuilder.new(editor)
  end

  def run
    @log.info "Starting process with file #{@projects_csv}"
    loop_csv
    @log.info "Completed process with file #{@projects_csv}"
  end

  private

  def show_progress(index)
    @log.info "Processing row #{index}"
    DataDogReport.info '.' unless (index % 10).zero?
    DataDogReport.info index if (index % 10).zero?
    Rails.logger.info('.') unless (index % 10).zero?
  end

  def create_project(row)
    @project_builder.row = row
    @project_builder.build_project
    @log.info @project_builder.messages
  end

  def loop_csv
    CSV.foreach(@projects_csv, headers: true).with_index(1) do |csv, index|
      show_progress(index)
      row = csv.to_h
      create_project(row)
    rescue StandardError => e
      @log.error "Error processing row #{index} with error #{e.message}"
    end
  end
end

class NoLicense
  def id
    0
  end
end

def check_params
  return unless ARGV.empty?

  DataDogReport.info 'Missing csv location and file name eg. tmp/test.csv'
  # exit removed for Rails best practices
end

DataDogReport.info 'starting script'
check_params
file_name = ARGV[0]
InsertKbProjects.new(file_name).run
DataDogReport.info 'script complete'
