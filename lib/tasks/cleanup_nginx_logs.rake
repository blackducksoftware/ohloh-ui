# frozen_string_literal: true

desc 'Cleanup nginx logs'
task cleanup_nginx_logs: :environment do
  log_file = '/var/log/nginx/openhub-access.log'

  File.open(log_file, 'w') {} if File.exist?(log_file)
end
