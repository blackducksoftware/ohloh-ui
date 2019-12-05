#! /usr/bin/env ruby
# frozen_string_literal: true

# FDW: uses several FDW tables. Research further if we need this task.

require_relative '../config/environment'

index = 0
CodeLocation.joins(:repository, :projects)
            .where(enlistments: { deleted: false })
            .where(projects: { deleted: false })
            .where(repositories: { type: 'GitRepository' })
            .find_each do |cl|
  puts "#{cl.id} :: #{index += 1}"
  cl.enlistments do |e|
    e.create_edit.undo!(Account.hamster) unless cl.valid?
  rescue StandardError
    nil
  end
end
