"""Script to run daily."""
import setup
import connect
import sql_commands
import linear_classifier as lc
import numpy as np
import helper


def main():
    """Filter stuff."""
    db = connect.db(setup.dbname, setup.user, setup.password, setup.host)
    sql_commands.create_all_tables(db)

    cmd_str = "select main.* from main, accounts where \
               main.account_id = accounts.id and \
               accounts.created_at > localtimestamp - INTERVAL '10 month' and \
               level = 0 and (main.url is not NULL or main.about is \
               not NULL);"

    cur = db.cursor()
    cur.execute(cmd_str)
    query_result = cur.fetchall()
    accounts = []
    for line in query_result:
        accounts.append(line[0])

    # If no account created...return 0:
    if(len(accounts) == 0):
        return []
    marker = 0  # Dummy Marker
    matrix = helper.create_matrix(query_result, marker)[:, :-1]

    count_spammers = {}
    no_count_spammers = {}

    # With counts:
    PA = np.load(setup.classifier_WI)
    T = PA[:-1]
    T_0 = PA[-1]
    feature_matrix = matrix[:, :]
    res = lc.classify(feature_matrix, T, T_0)

    for index in range(len(accounts)):
        if(res[index] == -1):
            account_id = accounts[index]
            count_spammers[account_id] = -1

    # Without counts:
    ptron = np.load(setup.classifier_W0)
    T = ptron[:-1]
    T_0 = ptron[-1]
    feature_matrix = matrix[:, 4:]
    res = lc.classify(feature_matrix, T, T_0)

    for index in range(len(accounts)):
        if(res[index] == -1):
            account_id = accounts[index]
            no_count_spammers[account_id] = -1
    final_lst = []

    for account_id in count_spammers:
        if (account_id in no_count_spammers):
            final_lst.append(account_id)

    f = open(setup.destination, 'w')
    for account_id in final_lst:
        f.write(str(account_id) + '\n')


if __name__ == '__main__':
    main()
