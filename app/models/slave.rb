# frozen_string_literal: true

require 'open3'
require 'socket'

class Slave < FisBase
  has_many :jobs
  has_many :running_jobs, -> { slave_recent_jobs.running }, class_name: 'Job'
  has_many :failed_jobs, -> { slave_recent_jobs.failed }, class_name: 'Job'

  # all these methods below can be removed after removing clumps
  def run_local_or_remote(cmd)
    local? ? run(cmd) : "ssh #{hostname} '#{cmd}'"
  end

  def path_from_code_set_id(code_set_id)
    return unless code_set_id

    j = code_set_id.to_s.rjust(12, '0')
    "#{clump_dir}/#{j[0..2]}/#{j[3..5]}/#{j[6..8]}/#{j[9..]}"
  end

  def allow?
    allow_deny.to_s.casecmp('allow').zero?
  end

  def deny?
    allow_deny.to_s.casecmp('deny').zero?
  end

  private

  def run(cmd)
    _stdin, stdout, stderr = Open3.popen3('bash', '-c', cmd)
    raise "#{cmd} failed: #{stderr.read}" if stderr.any?

    stdout.read
  end

  def local?
    hostname == Socket.gethostname
  end
end
