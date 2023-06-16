#! /usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/environment'

class DeleteProjectWithoutEnlistment
  def initialize; end

  def execute
    Project.active.includes(:enlistments).where(enlistments: { id: nil }).each do |p|
      p.editor_account = Account.hamster
      p.update!(deleted: true)
      puts "Deleted Project Successfully #{p.id}"
    end
  end
end

DeleteProjectWithoutEnlistment.new.execute
