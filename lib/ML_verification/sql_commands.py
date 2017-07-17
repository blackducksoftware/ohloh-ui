"""Provides methods to execute different sql commands."""


def create_commits_view(db):
    """Create commits view with user and commits_count.

    Args:
        db (psycopg2.connection) - the connection to database

    Returns:
        Creates a temporary view. Returns None.

        view_name: commits_count
        columns: account_id, commits_count

    Throws:
        An error if unable to execute the command describing the reason.

    """
    # Command String
    commits_str = "create temp view commits_count as \
                  (select accounts.id as account_id, \
                          name_facts.commits as commits_count \
                   from accounts, name_facts \
                   where (accounts.best_vita_id is not null) \
                     and (accounts.best_vita_id=name_facts.vita_id));"
    # Command execute
    db.cursor().execute(commits_str)


def create_contributions_view(db):
    """Create contributions view with user and contributions_count.

    Args:
        db (psycopg2.connection) - the connection to database

    Returns:
        Creates a temporary view. Returns None.

        view_name: contributions_count
        columns: account_id, contributions_count

    Throws:
        An error if unable to execute the command describing the reason.

    """
    # Command String
    contributions_str = "create temp view contributions_count as \
                        (select account_id, count(*) as contributions_count \
                         from positions \
                         group by account_id);"
    # Command execute
    db.cursor().execute(contributions_str)


def create_emails_view(db):
    """Create emails view with user and email_id.

    Args:
        db (psycopg2.connection) - the connection to database

    Returns:
        Creates a temporary view. Returns None.

        view_name: emails
        columns: account_id, email_id

    Throws:
        An error if unable to execute the command describing the reason.

    """
    # Command String
    emails_str = "create temp view emails as \
                 (select id as account_id, email as email_id \
                  from accounts);"
    # Command execute
    db.cursor().execute(emails_str)


def create_posts_view(db):
    """Create posts view with user and posts_count.

    Args:
        db (psycopg2.connection) - the connection to database

    Returns:
        Creates a temporary view. Returns None.

        view_name: posts_count
        columns: account_id, posts_count

    Throws:
        An error if unable to execute the command describing the reason.

    """
    # Command String
    posts_str = "create temp view posts_count as \
                (select id as account_id, \
                              posts_count \
                 from accounts);"
    # Command execute
    db.cursor().execute(posts_str)


def create_projects_used_view(db):
    """Create projects_used view with user and projects_used_count.

    Args:
        db (psycopg2.connection) - the connection to database

    Returns:
        Creates a temporary view. Returns None.

        view_name: projects_used_count
        columns: account_id, projects_used_count

    Throws:
        An error if unable to execute the command describing the reason.

    """
    # Create a temporary view "counting" with total project used count
    # from stacks table.

    stack_str = "create temp view counting as \
                (select account_id, sum(project_count) \
                 from stacks \
                 group by account_id);"

    db.cursor().execute(stack_str)

    # "accounts" left join "counting"
    # name the temp view as projects_used_count

    join_str = "create temp view projects_used_count as \
                (select accounts.id as account_id, \
                        counting.sum as projects_used_count \
                 from accounts \
                 left join counting \
                 on (accounts.id = counting.account_id))"

    db.cursor().execute(join_str)


def create_names_view(db):
    """Create names view with user and name.

    Args:
        db (psycopg2.connection) - the connection to database

    Returns:
        Creates a temporary view. Returns None.

        view_name: names
        columns: account_id, name

    Throws:
        An error if unable to execute the command describing the reason.

    """
    # Command String
    names_str = "create temp view names as \
                 (select id as account_id, name \
                  from accounts);"
    # Command execute
    db.cursor().execute(names_str)


def create_logins_view(db):
    """Create logins view with user and login.

    Args:
        db (psycopg2.connection) - the connection to database

    Returns:
        Creates a temporary view. Returns None.

        view_name: logins
        columns: account_id, login

    Throws:
        An error if unable to execute the command describing the reason.

    """
    # Command String
    logins_str = "create temp view logins as \
                (select id as account_id, login \
                 from accounts);"
    # Command execute
    db.cursor().execute(logins_str)


def create_urls_view(db):
    """Create urls view with user and url.

    Args:
        db (psycopg2.connection) - the connection to database

    Returns:
        Creates a temporary view. Returns None.

        view_name: urls
        columns: account_id, url

    Throws:
        An error if unable to execute the command describing the reason.

    """
    # Command String
    urls_str = "create temp view urls as \
               (select id as account_id, url \
                from accounts);"
    # Command execute
    db.cursor().execute(urls_str)


def create_about_view(db):
    """Create about view with user and about.

    Args:
        db (psycopg2.connection) - the connection to database

    Returns:
        Creates a temporary view. Returns None.

        view_name: abouts
        columns: account_id, about

    Throws:
        An error if unable to execute the command describing the reason.

    """
    # Command String
    abouts_str = "create temp view abouts as \
                (select accounts.id as account_id, markups.raw as about \
                 from accounts, markups \
                 where accounts.about_markup_id = markups.id \
                 and accounts.id is not null \
                 and markups.raw is not null);"
    # Command execute
    db.cursor().execute(abouts_str)


def create_main_view(db):
    """Create the main view with all info. about the user.

    Note: Assumption is all the necessary views are already created.

    Args:
        db (psycopg2.connection) - the connection to database

    Returns:
        Creates a temporary view. Returns None

        view_name: main
        columns: account_id, commits_count, contributions_count,
                 email_id, posts_count, projects_used_count,
                 name, login, url, about

    """
    # Cursor
    cur = db.cursor()

    # Create a join using account_id:
    main_str = "create temp view main as \
               (select logins.account_id, \
                       emails.email_id, logins.login, \
                       commits_count.commits_count, \
                       contributions_count.contributions_count, \
                       posts_count.posts_count, \
                       projects_used_count.projects_used_count, \
                       names.name, urls.url, abouts.about \
                from logins \
                    left outer join emails on \
                        (emails.account_id = logins.account_id) \
                    left outer join commits_count on \
                        (commits_count.account_id = logins.account_id) \
                    left outer join contributions_count on \
                        (contributions_count.account_id = logins.account_id) \
                    left outer join posts_count on \
                        (posts_count.account_id = logins.account_id) \
                    left outer join projects_used_count on \
                        (projects_used_count.account_id = logins.account_id) \
                    left outer join names on \
                        (names.account_id = logins.account_id) \
                    left outer join urls on \
                        (urls.account_id = logins.account_id) \
                    left outer join abouts on \
                        (abouts.account_id = logins.account_id) \
                );"
    cur.execute(main_str)


def create_all_tables(db):
    """Run all other methods in this file and create all tables."""
    create_commits_view(db)
    create_contributions_view(db)
    create_about_view(db)
    create_urls_view(db)
    create_emails_view(db)
    create_logins_view(db)
    create_posts_view(db)
    create_names_view(db)
    create_projects_used_view(db)
    create_main_view(db)
