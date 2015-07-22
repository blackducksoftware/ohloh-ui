# An add-on to the Daemonize found in vendor/daemonize-0.1.2
# this adds start and stop
#      start() requires a run! to be implemented
#      run! shall call daemonize and then store_pid
# it also adds functions which handle creating and destroying pidfiles
# these functions will bust the pidfile lock if the process is missing
module Daemonize
  module DaemonPidfiles
    # where should we store our pidfiles?
    def pid_directory
      preferred = "/var/run/openhub"
      File.directory?(preferred) ? preferred : File.dirname(__FILE__)
    end

    def initialize
      super
      @environment_file = File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
    end

    def require_rails_env
      require @environment_file
    end

    # override this
    def pid_filename
      File.join(pid_directory, 'generic_daemon.pid')
    end

    def store_pid
      File.open(pid_filename, 'w') {|f| f << Process.pid}
    end

    def recall_pid
      IO.read(pid_filename).to_i rescue nil
    end

    def rm_pidfile
      require 'fileutils'
      FileUtils.rm(pid_filename)
    end

    def processes
      processes = `ps x`.split("\n").collect {|proc| proc.match(/^\s*[0-9]+/)}.compact.collect{|match| match[0].to_i}
    end

    def running?
      unless File.file?(pid_filename)
        return false
      end
      if processes.include? recall_pid
        return true
      else
        STDOUT.puts "#{processes.join(", ")} does not include #{recall_pid}; deleting stale pidfile and starting daemon"
        STDERR.puts "#{self.class} pid_file exists, but process isn't running: deleting stale pidfile."
        rm_pidfile
        return false
      end
    end

    def start
      if running?
        STDERR.puts "#{self.class} already running."
        exit 1
      else
        STDERR.puts "Starting #{self.class}"
        STDOUT.puts "Starting #{self.class} at #{Time.now}."
        run!
      end
      exit 0
    end

    def stop
      if File.file?(pid_filename)
        begin
          Process.kill('INT', recall_pid)
          sleep 3
          Process.kill('TERM', recall_pid) if recall_pid
        rescue Errno::ESRCH
          STDERR.puts "Fail: #{$!}."
          rm_pidfile
        end
        STDERR.puts "Stopping #{self.class}."
      else
        STDERR.puts "#{pid_filename} not found. Is #{self.class} running?"
        exit 1
      end
      exit 0
    end
  end
end
