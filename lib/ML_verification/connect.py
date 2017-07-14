"""Provides Modulo to connect to a psql database."""
import psycopg2


def db(dbname, user, password, host):
    """Connect to the database.

    Args:
        dbname (str) - the database name
        user (str) - the user name
        password (str) - the password
        host (str) - the host name

    Returns:
        A database object that can be used as a portal to communicate with the
        actual database. It sets the client_encoding to utf-8. Changing
        client_encoding was required for python3 when I wrote this code.

    Throws:
        An error if unable to connect (possibly) describing the reason.

    """
    try:
        db = psycopg2.connect(dbname=dbname, user=user,
                              password=password, host=host)
        db.set_client_encoding("utf8")
    except:
        print("I am unable to connect to the database")

    return db
