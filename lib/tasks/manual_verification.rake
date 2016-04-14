desc 'Adds a manual verification to accounts with positions'
task :create_bulk_manual_verifications do
  Account.create_bulk_manual_verifications
end
