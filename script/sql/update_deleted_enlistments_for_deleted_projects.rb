#! /usr/bin/env ruby

raise 'RAILS_ENV is undefined' unless ENV['RAILS_ENV']

require_relative '../config/environment'

# update enlistments deleted field for all deleted projects
ActiveRecord::Base.connection.execute(
 "update enlistments set deleted = true
   from enlistments e
     inner join projects p on e.project_id = p.id
     where p.deleted and NOT e.deleted"
)

