BEGIN;

--
-- Create table `failed_accounts` from failed_id_list.csv file
--

DROP TABLE IF EXISTS failed_accounts;
CREATE TABLE failed_accounts(account_id int);
\COPY failed_accounts(account_id) FROM '/home/postgres/failed_id_list.csv' CSV;

--
-- Filter `failed_accounts` table:
-- If accounts have any associated entries like account reports, events, posts, edits, kudos, etc. remove it from `failed_accounts` table.
--

DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM account_reports  WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM actions WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM api_keys WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM authorizations WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM positions WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM duplicates WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM old_edits WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM edits WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT undone_by FROM old_edits WHERE undone_by IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT undone_by FROM edits WHERE undone_by IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM event_subscription WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT subscriber_id FROM event_subscription WHERE subscriber_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM follows WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT owner_id FROM follows WHERE owner_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM helpfuls WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT invitee_id FROM invites WHERE invitee_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT invitor_id FROM invites WHERE invitor_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM jobs WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM kudos WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT sender_id FROM kudos WHERE sender_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM manages WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT deleted_by FROM manages WHERE deleted_by IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM messages WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM posts WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM ratings WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT invitee_id FROM recommendations WHERE invitee_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT invitor_id FROM recommendations WHERE invitor_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM reviews WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM stacks WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM topics WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT replied_by FROM topics WHERE replied_by IN (SELECT account_id FROM failed_accounts));
DELETE FROM failed_accounts WHERE account_id IN (SELECT DISTINCT account_id FROM vitae WHERE account_id IN (SELECT account_id FROM failed_accounts));

--
-- Create a backup table that holds the vetted failed_accounts
--
CREATE TABLE IF NOT EXISTS guaranteed_spam_accounts(LIKE accounts);
INSERT INTO guaranteed_spam_accounts (SELECT a.* FROM accounts a INNER JOIN failed_accounts fa ON a.id=fa.account_id LEFT JOIN guaranteed_spam_accounts sa ON fa.account_id=sa.id WHERE sa.id IS NULL);
--
--  Remove the foreign key constraints from the tables account_reports, edits, posts, kudos, etc.
--

ALTER TABLE account_reports DROP CONSTRAINT account_reports_account_id_fkey;
ALTER TABLE actions DROP CONSTRAINT actions_account_id_fkey;
ALTER TABLE api_keys DROP CONSTRAINT api_keys_account_id_fkey;
ALTER TABLE authorizations DROP CONSTRAINT authorizations_account_id_fkey;
ALTER TABLE positions DROP CONSTRAINT claims_account_id_fkey;
ALTER TABLE duplicates DROP CONSTRAINT duplicates_account_id_fkey;
ALTER TABLE old_edits DROP CONSTRAINT edits_account_id_fkey;
ALTER TABLE edits DROP CONSTRAINT edits_account_id_fkey1;
ALTER TABLE old_edits DROP CONSTRAINT edits_undone_by_fkey;
ALTER TABLE edits DROP CONSTRAINT edits_undone_by_fkey1;
ALTER TABLE event_subscription DROP CONSTRAINT event_subscription_account_id_fkey;
ALTER TABLE event_subscription DROP CONSTRAINT event_subscription_subscriber_id_fkey;
ALTER TABLE follows DROP CONSTRAINT follows_account_id_fkey;
ALTER TABLE follows DROP CONSTRAINT follows_owner_id_fkey;
ALTER TABLE helpfuls DROP CONSTRAINT helpfuls_account_id_fkey;
ALTER TABLE invites DROP CONSTRAINT invites_invitee_id_fkey;
ALTER TABLE invites DROP CONSTRAINT invites_invitor_id_fkey;
ALTER TABLE jobs DROP CONSTRAINT jobs_account_id_fkey;
ALTER TABLE kudos DROP CONSTRAINT kudos_account_id_fkey;
ALTER TABLE kudos DROP CONSTRAINT kudos_sender_id_fkey;
ALTER TABLE manages DROP CONSTRAINT manages_account_id_fkey;
ALTER TABLE manages DROP CONSTRAINT manages_approved_by_fkey;
ALTER TABLE manages DROP CONSTRAINT manages_deleted_by_fkey;
ALTER TABLE message_account_tags DROP CONSTRAINT message_account_tags_account_id_fkey;
ALTER TABLE message_project_tags DROP CONSTRAINT message_project_tags_message_id_fkey;
ALTER TABLE messages DROP CONSTRAINT messages_account_id_fkey;
ALTER TABLE actions DROP CONSTRAINT actions_claim_person_id_fkey;
ALTER TABLE people DROP CONSTRAINT people_account_id_fkey;
ALTER TABLE posts DROP CONSTRAINT posts_account_id_fkey;
ALTER TABLE ratings DROP CONSTRAINT ratings_account_id_fkey;
ALTER TABLE recommendations DROP CONSTRAINT recommendations_invitee_id_fkey;
ALTER TABLE recommendations DROP CONSTRAINT recommendations_invitor_id_fkey;
ALTER TABLE reviews DROP CONSTRAINT reviews_account_id_fkey;
ALTER TABLE stacks DROP CONSTRAINT stacks_account_id_fkey;
ALTER TABLE topics DROP CONSTRAINT topics_account_id_fkey;
ALTER TABLE topics DROP CONSTRAINT topics_replied_by_fkey;
ALTER TABLE vitae DROP CONSTRAINT vitae_account_id_fkey;

