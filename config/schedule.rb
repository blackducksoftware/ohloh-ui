every 1.day, at: '9:00 am' do
  rake 'reverification:execute_reverification_process'
end

every :hour do
  rake 'reverification:poll_success_queue'
  rake 'reverification:poll_bounce_queue'
end

every 1.day, at: '6:00 am' do
  rake 'reverification:remove_reverification_trackers_for_validated_accounts'
end
