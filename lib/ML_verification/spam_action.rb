path_to_ML_job = Rails.root.join('lib', 'ML_verification', 'job.py').to_s
cmd_ML = 'python3 ' + path_to_ML_job
exec(cmd_ML)

path_to_spammers = Rails.root.join('lib', 'ML_verification', 'spammers.txt').to_s

AccountMailer.spam_notification(path_to_spammers).deliver_now
