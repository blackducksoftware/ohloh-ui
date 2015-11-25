require 'open3'
require 'socket'

class Slave < ActiveRecord::Base
  has_many :jobs

  # all these methods below can be removed after removing clumps
  def run_local_or_remote(cmd)
    local? ? run(cmd) : "ssh #{hostname} '#{cmd}'"
  end

  def path_from_code_set_id(code_set_id)
    return unless code_set_id
    j = code_set_id.to_s.rjust(12, '0')
    "#{clump_dir}/#{j[0..2]}/#{j[3..5]}/#{j[6..8]}/#{j[9..-1]}"
  end

  private

  def run(cmd)
    _stdin, stdout, stderr = Open3.popen3('bash', '-c', cmd)
    fail "#{ cmd } failed: #{ stderr.read }" if stderr.any?
    stdout.read
  end

  def local?
    hostname == Socket.gethostname
  end
end
