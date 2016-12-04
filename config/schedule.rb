set :output, error: 'reverification_cron_error.log', standard: 'reverification_cron.log'

job_type :thor_command, %{export PATH=$HOME/.rbenv/shims:$HOME/bin:/usr/bin:$PATH; eval "$(rbenv init -)"; \
                          cd /var/local/openhub/current && RAILS_ENV=production bundle exec thor :task }

every 1.day, at: '9:00 am' do
  thor_command 'reverification_task:reverify:execute --bounce_threshold 30 --num_email 2000'
end