--
--  Delete the guaranteed spam accounts and its associated messages and people entries.
--

DELETE FROM accounts WHERE id IN (SELECT account_id FROM failed_accounts);
DELETE FROM actions where claim_person_id IN (SELECT id FROM people WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM people WHERE account_id IN (SELECT account_id FROM failed_accounts);
DELETE FROM message_account_tags where account_id IN (SELECT account_id FROM failed_accounts);
DELETE FROM message_account_tags where message_id IN (SELECT id FROM messages WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM message_project_tags where message_id IN (SELECT id FROM messages WHERE account_id IN (SELECT account_id FROM failed_accounts));
DELETE FROM messages WHERE account_id IN (SELECT account_id FROM failed_accounts);

--
--  Add again the foreign key constraints to the tables account_reports, edits, posts, kudos, etc.
--

ALTER TABLE account_reports ADD CONSTRAINT account_reports_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE actions ADD CONSTRAINT actions_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE api_keys ADD CONSTRAINT api_keys_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE authorizations ADD CONSTRAINT authorizations_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE positions ADD CONSTRAINT claims_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE duplicates ADD CONSTRAINT duplicates_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE old_edits ADD CONSTRAINT edits_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id);
ALTER TABLE edits ADD CONSTRAINT edits_account_id_fkey1 FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE old_edits ADD CONSTRAINT edits_undone_by_fkey FOREIGN KEY (undone_by) REFERENCES accounts(id);
ALTER TABLE edits ADD CONSTRAINT edits_undone_by_fkey1 FOREIGN KEY (undone_by) REFERENCES accounts(id);
ALTER TABLE event_subscription ADD CONSTRAINT event_subscription_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE event_subscription ADD CONSTRAINT event_subscription_subscriber_id_fkey FOREIGN KEY (subscriber_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE follows ADD CONSTRAINT follows_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE follows ADD CONSTRAINT follows_owner_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE helpfuls ADD CONSTRAINT helpfuls_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE invites ADD CONSTRAINT invites_invitee_id_fkey FOREIGN KEY (invitee_id) REFERENCES accounts(id);
ALTER TABLE invites ADD CONSTRAINT invites_invitor_id_fkey FOREIGN KEY (invitor_id) REFERENCES accounts(id);
ALTER TABLE jobs ADD CONSTRAINT jobs_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE kudos ADD CONSTRAINT kudos_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE kudos ADD CONSTRAINT kudos_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE manages ADD CONSTRAINT manages_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE manages ADD CONSTRAINT manages_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES accounts(id);
ALTER TABLE manages ADD CONSTRAINT manages_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES accounts(id);
ALTER TABLE message_account_tags ADD CONSTRAINT message_account_tags_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE message_project_tags ADD CONSTRAINT message_project_tags_message_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;
ALTER TABLE messages ADD CONSTRAINT messages_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE actions ADD CONSTRAINT actions_claim_person_id_fkey FOREIGN KEY (claim_person_id) REFERENCES people(id);
ALTER TABLE people ADD CONSTRAINT people_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE posts ADD CONSTRAINT posts_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE ratings ADD CONSTRAINT ratings_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE recommendations ADD CONSTRAINT recommendations_invitee_id_fkey FOREIGN KEY (invitee_id) REFERENCES accounts(id);
ALTER TABLE recommendations ADD CONSTRAINT recommendations_invitor_id_fkey FOREIGN KEY (invitor_id) REFERENCES accounts(id);
ALTER TABLE reviews ADD CONSTRAINT reviews_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE stacks ADD CONSTRAINT stacks_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE topics ADD CONSTRAINT topics_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE topics ADD CONSTRAINT topics_replied_by_fkey FOREIGN KEY (replied_by) REFERENCES accounts(id) ON DELETE CASCADE;
ALTER TABLE vitae ADD CONSTRAINT vitae_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;

DROP TABLE IF EXISTS failed_accounts;

COMMIT;
