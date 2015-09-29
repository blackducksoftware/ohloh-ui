# Before the reverification process can begin....
# this task creates and populates a reverification
# association for every single account.
# The reverification table will be used in combination
# with verfications, twitter_digits_verification, and
# github_verification
task update_account_reverification_table: :environment do
  Reverification.create_and_populate_reverification_fields
end

task send_account_reverification_emails: :environment do
  #  Grab all accounts that don't have a twitter_id
  Reverification.send_reverification_emails
end
