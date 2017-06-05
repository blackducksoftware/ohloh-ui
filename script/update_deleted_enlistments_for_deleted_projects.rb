#! /usr/bin/env ruby

raise 'RAILS_ENV is undefined' unless ENV['RAILS_ENV']

require_relative '../config/environment'
require 'logger'
$LOG = Logger.new('update_deleted_enlistments_log_file.log')

# update enlistments deleted field for all deleted projects
puts 'starting script'
editor = Account.find_by_login('ohloh_slave')
Project.where(deleted: true).find_in_batches do |projects|
  projects.each do |project|
    begin
      puts "Processing project #{project.id}"
      project.enlistments.each do |enlistment|
        enlistment.create_edit.undo!(editor) if enlistment.create_edit.allow_undo?
      end
    rescue Exception => e
      $LOG.error  "error: #{project.id} - #{e.inspect}"
    end
  end
end
puts 'Successfully completed script - Please check update_deleted_enlistments_log_file.log to view any exceptions'

