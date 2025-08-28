#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

index = 0
CodeLocation.joins(:repository, :projects)
            .where(enlistments: { deleted: false })
            .where(projects: { deleted: false })
            .where(repositories: { type: 'GitRepository' })
            .find_each do |cl|
  DataDogReport.info("#{cl.id} :: #{index += 1}")
  cl.enlistments do |e|
    e.create_edit.undo!(Account.hamster) unless cl.valid?
  rescue StandardError
    nil
  end
end
