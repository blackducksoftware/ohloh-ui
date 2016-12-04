BEGIN;

CREATE TABLE fifty_thousand_batch_pilot_accounts(account_id int);
\COPY fifty_thousand_batch_pilot_accounts(account_id) FROM 'passed_email_list.csv' CSV;

COMMIT;