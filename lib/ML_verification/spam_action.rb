path_to_ml_job = Rails.root.join('lib', 'ML_verification', 'job.py').to_s
cmd_ml = 'python3 ' + path_to_ml_job
exec(cmd_ml)

path_to_spammers = Rails.root.join('lib', 'ML_verification', 'spammers.txt').to_s

AccountMailer.spam_notification(path_to_spammers).deliver_now
