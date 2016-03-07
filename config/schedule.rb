every 1.day, at: '9:00 am' do
  rake 'reverification:execute_reverification_process'
end

every 1.day, at: '9:00 am' do
  rake 'reverification:retry_soft_bounced_responses'
end

every :hour do
  rake 'reverification:poll_success_queue'
  rake 'reverification:poll_bounce_queue'
  rake 'reverification:poll_complaints_queue'
  rake 'reverification:remove_reverification_trackers_for_verified_accounts'
  rake 'reverification:delete_expired_accounts'
end
