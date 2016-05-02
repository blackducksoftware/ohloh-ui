every 1.day, at: '9:00 am' do
  thor 'reverification_task:reverify:execute --bounce_threshold 50 --num_email 3000'
end
