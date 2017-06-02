#! /usr/bin/env ruby

raise 'RAILS_ENV is undefined' unless ENV['RAILS_ENV']

require_relative '../config/environment'

# update enlistments deleted field for all deleted projects
puts 'starting script'
editor = Account.find_by_login('ohloh_slave')
Project.where(deleted: true).find_in_batches do |projects|
  projects.each do |project|
    project.enlistments.each do |enlistment|
      enlistment.create_edit.undo!(editor) if enlistment.create_edit.allow_undo?
    end
    puts 'finished updating enlistments'
  end
  puts 'finished script'
end


