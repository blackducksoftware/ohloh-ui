# Before the reverification process can begin....
# this task populates the reverification table fields
# if a user already has a twitter_id column.
task update_account_reverification_table: :environment do
  Reverification.populate_reverification_fields
end

task send_account_reverification_emails: :environment do
  #  Grab all accounts that don't have a twitter_id
  Reverification.send_reverification_emails
end
