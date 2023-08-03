SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: bluemedora; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA bluemedora;


--
-- Name: fis; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA fis;


--
-- Name: SCHEMA fis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA fis IS 'standard public schema';


--
-- Name: oa; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA oa;


--
-- Name: oh; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA oh;


--
-- Name: SCHEMA oh; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA oh IS 'standard public schema';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA fis;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA fis;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: statinfo; Type: TYPE; Schema: fis; Owner: -
--

CREATE TYPE fis.statinfo AS (
	word text,
	ndoc integer,
	nentry integer
);


--
-- Name: tokenout; Type: TYPE; Schema: fis; Owner: -
--

CREATE TYPE fis.tokenout AS (
	tokid integer,
	token text
);


--
-- Name: tokentype; Type: TYPE; Schema: fis; Owner: -
--

CREATE TYPE fis.tokentype AS (
	tokid integer,
	alias text,
	descr text
);


--
-- Name: tsdebug; Type: TYPE; Schema: fis; Owner: -
--

CREATE TYPE fis.tsdebug AS (
	ts_name text,
	tok_type text,
	description text,
	token text,
	dict_name text[],
	tsvector tsvector
);


--
-- Name: statinfo; Type: TYPE; Schema: oh; Owner: -
--

CREATE TYPE oh.statinfo AS (
	word text,
	ndoc integer,
	nentry integer
);


--
-- Name: tokenout; Type: TYPE; Schema: oh; Owner: -
--

CREATE TYPE oh.tokenout AS (
	tokid integer,
	token text
);


--
-- Name: tokentype; Type: TYPE; Schema: oh; Owner: -
--

CREATE TYPE oh.tokentype AS (
	tokid integer,
	alias text,
	descr text
);


--
-- Name: tsdebug; Type: TYPE; Schema: oh; Owner: -
--

CREATE TYPE oh.tsdebug AS (
	ts_name text,
	tok_type text,
	description text,
	token text,
	dict_name text[],
	tsvector tsvector
);


--
-- Name: pg_stat_statements(); Type: FUNCTION; Schema: bluemedora; Owner: -
--

CREATE FUNCTION bluemedora.pg_stat_statements() RETURNS SETOF fis.pg_stat_statements
    LANGUAGE sql SECURITY DEFINER
    AS $$
SELECT * FROM public.pg_stat_statements;
$$;


--
-- Name: _get_parser_from_curcfg(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis._get_parser_from_curcfg() RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ select prs_name from pg_ts_cfg where oid = show_curcfg() $$;


--
-- Name: admin_insert_cl_added_stats(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_insert_cl_added_stats() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$

DECLARE
  result jsonb;
BEGIN
  WITH locations AS (SELECT created_at FROM code_locations
                WHERE created_at  BETWEEN
                      date_trunc('year', now())::timestamp - interval '14 days' AND DATE 'tomorrow'),
        series AS (SELECT generate_series( date_trunc('week', date_trunc('year', now()::timestamp)), DATE 'tomorrow',
            '1 week'::INTERVAL)::date AS bow),
        range AS (SELECT EXTRACT(Week from bow) as weeknumber, bow, (bow + 6) AS eow, (bow - 14) AS biweekly,
                  EXTRACT(quarter FROM bow) AS quarter, EXTRACT(month from bow) AS month,
                  EXTRACT(Year from bow) AS year
                FROM series)
          SELECT array_to_json(array_agg(row_to_json(t))) FROM (
            SELECT * FROM
              (SELECT weeknumber, bow,eow, biweekly, month, year,
              (SELECT count(*) FROM locations WHERE created_at BETWEEN bow AND eow) as weekly,
              (SELECT count(*) FROM locations WHERE created_at BETWEEN biweekly and bow) as biweekly,
              (SELECT count(*) FROM locations WHERE EXTRACT(MONTH from created_at) = month
                  AND EXTRACT(YEAR from created_at) = year) as monthly,
              (SELECT count(*) FROM locations WHERE EXTRACT(QUARTER from created_at) = quarter
                  AND EXTRACT(YEAR from created_at) = year) as quarterly,
              (SELECT count(*) FROM locations WHERE EXTRACT(YEAR from created_at) = year) as yearly
          FROM range) n1 where weeknumber = EXTRACT('week' from CURRENT_DATE)
              AND YEAR = EXTRACT('year' from CURRENT_DATE))t INTO result;
   INSERT INTO admin_dashboard_stats (stat_type, data, created_at, updated_at)
      VALUES ('cl_added', result, current_timestamp, current_timestamp) ;

  RETURN result;
END;

$$;


--
-- Name: admin_insert_cl_added_stats_v2(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_insert_cl_added_stats_v2() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$

    DECLARE
      result jsonb;
    BEGIN
      WITH locations AS (SELECT created_at FROM code_locations
                    WHERE created_at  BETWEEN
                    now() - interval '1 year' AND DATE 'tomorrow'),

            series AS (SELECT generate_series( date_trunc('week', now() - interval '1 year'), DATE 'tomorrow',
                '1 week'::INTERVAL)::date AS bow),

            range AS (SELECT EXTRACT(Week from bow) as weeknumber, bow, (bow + 6) AS eow, (bow - 14) AS biweekly,
                    (bow - 30) AS monthly,
                    (bow - 60) AS sixty_days,
                    (bow - 90) As ninety_days,
                      EXTRACT(quarter FROM bow) AS quarter, EXTRACT(month from bow) AS month,
                      EXTRACT(Year from bow) AS year
                    FROM series)

            SELECT array_to_json(array_agg(row_to_json(t))) FROM (
                SELECT * FROM
                  (SELECT weeknumber, bow,eow, biweekly, monthly, sixty_days, ninety_days,  month, year,
                  (SELECT count(*) FROM locations WHERE created_at BETWEEN bow AND eow) as weekly,
                  (SELECT count(*) FROM locations WHERE created_at BETWEEN biweekly and bow) as biweekly,
                  (SELECT count(*) FROM locations WHERE created_at BETWEEN monthly and bow) as monthly,
                  (SELECT count(*) FROM locations WHERE created_at BETWEEN sixty_days and bow) as sixty_days,
                  (SELECT count(*) FROM locations WHERE created_at BETWEEN ninety_days and bow) as ninety_days,
                  (SELECT count(*) FROM locations WHERE EXTRACT(MONTH from created_at) = month
                      AND EXTRACT(YEAR from created_at) = year) as monthly,
                  (SELECT count(*) FROM locations WHERE EXTRACT(QUARTER from created_at) = quarter
                      AND EXTRACT(YEAR from created_at) = year) as quarterly,
                  (SELECT count(*) FROM locations WHERE created_at BETWEEN now() - interval '1 year' and bow) as yearly
              FROM range) n1 where weeknumber = EXTRACT('week' from CURRENT_DATE)
                  AND YEAR = EXTRACT('year' from CURRENT_DATE))t INTO result;

            INSERT INTO admin_dashboard_stats (stat_type, data, created_at, updated_at)
                VALUES ('cl_added', result, current_timestamp, current_timestamp) ;

          RETURN result;
    END;
    $$;


--
-- Name: admin_insert_cl_py_ages_stats(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_insert_cl_py_ages_stats() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$

DECLARE
  result jsonb;
BEGIN
WITH codesets AS (SELECT logged_at
FROM code_sets
INNER JOIN code_locations ON code_locations.best_code_set_id = code_sets.id
LEFT OUTER JOIN (SELECT DISTINCT enlistments.code_location_id, enlistments.deleted FROM enlistments
          WHERE enlistments.deleted = false) e1 ON e1.code_location_id = code_locations.id

 WHERE (COALESCE(code_sets.logged_at, '1970-01-01') + code_locations.update_interval * INTERVAL '1 second'
          <= NOW() AT TIME ZONE 'utc' )
 AND code_locations.do_not_fetch = false
      AND ( (code_locations.status = 0  AND e1.deleted = false) OR code_locations.status = 1)),

series AS (SELECT generate_series( date_trunc('year', now()),
                                   now() + interval '1 week',
                                   '1 week'::INTERVAL)::date AS eow ),

min_date AS (SELECT MIN(eow) as eow FROM series),

py_month AS (SELECT series.eow as week_ending, count(*) as count
FROM codesets
INNER JOIN series ON EXTRACT('week' from series.eow) = EXTRACT('week' from codesets.logged_at)
WHERE codesets.logged_at >= date_trunc('year', now())
group by series.eow order by series.eow desc)

SELECT array_to_json(array_agg(row_to_json(t))) FROM (
SELECT 'cy' as type, week_ending, count FROM py_month
UNION
SELECT 'ly' as type, (SELECT eow FROM min_date) as week_ending, count(*)  as count  from codesets
WHERE logged_at < (SELECT eow FROM min_date)
order by type asc, week_ending desc)t INTO result;

INSERT INTO admin_dashboard_stats (stat_type, data, created_at, updated_at)
        VALUES ('cl_py_ages', result, current_timestamp, current_timestamp) ;

    RETURN result;
END;

$$;


--
-- Name: admin_insert_cl_py_ages_stats_v2(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_insert_cl_py_ages_stats_v2() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$

DECLARE
  result jsonb;
BEGIN
WITH codesets AS (SELECT logged_at
FROM code_sets
INNER JOIN code_locations ON code_locations.best_code_set_id = code_sets.id
INNER JOIN (SELECT DISTINCT subscriptions.code_location_id FROM subscriptions) sub
    ON sub.code_location_id = code_locations.id
WHERE code_locations.do_not_fetch = false),

series AS (SELECT generate_series( date_trunc('year', now()),
                                   NOW() + interval '1 week',
                                   '1 week'::INTERVAL)::date AS eow ),

min_date AS (SELECT MIN(eow) as eow FROM series),

py_month AS (SELECT series.eow as week_ending, count(*) as count
FROM codesets
INNER JOIN series ON EXTRACT('week' from series.eow) = EXTRACT('week' from codesets.logged_at)
WHERE codesets.logged_at >= date_trunc('year', NOW())
GROUP BY series.eow ORDER BY series.eow desc)

SELECT array_to_json(array_agg(row_to_json(t))) FROM (
SELECT 'cy' as type, week_ending, count FROM py_month
UNION
SELECT 'ly' as type, (SELECT eow FROM min_date) as week_ending, count(*)  as count  from codesets
WHERE logged_at < (SELECT eow FROM min_date)
ORDER BY type asc, week_ending desc)t INTO result;

INSERT INTO admin_dashboard_stats (stat_type, data, created_at, updated_at)
        VALUES ('cl_py_ages', result, current_timestamp, current_timestamp) ;

    RETURN result;
END;

$$;


--
-- Name: admin_insert_cl_py_by_month_stats(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_insert_cl_py_by_month_stats() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$

DECLARE
  result jsonb;
BEGIN
  SELECT array_to_json(array_agg(row_to_json(t))) FROM (
      SELECT bom, count(*) FROM code_sets
                 INNER JOIN code_locations ON code_locations.best_code_set_id = code_sets.id
                 INNER JOIN (SELECT generate_series(make_date(EXTRACT(year from now() - interval '1 year')::int,01,01),
                   make_date(EXTRACT(year from now())::int, 12,31),'1 month'::INTERVAL)::date AS bom
                 ) series ON EXTRACT('month' from series.bom) = EXTRACT('month' from code_sets.logged_at)
                 LEFT OUTER JOIN (SELECT DISTINCT enlistments.code_location_id, enlistments.deleted FROM enlistments
                     WHERE enlistments.deleted = false) e1 ON e1.code_location_id = code_locations.id
                 WHERE code_locations.do_not_fetch = false
                   AND ((code_locations.status = 0  AND e1.deleted = false) OR code_locations.status = 1)
                 AND code_sets.logged_at >= make_date(EXTRACT(year from now() - interval '1 year')::int, 01,01)
                 group by bom order by bom desc)t INTO result;
   INSERT INTO admin_dashboard_stats (stat_type, data, created_at, updated_at)
    VALUES ('cl_py_by_month', result, current_timestamp, current_timestamp) ;

  RETURN result;
END;

$$;


--
-- Name: admin_insert_cl_py_by_month_stats_v2(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_insert_cl_py_by_month_stats_v2() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$

DECLARE
  result jsonb;
BEGIN
  SELECT array_to_json(array_agg(row_to_json(t))) FROM (
      SELECT bom, count(*)
        FROM code_sets
        INNER JOIN code_locations ON code_locations.best_code_set_id = code_sets.id
        INNER JOIN (SELECT generate_series(make_date(EXTRACT(year from now() - interval '1 year')::int,01,01),
                   make_date(EXTRACT(year from now())::int, 12,31),'1 month'::INTERVAL)::date AS bom) series
                    ON EXTRACT('month' from series.bom) = EXTRACT('month' from code_sets.logged_at)
        LEFT OUTER JOIN (SELECT DISTINCT subscriptions.code_location_id FROM subscriptions) sub
                    ON sub.code_location_id = code_locations.id
        WHERE code_locations.do_not_fetch = false
          AND code_sets.logged_at >= make_date(EXTRACT(year from now() - interval '1 year')::int, 01,01)
        GROUP BY bom ORDER BY bom desc)t INTO result;

    INSERT INTO admin_dashboard_stats (stat_type, data, created_at, updated_at)
      VALUES ('cl_py_by_month', result, current_timestamp, current_timestamp) ;

  RETURN result;
END;

$$;


--
-- Name: admin_insert_cl_total_stats(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_insert_cl_total_stats() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$

  DECLARE
    result jsonb;
  BEGIN
    WITH locations AS (SELECT id, status, do_not_fetch, update_interval, best_code_set_id FROM code_locations),

    dnf AS (Select * from locations WHERE do_not_fetch = true),

    unsubscribed AS (SELECT cl.*
      FROM locations cl
       LEFT OUTER JOIN (SELECT DISTINCT enlistments.code_location_id, enlistments.deleted FROM enlistments
                  WHERE enlistments.deleted = false) e1 ON e1.code_location_id = cl.id
       WHERE (cl.status = 0 AND e1.code_location_id IS NULL) AND do_not_fetch = false AND best_code_set_id IS NOT NULL),

    inactive AS (SELECT * from locations WHERE status = 2 AND do_not_fetch = false),

    subscribed AS ( SELECT  locations.id, status, do_not_fetch, best_code_set_id
             FROM code_sets
             INNER JOIN locations ON locations.best_code_set_id = code_sets.id
                LEFT OUTER JOIN (SELECT DISTINCT enlistments.code_location_id, enlistments.deleted FROM enlistments
                     WHERE enlistments.deleted = false) e1 ON e1.code_location_id = locations.id
             WHERE (COALESCE(code_sets.logged_at, '1970-01-01') +
                  locations.update_interval * INTERVAL '1 second'
                  <= NOW() AT TIME ZONE 'utc' AND locations.do_not_fetch = false)
                AND ( (locations.status = 0  AND e1.deleted = false) OR locations.status = 1)
            AND locations.do_not_fetch = false),

    timely AS (SELECT locations.id, locations.status, do_not_fetch, update_interval, best_code_set_id FROM locations
            INNER JOIN code_sets cs ON  locations.best_code_set_id = cs.id
            LEFT OUTER JOIN (SELECT DISTINCT enlistments.code_location_id, enlistments.deleted
                  FROM enlistments
                     WHERE enlistments.deleted = false) e1 ON e1.code_location_id = locations.id
          WHERE (COALESCE(cs.logged_at, '1970-01-01') +
             locations.update_interval * INTERVAL '1 second'
          > NOW() AT TIME ZONE 'utc' AND locations.do_not_fetch = false)
                AND ( (locations.status = 0  AND e1.deleted = false) OR locations.status = 1)
            AND locations.do_not_fetch = false),

    no_best_code AS (select * from locations where best_code_set_id IS NULL AND do_not_fetch = false AND status <> 2)

    SELECT array_to_json(array_agg(row_to_json(t))) FROM (
    SELECT * FROM
      (SELECT count(*) as total FROM locations) as total,
      (SELECT count(*) as dnf FROM dnf) as dnf,
      (SELECT count(*) as inactive FROM inactive) as inactive,
      (SELECT count(*) as unsubscribed FROM unsubscribed) as unsubscribed,
      (SELECT count(*) as wait_until FROM timely) as wait_until,
      (SELECT count(*) as no_best_code FROM no_best_code) as no_best_code,
      (SELECT count(*) as subscribed FROM subscribed) as subscribed,
      (SELECT count(*) as idk
        FROM locations cl
        LEFT OUTER JOIN dnf ON cl.id = dnf.id
        LEFT OUTER JOIN unsubscribed us ON cl.id = us.id
        LEFT OUTER JOIN inactive ina ON cl.id = ina.id
        LEFT OUTER JOIN subscribed sb ON cl.id = sb.id
        LEFT OUTER JOIN timely tml ON cl.id = tml.id
        LEFT OUTER JOIN no_best_code nbc ON cl.id = nbc.id
      WHERE dnf.id IS NULL
      AND us.id IS NULL
      AND ina.id IS NULL
      AND sb.id IS NULL
      AND tml.id IS NULL
      AND nbc.id IS NULL) as idk)t
    INTO result;

    INSERT INTO admin_dashboard_stats (stat_type, data, created_at, updated_at)
      VALUES ('cl_total', result, current_timestamp, current_timestamp) ;

    RETURN result;
  END;

  $$;


--
-- Name: admin_insert_cl_total_stats_v2(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_insert_cl_total_stats_v2() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$

  DECLARE
    result jsonb;
  BEGIN
    WITH locations AS (SELECT id, status, do_not_fetch, update_interval, best_code_set_id FROM code_locations),

    dnf AS (Select * FROM locations WHERE do_not_fetch = true),

    unsubscribed AS (SELECT cl.*
      FROM locations cl
      LEFT OUTER JOIN (SELECT DISTINCT subscriptions.code_location_id FROM subscriptions) sub
          ON sub.code_location_id = cl.id
      WHERE sub.code_location_id IS NULL
        AND do_not_fetch = false AND best_code_set_id IS NOT NULL),

    inactive AS (SELECT * FROM locations WHERE status = 2 AND do_not_fetch = false),

    subscribed AS ( SELECT  locations.id, status, do_not_fetch, best_code_set_id
      FROM code_sets cs
      INNER JOIN locations ON locations.best_code_set_id = cs.id
      INNER JOIN (SELECT DISTINCT subscriptions.code_location_id FROM subscriptions) sub
          ON sub.code_location_id = locations.id
      WHERE COALESCE(cs.logged_at, '1970-01-01') + locations.update_interval * INTERVAL '1 second'
          < NOW() AT TIME ZONE 'utc'
        AND locations.do_not_fetch = false),

    timely AS (SELECT locations.id, locations.status, do_not_fetch, update_interval, best_code_set_id
      FROM locations
      INNER JOIN code_sets cs ON  locations.best_code_set_id = cs.id
      INNER JOIN (SELECT DISTINCT subscriptions.code_location_id FROM subscriptions) sub
          ON sub.code_location_id = locations.id
      WHERE COALESCE(cs.logged_at, '1970-01-01') +locations.update_interval * INTERVAL '1 second'
          > NOW() AT TIME ZONE 'utc'
        AND locations.do_not_fetch = false),

    no_best_code AS (select * FROM locations where best_code_set_id IS NULL AND do_not_fetch = false )

    SELECT array_to_json(array_agg(row_to_json(t))) FROM (
    SELECT * FROM
      (SELECT count(*) as total FROM locations) as total,
      (SELECT count(*) as dnf FROM dnf) as dnf,
      (SELECT count(*) as inactive FROM inactive) as inactive,
      (SELECT count(*) as unsubscribed FROM unsubscribed) as unsubscribed,
      (SELECT count(*) as wait_until FROM timely) as wait_until,
      (SELECT count(*) as no_best_code FROM no_best_code) as no_best_code,
      (SELECT count(*) as subscribed FROM subscribed) as subscribed,
      (SELECT count(*) as idk
        FROM locations cl
        LEFT OUTER JOIN dnf ON cl.id = dnf.id
        LEFT OUTER JOIN unsubscribed us ON cl.id = us.id
        LEFT OUTER JOIN inactive ina ON cl.id = ina.id
        LEFT OUTER JOIN subscribed sb ON cl.id = sb.id
        LEFT OUTER JOIN timely tml ON cl.id = tml.id
        LEFT OUTER JOIN no_best_code nbc ON cl.id = nbc.id
      WHERE dnf.id IS NULL
      AND us.id IS NULL
      AND ina.id IS NULL
      AND sb.id IS NULL
      AND tml.id IS NULL
      AND nbc.id IS NULL) as idk)t
    INTO result;

    INSERT INTO admin_dashboard_stats (stat_type, data, created_at, updated_at)
      VALUES ('cl_total', result, current_timestamp, current_timestamp) ;

    RETURN result;
  END;

  $$;


--
-- Name: admin_insert_cl_total_stats_v3(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_insert_cl_total_stats_v3() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$

DECLARE
  result jsonb;
BEGIN
  WITH locations AS (SELECT id, do_not_fetch, update_interval, best_code_set_id FROM code_locations),

  dnf AS (Select * FROM locations WHERE do_not_fetch = true),

  unsubscribed AS (SELECT cl.*
    FROM locations cl
    LEFT OUTER JOIN (SELECT DISTINCT subscriptions.code_location_id FROM subscriptions) sub
        ON sub.code_location_id = cl.id
    WHERE sub.code_location_id IS NULL
      AND do_not_fetch = false AND best_code_set_id IS NOT NULL),

  subscribed AS ( SELECT  locations.id, do_not_fetch, best_code_set_id
    FROM code_sets cs
    INNER JOIN locations ON locations.best_code_set_id = cs.id
    INNER JOIN (SELECT DISTINCT subscriptions.code_location_id FROM subscriptions) sub
        ON sub.code_location_id = locations.id
    WHERE COALESCE(cs.logged_at, '1970-01-01') + locations.update_interval * INTERVAL '1 second'
        < NOW() AT TIME ZONE 'utc'
      AND locations.do_not_fetch = false),

  timely AS (SELECT locations.id, do_not_fetch, update_interval, best_code_set_id
    FROM locations
    INNER JOIN code_sets cs ON  locations.best_code_set_id = cs.id
    INNER JOIN (SELECT DISTINCT subscriptions.code_location_id FROM subscriptions) sub
        ON sub.code_location_id = locations.id
    WHERE COALESCE(cs.logged_at, '1970-01-01') +locations.update_interval * INTERVAL '1 second'
        > NOW() AT TIME ZONE 'utc'
      AND locations.do_not_fetch = false),

  no_best_code AS (select * FROM locations where best_code_set_id IS NULL AND do_not_fetch = false )

  SELECT array_to_json(array_agg(row_to_json(t))) FROM (
  SELECT * FROM
    (SELECT count(*) as total FROM locations) as total,
    (SELECT count(*) as dnf FROM dnf) as dnf,
    (SELECT count(*) as unsubscribed FROM unsubscribed) as unsubscribed,
    (SELECT count(*) as wait_until FROM timely) as wait_until,
    (SELECT count(*) as no_best_code FROM no_best_code) as no_best_code,
    (SELECT count(*) as subscribed FROM subscribed) as subscribed,
    (SELECT count(*) as idk
      FROM locations cl
      LEFT OUTER JOIN dnf ON cl.id = dnf.id
      LEFT OUTER JOIN unsubscribed us ON cl.id = us.id
      LEFT OUTER JOIN subscribed sb ON cl.id = sb.id
      LEFT OUTER JOIN timely tml ON cl.id = tml.id
      LEFT OUTER JOIN no_best_code nbc ON cl.id = nbc.id
    WHERE dnf.id IS NULL
    AND us.id IS NULL
    AND sb.id IS NULL
    AND tml.id IS NULL
    AND nbc.id IS NULL) as idk)t
  INTO result;

  INSERT INTO admin_dashboard_stats (stat_type, data, created_at, updated_at)
    VALUES ('cl_total', result, current_timestamp, current_timestamp) ;

  RETURN result;
END;

$$;


--
-- Name: admin_insert_cl_visited_stats(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_insert_cl_visited_stats() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$

DECLARE
  result jsonb;
BEGIN
  SELECT admin_select_cl_visited_stats() ||
  		 admin_select_cl_visited_stats('3 days') ||
  		 admin_select_cl_visited_stats('1 month') ||
         admin_select_kb_cl_visited_stats() ||
         admin_select_kb_cl_visited_stats('3 days') ||
         admin_select_kb_cl_visited_stats('1 month') INTO result;

  INSERT INTO admin_dashboard_stats (stat_type, data, created_at, updated_at)
    VALUES ('cl_visited', result, current_timestamp, current_timestamp) ;
  RETURN result;
END;

$$;


--
-- Name: admin_insert_cl_visited_stats_v2(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_insert_cl_visited_stats_v2() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$

DECLARE
  result jsonb;
BEGIN
  SELECT admin_select_cl_visited_stats_V2() ||
        admin_select_cl_visited_stats_V2('3 days') ||
        admin_select_cl_visited_stats_V2('1 month') ||
        admin_select_cl_visited_stats_V2(NULL, 'discovery') ||
        admin_select_cl_visited_stats_V2('3 days', 'discovery') ||
        admin_select_cl_visited_stats_V2('1 month', 'discovery')
        INTO result;

  INSERT INTO admin_dashboard_stats (stat_type, data, created_at, updated_at)
    VALUES ('cl_visited', result, current_timestamp, current_timestamp) ;
  RETURN result;
END;

$$;


--
-- Name: admin_insert_cl_visited_stats_v3(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_insert_cl_visited_stats_v3() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$

   DECLARE
     result jsonb;
   BEGIN
     SELECT admin_select_cl_visited_stats_V3() ||
           admin_select_cl_visited_stats_V3('3 days') ||
           admin_select_cl_visited_stats_V3('1 month') ||
           admin_select_cl_visited_stats_V3(NULL, 'discovery') ||
           admin_select_cl_visited_stats_V3('3 days', 'discovery') ||
           admin_select_cl_visited_stats_V3('1 month', 'discovery')
           INTO result;

     INSERT INTO admin_dashboard_stats (stat_type, data, created_at, updated_at)
       VALUES ('cl_visited', result, current_timestamp, current_timestamp) ;
     RETURN result;
   END;

   $$;


--
-- Name: admin_select_cl_visited_stats(character varying); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_select_cl_visited_stats(interval_span character varying DEFAULT NULL::character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$

    DECLARE
      result jsonb;
      columnName varchar ;
      query varchar ;
    BEGIN
      columnName := '_' || COALESCE(REPLACE($1, ' ', ''), 'all') ;
      query :=
      'SELECT array_to_json(array_agg(row_to_json(t))) FROM (
      SELECT  count(*) as ' || columnName ||
                ' FROM code_sets
                INNER JOIN code_locations ON code_locations.best_code_set_id = code_sets.id
                LEFT OUTER JOIN (SELECT DISTINCT enlistments.code_location_id, enlistments.deleted FROM enlistments
                    WHERE enlistments.deleted = false) e1 ON e1.code_location_id = code_locations.id
                WHERE (COALESCE(code_sets.logged_at, ''1970-01-01'') +
                  code_locations.update_interval * INTERVAL ''1 second''
                  <= NOW() AT TIME ZONE ''utc'')
                AND ( (code_locations.status = 0  AND e1.deleted = false) OR code_locations.status = 1) ' ;

      IF $1 IS NOT NULL THEN
        query := query || ' AND logged_at > now() - interval ''' || ($1)::interval || '''' ;
      ELSE
        query := query || ' AND code_locations.do_not_fetch = false' ;
      END IF ;

      query := query || ' )t' ;

      EXECUTE query INTO result;
      RETURN result;
    END;

  $_$;


--
-- Name: admin_select_cl_visited_stats_v2(character varying, character varying); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_select_cl_visited_stats_v2(interval_span character varying DEFAULT NULL::character varying, registration_key character varying DEFAULT NULL::character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$

      DECLARE
         result jsonb;
         columnName varchar := '';
         query varchar ;
         client_name varchar ;
      BEGIN
         client_name := $2 ;

         IF client_name IS NOT NULL THEN
         columnName := '_kb' ;
         END IF ;

        columnName := columnName || '_' || COALESCE(REPLACE($1, ' ', ''), 'all') ;

        query :=
          'SELECT array_to_json(array_agg(row_to_json(t))) FROM (
            SELECT  count(*) as ' || columnName ||
                    ' FROM code_sets
                    INNER JOIN code_locations ON code_locations.best_code_set_id = code_sets.id
                    INNER JOIN (SELECT DISTINCT sub.code_location_id FROM subscriptions sub ' ;

        IF client_name IS NOT NULL THEN
          query = query || ' INNER JOIN registration_keys reg ON reg.id = sub.registration_key_id
              AND reg.client_name = ''' || client_name || '''' ;
        END IF ;

        query = query || ') e1 ON e1.code_location_id = code_locations.id ' ;

        IF $1 IS NOT NULL THEN
          query := query || ' AND logged_at > NOW() - interval ''' || ($1)::interval || '''' ;
        ELSE
          query := query || ' AND code_locations.do_not_fetch = false' ;
        END IF ;

        query := query || ' )t' ;

        RAISE NOTICE 'query: %', query ;
        EXECUTE query INTO result;
        RETURN result;
      END;

     $_$;


--
-- Name: admin_select_cl_visited_stats_v3(character varying, character varying); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_select_cl_visited_stats_v3(interval_span character varying DEFAULT NULL::character varying, registration_key character varying DEFAULT NULL::character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$

         DECLARE
            result jsonb;
            columnName varchar := '';
            query varchar ;
            client_name varchar ;
         BEGIN
            client_name := $2 ;

            IF client_name IS NOT NULL THEN
            columnName := '_kb' ;
            END IF ;

           columnName := columnName || '_' || COALESCE(REPLACE($1, ' ', ''), 'all') ;

           query :=
             'SELECT array_to_json(array_agg(row_to_json(t))) FROM (
               SELECT  count(*) as ' || columnName ||
                       ' FROM code_sets
                       INNER JOIN code_locations ON code_locations.best_code_set_id = code_sets.id
                             INNER JOIN jobs j ON j.id = code_locations.last_job_id
                       INNER JOIN (SELECT DISTINCT sub.code_location_id FROM subscriptions sub ' ;

           IF client_name IS NOT NULL THEN
             query = query || ' INNER JOIN registration_keys reg ON reg.id = sub.registration_key_id
                 AND reg.client_name = ''' || client_name || '''' ;
           END IF ;

           query = query || ') e1 ON e1.code_location_id = code_locations.id ' ;

           IF $1 IS NOT NULL THEN
             query := query || ' AND COALESCE(j.current_step_at, NOW()) >
                                  NOW() - interval ''' || ($1)::interval || '''' ;
           ELSE
             query := query || ' AND code_locations.do_not_fetch = false' ;
           END IF ;

           query := query || ' )t' ;

           RAISE NOTICE 'query: %', query ;
           EXECUTE query INTO result;
           RETURN result;
         END;

        $_$;


--
-- Name: admin_select_kb_cl_visited_stats(character varying); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.admin_select_kb_cl_visited_stats(interval_span character varying DEFAULT NULL::character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$

      DECLARE
        result jsonb;
        columnName varchar ;
        query varchar ;
      BEGIN
        columnName := '_kb_' || COALESCE(REPLACE($1, ' ', ''), 'all') ;
        query :=
        'SELECT array_to_json(array_agg(row_to_json(t))) FROM (
        SELECT  count(*) as ' || columnName ||
                    ' FROM code_sets
                    INNER JOIN code_locations ON code_locations.best_code_set_id = code_sets.id
                    WHERE (COALESCE(code_sets.logged_at, ''1970-01-01'') +
                      code_locations.update_interval * INTERVAL ''1 second''
                      <= NOW() AT TIME ZONE ''utc'')
                    AND (code_locations.status = 1) ' ;

        IF $1 IS NOT NULL THEN
          query := query || ' AND logged_at > now() - interval ''' || ($1)::interval || '''' ;
        ELSE
          query := query || ' AND code_locations.do_not_fetch = false' ;
        END IF ;

        query := query || ' )t' ;

        EXECUTE query INTO result;
        RETURN result;
      END;

      $_$;


--
-- Name: analysis_aliases_id_seq_view(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.analysis_aliases_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from analysis_aliases_id_seq_view$$;


--
-- Name: analysis_sloc_sets_id_seq_view(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.analysis_sloc_sets_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from analysis_sloc_sets_id_seq_view$$;


--
-- Name: check_jobs(integer); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.check_jobs(integer) RETURNS integer
    LANGUAGE sql
    AS $_$select repository_id as RESULT from jobs where status != 5 AND  repository_id= $1;$_$;


--
-- Name: code_location_tarballs_id_seq_view(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.code_location_tarballs_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from code_location_tarballs_id_seq_view$$;


--
-- Name: code_sets_id_seq_view(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.code_sets_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from code_sets_id_seq_view$$;


--
-- Name: commit_flags_id_seq_view(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.commit_flags_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from commit_flags_id_seq_view$$;


--
-- Name: delete_old_code_sets(smallint, boolean); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.delete_old_code_sets(smallint, boolean) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$

      DECLARE
         result jsonb ;
         message varchar ;
         query varchar ;
         rollback boolean ;
         num_selected integer ;
         num_limit integer ;
       BEGIN
       num_limit = $1 ;
       rollback = $2 ;

         RAISE NOTICE 'Limit set to % and rollback set to %', num_limit, rollback::text ;

         CREATE TEMPORARY TABLE temp_messages (
            message varchar
         ) ;

         CREATE TEMPORARY TABLE temp_code_sets (
             id integer
         ) ;

         CREATE TEMPORARY TABLE temp_commit_diffs (
             diff_id bigint,
             commit_id integer
         ) ;

          INSERT INTO temp_code_sets (id)
           SELECT code_sets.id
           FROM code_sets
           INNER JOIN code_locations cl ON code_sets.code_location_id = cl.id
           INNER JOIN code_sets cs_best ON cl.best_code_set_id = cs_best.id
           WHERE code_sets.id <> cl.best_code_set_id
             AND COALESCE(code_sets.logged_at, code_sets.updated_on)
                 < COALESCE(cs_best.logged_at, cs_best.updated_on)
			 AND code_sets.id NOT IN
			 	(SELECT distinct j.code_set_id FROM jobs j
				 WHERE j.status <> 5 AND j.code_set_id IS NOT NULL)
		   Limit num_limit ;

         GET DIAGNOSTICS num_selected = row_count;
         RAISE NOTICE 'Selected %s code_sets', num_selected ;
         INSERT INTO temp_messages VALUES
           (FORMAT('Selected %s code_sets', num_selected))  ;

         --DELETE FROM temp_code_sets
         --WHERE id IN
         --  (SELECT tcs.id
         --     FROM temp_code_sets tcs
         --     INNER JOIN jobs j ON tcs.id = j.code_set_id
         --    WHERE j.status <> 5) ;

          GET DIAGNOSTICS num_selected = row_count;
          RAISE NOTICE 'Deleted %s incomplete jobs', num_selected ;
          INSERT INTO temp_messages VALUES
           (FORMAT('Deleted %s incomplete jobs', num_selected))  ;

         CREATE INDEX ON temp_code_sets (id) ;

         INSERT INTO temp_commit_diffs (commit_id)
         SELECT commit.id commit_id
         from commits commit
         WHERE commit.code_set_id IN
                    (SELECT id FROM temp_code_sets)  ;

         GET DIAGNOSTICS num_selected = row_count;
         RAISE NOTICE 'Selected %s commits', num_selected ;
         INSERT INTO temp_messages VALUES
            (FORMAT('Selected %s commits', num_selected))  ;


         INSERT INTO temp_commit_diffs (diff_id, commit_id)
         SELECT diff.id diff_id, diff.commit_id
            FROM Diffs diff
         WHERE diff.commit_id IN
            (SELECT commit_id FROM temp_commit_diffs) ;

         GET DIAGNOSTICS num_selected = row_count;
         RAISE NOTICE 'Selected %s diffs', num_selected ;
         INSERT INTO temp_messages VALUES
              (FORMAT('Selected %s diffs', num_selected))  ;

         CREATE INDEX ON temp_commit_diffs (commit_id);
         CREATE INDEX ON temp_commit_diffs (diff_id) ;

         INSERT INTO temp_messages VALUES
           (FORMAT('temporary tables created')) ;
         RAISE NOTICE 'temporary tables created' ;

         SET session_replication_role TO replica ;

         DELETE FROM slave_logs
         WHERE code_set_id IN
           (SELECT id FROM temp_code_sets) ;
         GET DIAGNOSTICS num_selected = row_count;

         RAISE NOTICE 'slave_logs deleted %s records', num_selected ;
         INSERT INTO temp_messages VALUES
           (FORMAT('slave_logs deleted %s records', num_selected)) ;

         DELETE FROM analysis_sloc_sets
         WHERE id IN
             (SELECT ass.id
             FROM analysis_sloc_sets ass
             INNER JOIN sloc_sets ss ON ass.sloc_set_id = ss.id
             WHERE ss.code_set_id IN (SELECT id from temp_code_sets ));
         GET DIAGNOSTICS num_selected = row_count;
         RAISE NOTICE 'analysis_sloc_sets deleted %s records', num_selected ;
         INSERT INTO temp_messages VALUES
           (FORMAT('analysis_sloc_sets deleted %s records', num_selected)) ;

         DELETE FROM sloc_sets
         WHERE code_set_id IN
          (SELECT id from temp_code_sets ) ;
         GET DIAGNOSTICS num_selected = row_count;
         RAISE NOTICE 'sloc_sets deleted %s records', num_selected ;
         INSERT INTO temp_messages VALUES
           (FORMAT('sloc_sets deleted %s records', num_selected)) ;

         DELETE FROM fyles
         WHERE code_set_id IN
          (SELECT id from temp_code_sets ) ;
        GET DIAGNOSTICS num_selected = row_count;
        RAISE NOTICE 'fyles deleted %s records', num_selected ;
        INSERT INTO temp_messages VALUES
          (FORMAT('fyles deleted %s records', num_selected));

        DELETE FROM diffs
        WHERE diffs.id IN
          (SELECT diff_id FROM temp_commit_diffs) ;
        GET DIAGNOSTICS num_selected = row_count;
        RAISE NOTICE 'diffs deleted %s records', num_selected ;
        INSERT INTO temp_messages VALUES
           (FORMAT('diffs deleted %s records', num_selected)) ;

        DELETE FROM commits
        WHERE code_set_id IN
          (SELECT id FROM temp_code_sets) ;
        GET DIAGNOSTICS num_selected = row_count;
        RAISE NOTICE 'commits deleted %s records', num_selected ;
        INSERT INTO temp_messages VALUES
           (FORMAT('commits deleted %s records', num_selected)) ;

        DELETE FROM code_sets
        WHERE id IN
          (SELECT id FROM temp_code_sets) ;
        GET DIAGNOSTICS num_selected = row_count;
        RAISE NOTICE 'commits deleted % records', num_selected ;
        INSERT INTO temp_messages VALUES
           (FORMAT('code_sets deleted %s records', num_selected)) ;

        INSERT INTO old_code_sets (code_set_id, created_at, updated_at)
        SELECT id as code_set_id, now() as created_at, now() as updated_at
          FROM temp_code_sets ;

        GET DIAGNOSTICS num_selected = row_count;
        RAISE NOTICE 'old_code_sets inserted %s records', num_selected ;
        INSERT INTO temp_messages VALUES
           (FORMAT('old_code_sets inserted %s records', num_selected)) ;

        SET session_replication_role TO default ;

        DROP TABLE temp_code_sets ;
        DROP TABLE temp_commit_diffs ;

        INSERT INTO temp_messages VALUES
           ('dropped temp tables') ;

      IF rollback THEN
        RAISE NOTICE 'rollback is set';

        query := 'SELECT array_to_json(array_agg(row_to_json(row)))
        FROM (SELECT message FROM temp_messages) row' ;
        EXECUTE query INTO result;

        DROP TABLE temp_messages ;
        RAISE EXCEPTION 'rolling back --> %', result::text ;
      END IF ;

      INSERT INTO temp_messages VALUES
        ('done') ;
      RAISE NOTICE 'done' ;

      query := 'SELECT array_to_json(array_agg(row_to_json(row)))
      FROM (SELECT message FROM temp_messages) row' ;
      EXECUTE query INTO result;

      DROP TABLE temp_messages ;
      RETURN result ;
     END;

$_$;


--
-- Name: email_addresses_id_seq_view(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.email_addresses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from email_addresses_id_seq_view$$;


--
-- Name: explain_this(text); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.explain_this(l_query text, OUT explain json) RETURNS SETOF json
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY EXECUTE 'explain (format json) ' || l_query;
END;
$$;


--
-- Name: failure_groups_id_seq_view(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.failure_groups_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from failure_groups_id_seq_view$$;


--
-- Name: fisbot_events_id_seq_view(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.fisbot_events_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from fisbot_events_id_seq_view$$;


--
-- Name: jobs_id_seq_view(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.jobs_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from jobs_id_seq_view$$;


--
-- Name: load_averages_id_seq_view(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.load_averages_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from load_averages_id_seq_view$$;


--
-- Name: slave_logs_id_seq_view(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.slave_logs_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from slave_logs_id_seq_view$$;


--
-- Name: slave_permissions_id_seq_view(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.slave_permissions_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from slave_permissions_id_seq_view$$;


--
-- Name: sloc_sets_id_seq_view(); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.sloc_sets_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from sloc_sets_id_seq_view$$;


--
-- Name: ts_debug(text); Type: FUNCTION; Schema: fis; Owner: -
--

CREATE FUNCTION fis.ts_debug(text) RETURNS SETOF fis.tsdebug
    LANGUAGE sql STRICT
    AS $_$
select
        m.ts_name,
        t.alias as tok_type,
        t.descr as description,
        p.token,
        m.dict_name,
        strip(to_tsvector(p.token)) as tsvector
from
        parse( _get_parser_from_curcfg(), $1 ) as p,
        token_type() as t,
        pg_ts_cfgmap as m,
        pg_ts_cfg as c
where
        t.tokid=p.tokid and
        t.alias = m.tok_alias and
        m.ts_name=c.ts_name and
        c.oid=show_curcfg()
$_$;


--
-- Name: _get_parser_from_curcfg(); Type: FUNCTION; Schema: oh; Owner: -
--

CREATE FUNCTION oh._get_parser_from_curcfg() RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ select prs_name from pg_ts_cfg where oid = show_curcfg() $$;


--
-- Name: check_jobs(integer); Type: FUNCTION; Schema: oh; Owner: -
--

CREATE FUNCTION oh.check_jobs(integer) RETURNS integer
    LANGUAGE sql
    AS $_$select repository_id as RESULT from jobs where status != 5 AND  repository_id= $1;$_$;


--
-- Name: ts_debug(text); Type: FUNCTION; Schema: oh; Owner: -
--

CREATE FUNCTION oh.ts_debug(text) RETURNS SETOF oh.tsdebug
    LANGUAGE sql STRICT
    AS $_$
select
        m.ts_name,
        t.alias as tok_type,
        t.descr as description,
        p.token,
        m.dict_name,
        strip(to_tsvector(p.token)) as tsvector
from
        parse( _get_parser_from_curcfg(), $1 ) as p,
        token_type() as t,
        pg_ts_cfgmap as m,
        pg_ts_cfg as c
where
        t.tokid=p.tokid and
        t.alias = m.tok_alias and
        m.ts_name=c.ts_name and
        c.oid=show_curcfg()
$_$;


--
-- Name: <; Type: OPERATOR; Schema: fis; Owner: -
--

CREATE OPERATOR fis.< (
    FUNCTION = tsvector_lt,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(pg_catalog.>),
    NEGATOR = OPERATOR(pg_catalog.>=),
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: <=; Type: OPERATOR; Schema: fis; Owner: -
--

CREATE OPERATOR fis.<= (
    FUNCTION = tsvector_le,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(pg_catalog.>=),
    NEGATOR = OPERATOR(pg_catalog.>),
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: <>; Type: OPERATOR; Schema: fis; Owner: -
--

CREATE OPERATOR fis.<> (
    FUNCTION = tsvector_ne,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(pg_catalog.<>),
    NEGATOR = OPERATOR(pg_catalog.=),
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);


--
-- Name: =; Type: OPERATOR; Schema: fis; Owner: -
--

CREATE OPERATOR fis.= (
    FUNCTION = tsvector_eq,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(pg_catalog.=),
    NEGATOR = OPERATOR(fis.<>),
    MERGES,
    RESTRICT = eqsel,
    JOIN = eqjoinsel
);


--
-- Name: >; Type: OPERATOR; Schema: fis; Owner: -
--

CREATE OPERATOR fis.> (
    FUNCTION = tsvector_gt,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(fis.<),
    NEGATOR = OPERATOR(fis.<=),
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: >=; Type: OPERATOR; Schema: fis; Owner: -
--

CREATE OPERATOR fis.>= (
    FUNCTION = tsvector_ge,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(fis.<=),
    NEGATOR = OPERATOR(fis.<),
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: <; Type: OPERATOR; Schema: oh; Owner: -
--

CREATE OPERATOR oh.< (
    FUNCTION = tsvector_lt,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(pg_catalog.>),
    NEGATOR = OPERATOR(pg_catalog.>=),
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: <=; Type: OPERATOR; Schema: oh; Owner: -
--

CREATE OPERATOR oh.<= (
    FUNCTION = tsvector_le,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(pg_catalog.>=),
    NEGATOR = OPERATOR(pg_catalog.>),
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: <>; Type: OPERATOR; Schema: oh; Owner: -
--

CREATE OPERATOR oh.<> (
    FUNCTION = tsvector_ne,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(pg_catalog.<>),
    NEGATOR = OPERATOR(pg_catalog.=),
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);


--
-- Name: =; Type: OPERATOR; Schema: oh; Owner: -
--

CREATE OPERATOR oh.= (
    FUNCTION = tsvector_eq,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(pg_catalog.=),
    NEGATOR = OPERATOR(oh.<>),
    MERGES,
    RESTRICT = eqsel,
    JOIN = eqjoinsel
);


--
-- Name: >; Type: OPERATOR; Schema: oh; Owner: -
--

CREATE OPERATOR oh.> (
    FUNCTION = tsvector_gt,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(oh.<),
    NEGATOR = OPERATOR(oh.<=),
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: >=; Type: OPERATOR; Schema: oh; Owner: -
--

CREATE OPERATOR oh.>= (
    FUNCTION = tsvector_ge,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(oh.<=),
    NEGATOR = OPERATOR(oh.<),
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: default; Type: TEXT SEARCH CONFIGURATION; Schema: fis; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION fis."default" (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR asciiword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR word WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR hword_part WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR hword_asciipart WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR asciihword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR hword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis."default"
    ADD MAPPING FOR uint WITH simple;


--
-- Name: pg; Type: TEXT SEARCH CONFIGURATION; Schema: fis; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION fis.pg (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR asciiword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR word WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR hword_part WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR hword_asciipart WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR asciihword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR hword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION fis.pg
    ADD MAPPING FOR uint WITH simple;


--
-- Name: default; Type: TEXT SEARCH CONFIGURATION; Schema: oh; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION oh."default" (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR asciiword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR word WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR hword_part WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR hword_asciipart WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR asciihword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR hword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh."default"
    ADD MAPPING FOR uint WITH simple;


--
-- Name: pg; Type: TEXT SEARCH CONFIGURATION; Schema: oh; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION oh.pg (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR asciiword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR word WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR hword_part WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR hword_asciipart WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR asciihword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR hword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION oh.pg
    ADD MAPPING FOR uint WITH simple;


SET default_tablespace = '';

--
-- Name: admin_dashboard_stats; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.admin_dashboard_stats (
    id integer NOT NULL,
    stat_type character varying,
    data jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_dashboard_stats_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.admin_dashboard_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_dashboard_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.admin_dashboard_stats_id_seq OWNED BY fis.admin_dashboard_stats.id;


--
-- Name: analysis_aliases; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.analysis_aliases (
    id bigint NOT NULL,
    analysis_id integer NOT NULL,
    commit_name_id integer NOT NULL,
    preferred_name_id integer NOT NULL
);


--
-- Name: analysis_aliases_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.analysis_aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analysis_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.analysis_aliases_id_seq OWNED BY fis.analysis_aliases.id;


--
-- Name: analysis_sloc_sets_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.analysis_sloc_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analysis_sloc_sets; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.analysis_sloc_sets (
    id integer DEFAULT nextval('fis.analysis_sloc_sets_id_seq'::regclass) NOT NULL,
    analysis_id integer NOT NULL,
    sloc_set_id integer NOT NULL,
    as_of integer,
    code_set_time timestamp without time zone,
    ignore text,
    ignored_fyle_count integer,
    allowed_fyles text,
    allowed_fyle_count integer
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: code_location_dnfs; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.code_location_dnfs (
    id integer NOT NULL,
    code_location_id integer,
    job_id bigint,
    exception text,
    retry_count integer,
    comments text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: code_location_dnfs_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.code_location_dnfs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_location_dnfs_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.code_location_dnfs_id_seq OWNED BY fis.code_location_dnfs.id;


--
-- Name: code_location_job_feeders; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.code_location_job_feeders (
    id integer NOT NULL,
    code_location_id integer,
    url text,
    status integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: code_location_job_feeders_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.code_location_job_feeders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_location_job_feeders_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.code_location_job_feeders_id_seq OWNED BY fis.code_location_job_feeders.id;


--
-- Name: code_location_tarballs; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.code_location_tarballs (
    id integer NOT NULL,
    code_location_id integer,
    reference text,
    filepath text,
    status integer DEFAULT 0,
    created_at timestamp without time zone,
    type text
);


--
-- Name: code_location_tarballs_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.code_location_tarballs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_location_tarballs_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.code_location_tarballs_id_seq OWNED BY fis.code_location_tarballs.id;


--
-- Name: code_locations; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.code_locations (
    id integer NOT NULL,
    repository_id integer,
    module_branch_name text,
    best_code_set_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    update_interval integer DEFAULT 3600,
    best_repository_directory_id integer,
    do_not_fetch boolean DEFAULT false,
    last_job_id integer,
    cl_update_event_time timestamp without time zone,
    is_important boolean DEFAULT false
);


--
-- Name: code_locations_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.code_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.code_locations_id_seq OWNED BY fis.code_locations.id;


--
-- Name: code_sets_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.code_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_sets; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.code_sets (
    id integer DEFAULT nextval('fis.code_sets_id_seq'::regclass) NOT NULL,
    updated_on timestamp without time zone,
    best_sloc_set_id integer,
    as_of integer,
    logged_at timestamp without time zone,
    clump_count integer DEFAULT 0,
    fetched_at timestamp without time zone,
    code_location_id integer
);


--
-- Name: sloc_sets_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.sloc_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sloc_sets; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.sloc_sets (
    id integer DEFAULT nextval('fis.sloc_sets_id_seq'::regclass) NOT NULL,
    code_set_id integer NOT NULL,
    updated_on timestamp without time zone,
    as_of integer,
    code_set_time timestamp without time zone
);


--
-- Name: positions; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.positions (
    id integer NOT NULL,
    project_id integer,
    name_id integer,
    account_id integer NOT NULL,
    created_at timestamp without time zone,
    title text,
    organization_name text,
    description text,
    start_date timestamp without time zone,
    stop_date timestamp without time zone,
    ongoing boolean,
    organization_id integer,
    affiliation_type text DEFAULT 'unaffiliated'::text NOT NULL
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.projects (
    id integer DEFAULT nextval('oh.projects_id_seq'::regclass) NOT NULL,
    name text,
    description text,
    comments text,
    best_analysis_id integer,
    deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    old_name text,
    missing_source text,
    logo_id integer,
    vanity_url text,
    downloadable boolean DEFAULT false,
    scraped boolean DEFAULT false,
    vector tsvector,
    popularity_factor numeric,
    user_count integer DEFAULT 0 NOT NULL,
    rating_average real,
    forge_id integer,
    name_at_forge text,
    owner_at_forge text,
    active_committers integer DEFAULT 0,
    kb_id integer,
    organization_id integer,
    activity_level_index integer,
    uuid character varying,
    best_project_security_set_id integer,
    coverity_project_id integer,
    reported_at timestamp without time zone,
    CONSTRAINT valid_missing_source CHECK (((missing_source IS NULL) OR (missing_source = 'not available'::text) OR (missing_source = 'not supported'::text)))
);


--
-- Name: commit_contributors; Type: VIEW; Schema: fis; Owner: -
--

CREATE VIEW fis.commit_contributors AS
 SELECT analysis_aliases.commit_name_id AS id,
    sloc_sets.code_set_id,
    analysis_aliases.commit_name_id AS name_id,
    analysis_sloc_sets.analysis_id,
    projects.id AS project_id,
    positions.id AS position_id,
    positions.account_id,
        CASE
            WHEN (positions.account_id IS NULL) THEN ((((projects.id)::bigint << 32) + (analysis_aliases.preferred_name_id)::bigint) + ('10000000000000000000000000000000'::"bit")::bigint)
            ELSE (((projects.id)::bigint << 32) + (positions.account_id)::bigint)
        END AS contribution_id,
        CASE
            WHEN (positions.account_id IS NULL) THEN ((((projects.id)::bigint << 32) + (analysis_aliases.preferred_name_id)::bigint) + ('10000000000000000000000000000000'::"bit")::bigint)
            ELSE (positions.account_id)::bigint
        END AS person_id
   FROM ((((fis.analysis_sloc_sets
     JOIN fis.sloc_sets ON ((analysis_sloc_sets.sloc_set_id = sloc_sets.id)))
     JOIN oh.projects ON ((analysis_sloc_sets.analysis_id = projects.best_analysis_id)))
     JOIN fis.analysis_aliases ON ((analysis_aliases.analysis_id = analysis_sloc_sets.analysis_id)))
     LEFT JOIN oh.positions ON (((positions.project_id = projects.id) AND (positions.name_id = analysis_aliases.preferred_name_id))));


--
-- Name: commit_flags; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.commit_flags (
    id integer NOT NULL,
    sloc_set_id integer NOT NULL,
    commit_id integer NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type text NOT NULL,
    data text
);


--
-- Name: commit_flags_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.commit_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commit_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.commit_flags_id_seq OWNED BY fis.commit_flags.id;


--
-- Name: commits_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.commits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commits; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.commits (
    id bigint DEFAULT nextval('fis.commits_id_seq'::regclass) NOT NULL,
    sha1 text,
    "time" timestamp without time zone NOT NULL,
    comment text,
    code_set_id integer NOT NULL,
    name_id integer NOT NULL,
    "position" integer,
    on_trunk boolean DEFAULT true,
    email_address_id integer
)
WITH (autovacuum_analyze_scale_factor='0.001', autovacuum_vacuum_scale_factor='0.0005');


--
-- Name: deleted_subscriptions_code_locations; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.deleted_subscriptions_code_locations (
    code_location_id integer NOT NULL
);


--
-- Name: diffs_orig_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.diffs_orig_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: diffs; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
)
PARTITION BY HASH (code_set_id);


--
-- Name: diffs_0; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_0 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_1; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_1 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_10; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_10 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_11; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_11 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_12; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_12 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_13; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_13 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_14; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_14 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_15; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_15 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_16; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_16 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_17; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_17 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_18; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_18 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_19; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_19 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_2; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_2 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_20; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_20 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_21; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_21 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_22; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_22 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_23; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_23 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_24; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_24 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_25; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_25 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_26; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_26 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_27; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_27 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_28; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_28 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_29; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_29 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_3; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_3 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_30; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_30 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_31; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_31 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_32; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_32 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_33; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_33 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_34; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_34 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_35; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_35 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_36; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_36 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_37; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_37 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_38; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_38 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_39; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_39 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_4; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_4 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_40; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_40 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_41; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_41 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_42; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_42 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_43; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_43 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_44; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_44 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_45; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_45 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_46; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_46 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_47; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_47 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_48; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_48 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_49; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_49 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_5; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_5 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_50; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_50 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_51; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_51 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_52; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_52 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_53; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_53 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_54; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_54 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_55; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_55 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_56; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_56 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_57; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_57 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_58; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_58 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_59; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_59 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_6; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_6 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_60; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_60 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_61; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_61 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_62; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_62 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_63; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_63 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_64; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_64 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_65; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_65 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_66; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_66 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_67; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_67 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_68; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_68 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_69; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_69 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_7; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_7 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_70; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_70 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_71; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_71 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_72; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_72 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_73; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_73 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_74; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_74 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_75; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_75 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_76; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_76 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_77; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_77 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_78; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_78 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_79; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_79 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_8; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_8 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_80; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_80 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_81; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_81 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_82; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_82 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_83; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_83 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_84; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_84 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_85; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_85 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_86; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_86 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_87; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_87 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_88; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_88 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_89; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_89 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_9; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_9 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_90; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_90 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_91; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_91 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_92; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_92 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_93; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_93 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_94; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_94 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_95; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_95 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_96; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_96 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_97; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_97 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_98; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_98 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_99; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_99 (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    code_set_id bigint
);


--
-- Name: diffs_orig; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.diffs_orig (
    id bigint DEFAULT nextval('fis.diffs_orig_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id bigint,
    fyle_id bigint,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
)
WITH (autovacuum_analyze_scale_factor='0.0002', autovacuum_vacuum_scale_factor='0.0005');


--
-- Name: dnf_code_locations; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.dnf_code_locations (
    code_location_id integer NOT NULL
);


--
-- Name: email_addresses; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.email_addresses (
    id integer NOT NULL,
    address text NOT NULL
);


--
-- Name: email_addresses_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.email_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.email_addresses_id_seq OWNED BY fis.email_addresses.id;


--
-- Name: failure_groups; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.failure_groups (
    id integer NOT NULL,
    name text NOT NULL,
    pattern text NOT NULL,
    priority integer DEFAULT 0,
    auto_reschedule boolean DEFAULT false
);


--
-- Name: failure_groups_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.failure_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failure_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.failure_groups_id_seq OWNED BY fis.failure_groups.id;


--
-- Name: fg_232_code_locations; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.fg_232_code_locations (
    code_location_id integer NOT NULL
);


--
-- Name: fisbot_events; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.fisbot_events (
    id integer NOT NULL,
    code_location_id integer,
    type text NOT NULL,
    value text,
    commit_sha1 text,
    status boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    repository_id integer,
    component_id integer
);


--
-- Name: fisbot_events_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.fisbot_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fisbot_events_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.fisbot_events_id_seq OWNED BY fis.fisbot_events.id;


--
-- Name: forges_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.forges_id_seq
    START WITH 8
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forges; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.forges (
    id integer DEFAULT nextval('fis.forges_id_seq'::regclass) NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    type text
);


--
-- Name: fyles_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.fyles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fyles; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.fyles (
    id bigint DEFAULT nextval('fis.fyles_id_seq'::regclass) NOT NULL,
    name text NOT NULL,
    code_set_id integer NOT NULL
)
WITH (autovacuum_analyze_scale_factor='0.001', autovacuum_vacuum_scale_factor='0.0005');


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.jobs_id_seq
    START WITH 390996709
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.jobs (
    id bigint DEFAULT nextval('fis.jobs_id_seq'::regclass) NOT NULL,
    project_id integer,
    status integer DEFAULT 0 NOT NULL,
    type text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    current_step integer,
    current_step_at timestamp without time zone,
    max_steps integer,
    exception text,
    backtrace text,
    code_set_id integer,
    sloc_set_id integer,
    notes text,
    wait_until timestamp without time zone,
    account_id integer,
    logged_at timestamp without time zone,
    slave_id integer,
    started_at timestamp without time zone,
    retry_count integer DEFAULT 0,
    do_not_retry boolean DEFAULT false,
    failure_group_id integer,
    organization_id integer,
    code_location_id integer,
    code_location_tarball_id integer,
    is_expensive boolean DEFAULT false
)
WITH (autovacuum_analyze_scale_factor='0.0005', autovacuum_vacuum_scale_factor='0.001');


--
-- Name: load_averages; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.load_averages (
    current numeric DEFAULT 0.0,
    id integer NOT NULL,
    max numeric DEFAULT 3.0
);


--
-- Name: load_averages_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.load_averages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: load_averages_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.load_averages_id_seq OWNED BY fis.load_averages.id;


--
-- Name: locations; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.locations (
    id integer,
    status integer,
    do_not_fetch boolean,
    update_interval integer,
    best_code_set_id integer
);


--
-- Name: m_enlistments; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.m_enlistments (
    code_location_id integer,
    deleted boolean
);


--
-- Name: new_subscriptions_code_locations; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.new_subscriptions_code_locations (
    code_location_id integer NOT NULL
);


--
-- Name: old_code_sets; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.old_code_sets (
    id integer NOT NULL,
    code_set_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: old_code_sets_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.old_code_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: old_code_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.old_code_sets_id_seq OWNED BY fis.old_code_sets.id;


--
-- Name: queued_jobs; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.queued_jobs (
    job_id integer NOT NULL,
    queue_name character varying
);


--
-- Name: registration_keys; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.registration_keys (
    id uuid DEFAULT fis.uuid_generate_v4() NOT NULL,
    client_name text NOT NULL,
    description text
);


--
-- Name: repositories_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.repositories_id_seq
    START WITH 821423
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.repositories (
    id integer DEFAULT nextval('fis.repositories_id_seq'::regclass) NOT NULL,
    url text,
    forge_id integer,
    username text,
    password text,
    type text NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    updated_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    update_interval integer DEFAULT 3600,
    name_at_forge text,
    owner_at_forge text,
    best_repository_directory_id integer
);


--
-- Name: repository_directories; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.repository_directories (
    id integer NOT NULL,
    code_location_id integer,
    repository_id integer,
    fetched_at timestamp without time zone
);


--
-- Name: repository_directories_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.repository_directories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repository_directories_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.repository_directories_id_seq OWNED BY fis.repository_directories.id;


--
-- Name: repository_tags; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.repository_tags (
    id integer NOT NULL,
    repository_id integer,
    name text,
    commit_sha1 text,
    message text,
    "timestamp" timestamp without time zone
);


--
-- Name: repository_tags_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.repository_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repository_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.repository_tags_id_seq OWNED BY fis.repository_tags.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: slave_logs_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.slave_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slave_logs; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.slave_logs (
    id bigint DEFAULT nextval('fis.slave_logs_id_seq'::regclass) NOT NULL,
    message text,
    created_on timestamp without time zone,
    slave_id integer,
    job_id integer,
    code_set_id integer,
    level integer DEFAULT 0
);


--
-- Name: slave_logs_old; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.slave_logs_old (
    id integer,
    message text,
    created_on timestamp without time zone,
    slave_id integer,
    job_id integer,
    code_set_id integer,
    level integer
);


--
-- Name: slave_permissions_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.slave_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slaves; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.slaves (
    id integer DEFAULT nextval('fis.slave_permissions_id_seq'::regclass) NOT NULL,
    allow_deny text,
    hostname text NOT NULL,
    available_blocks integer,
    used_blocks integer,
    used_percent integer,
    updated_at timestamp without time zone,
    load_average numeric,
    clump_dir text,
    clump_status text,
    oldest_clump_timestamp timestamp without time zone,
    enable_profiling boolean DEFAULT false,
    blocked_types text,
    queue_name character varying
);


--
-- Name: sloc_metrics_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.sloc_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sloc_metrics; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.sloc_metrics (
    id bigint DEFAULT nextval('fis.sloc_metrics_id_seq'::regclass) NOT NULL,
    diff_id bigint,
    language_id integer,
    code_added integer DEFAULT 0 NOT NULL,
    code_removed integer DEFAULT 0 NOT NULL,
    comments_added integer DEFAULT 0 NOT NULL,
    comments_removed integer DEFAULT 0 NOT NULL,
    blanks_added integer DEFAULT 0 NOT NULL,
    blanks_removed integer DEFAULT 0 NOT NULL,
    sloc_set_id integer NOT NULL
)
WITH (autovacuum_analyze_scale_factor='0.0005', autovacuum_vacuum_scale_factor='0.001');


--
-- Name: subscriptions; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.subscriptions (
    id integer NOT NULL,
    code_location_id integer NOT NULL,
    registration_key_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    client_relation_id integer
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.subscriptions_id_seq OWNED BY fis.subscriptions.id;


--
-- Name: users; Type: TABLE; Schema: fis; Owner: -
--

CREATE TABLE fis.users (
    id integer NOT NULL,
    level integer DEFAULT 0,
    email character varying NOT NULL,
    activated boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    encrypted_password character varying(128) NOT NULL,
    confirmation_token character varying(128),
    remember_token character varying(128) NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: fis; Owner: -
--

CREATE SEQUENCE fis.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: fis; Owner: -
--

ALTER SEQUENCE fis.users_id_seq OWNED BY fis.users.id;


--
-- Name: failure_groups; Type: TABLE; Schema: oa; Owner: -
--

CREATE TABLE oa.failure_groups (
    id bigint NOT NULL,
    name text NOT NULL,
    pattern text NOT NULL,
    priority integer DEFAULT 0,
    auto_reschedule boolean DEFAULT false
);


--
-- Name: failure_groups_id_seq; Type: SEQUENCE; Schema: oa; Owner: -
--

CREATE SEQUENCE oa.failure_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failure_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: oa; Owner: -
--

ALTER SEQUENCE oa.failure_groups_id_seq OWNED BY oa.failure_groups.id;


--
-- Name: jobs; Type: TABLE; Schema: oa; Owner: -
--

CREATE TABLE oa.jobs (
    id bigint NOT NULL,
    project_id integer,
    status integer DEFAULT 0 NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    current_step integer,
    max_steps integer,
    account_id integer,
    worker_id integer,
    retry_count integer DEFAULT 0,
    failure_group_id integer,
    organization_id integer,
    do_not_retry boolean DEFAULT false,
    is_expensive boolean DEFAULT false,
    type text NOT NULL,
    exception text,
    backtrace text,
    notes text,
    current_step_at timestamp without time zone,
    wait_until timestamp without time zone,
    logged_at timestamp without time zone,
    started_at timestamp without time zone
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: oa; Owner: -
--

CREATE SEQUENCE oa.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: oa; Owner: -
--

ALTER SEQUENCE oa.jobs_id_seq OWNED BY oa.jobs.id;


--
-- Name: registration_keys; Type: TABLE; Schema: oa; Owner: -
--

CREATE TABLE oa.registration_keys (
    id uuid DEFAULT fis.uuid_generate_v4() NOT NULL,
    client_name text NOT NULL,
    description text
);


--
-- Name: schema_migrations; Type: TABLE; Schema: oa; Owner: -
--

CREATE TABLE oa.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: worker_logs; Type: TABLE; Schema: oa; Owner: -
--

CREATE TABLE oa.worker_logs (
    id bigint NOT NULL,
    message text,
    created_on timestamp without time zone,
    worker_id integer,
    job_id integer,
    level integer DEFAULT 0
);


--
-- Name: worker_logs_id_seq; Type: SEQUENCE; Schema: oa; Owner: -
--

CREATE SEQUENCE oa.worker_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: worker_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: oa; Owner: -
--

ALTER SEQUENCE oa.worker_logs_id_seq OWNED BY oa.worker_logs.id;


--
-- Name: workers; Type: TABLE; Schema: oa; Owner: -
--

CREATE TABLE oa.workers (
    id bigint NOT NULL,
    allow_deny text,
    hostname text NOT NULL,
    used_percent integer,
    load_average numeric,
    enable_profiling boolean DEFAULT false,
    blocked_types text,
    queue_name character varying
);


--
-- Name: workers_id_seq; Type: SEQUENCE; Schema: oa; Owner: -
--

CREATE SEQUENCE oa.workers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workers_id_seq; Type: SEQUENCE OWNED BY; Schema: oa; Owner: -
--

ALTER SEQUENCE oa.workers_id_seq OWNED BY oa.workers.id;


--
-- Name: account_reports; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.account_reports (
    id integer NOT NULL,
    account_id integer NOT NULL,
    report_id integer NOT NULL
);


--
-- Name: account_reports_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.account_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.account_reports_id_seq OWNED BY oh.account_reports.id;


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.accounts (
    id integer DEFAULT nextval('oh.accounts_id_seq'::regclass) NOT NULL,
    login text NOT NULL,
    email text NOT NULL,
    encrypted_password character varying NOT NULL,
    salt text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    activation_code text,
    activated_at timestamp without time zone,
    remember_token character varying(128) NOT NULL,
    remember_token_expires_at timestamp without time zone,
    level integer DEFAULT 0 NOT NULL,
    posts_count integer DEFAULT 0,
    last_seen_at timestamp without time zone,
    name text,
    country_code text,
    location text,
    latitude numeric,
    longitude numeric,
    best_vita_id integer,
    url text,
    about_markup_id integer,
    hide_experience boolean DEFAULT false,
    email_master boolean DEFAULT true,
    email_posts boolean DEFAULT true,
    email_kudos boolean DEFAULT true,
    email_md5 text,
    email_opportunities_visited timestamp without time zone,
    activation_resent_at timestamp without time zone,
    akas text,
    email_new_followers boolean DEFAULT false,
    last_seen_ip text,
    twitter_account text,
    confirmation_token character varying,
    organization_id integer,
    affiliation_type text DEFAULT 'unaffiliated'::text NOT NULL,
    organization_name text,
    auth_fail_count integer DEFAULT 0,
    CONSTRAINT accounts_email_check CHECK ((length(email) >= 3)),
    CONSTRAINT accounts_login_check CHECK ((length(login) >= 3))
);


--
-- Name: accounts_new_login; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.accounts_new_login (
    id integer,
    login text,
    email text,
    encrypted_password character varying,
    salt text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    activation_code text,
    activated_at timestamp without time zone,
    remember_token character varying(128),
    remember_token_expires_at timestamp without time zone,
    level integer,
    posts_count integer,
    last_seen_at timestamp without time zone,
    name text,
    country_code text,
    location text,
    latitude numeric,
    longitude numeric,
    best_vita_id integer,
    url text,
    about_markup_id integer,
    hide_experience boolean,
    email_master boolean,
    email_posts boolean,
    email_kudos boolean,
    email_md5 text,
    email_opportunities_visited timestamp without time zone,
    activation_resent_at timestamp without time zone,
    akas text,
    email_new_followers boolean,
    last_seen_ip text,
    twitter_account text,
    confirmation_token character varying,
    organization_id integer,
    affiliation_type text,
    organization_name text
);


--
-- Name: actions; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.actions (
    id integer NOT NULL,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    status text,
    stack_project_id integer,
    claim_person_id bigint
);


--
-- Name: actions_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actions_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.actions_id_seq OWNED BY oh.actions.id;


--
-- Name: activity_facts_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.activity_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_facts; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.activity_facts (
    month date,
    language_id integer,
    code_added integer DEFAULT 0,
    code_removed integer DEFAULT 0,
    comments_added integer DEFAULT 0,
    comments_removed integer DEFAULT 0,
    blanks_added integer DEFAULT 0,
    blanks_removed integer DEFAULT 0,
    name_id integer NOT NULL,
    id bigint DEFAULT nextval('oh.activity_facts_id_seq'::regclass) NOT NULL,
    analysis_id integer NOT NULL,
    commits integer DEFAULT 0,
    on_trunk boolean DEFAULT true
);


--
-- Name: aliases; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.aliases (
    id integer NOT NULL,
    project_id integer NOT NULL,
    commit_name_id integer NOT NULL,
    preferred_name_id integer NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT alias_noop_check CHECK ((preferred_name_id <> commit_name_id))
);


--
-- Name: aliases_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.aliases_id_seq OWNED BY oh.aliases.id;


--
-- Name: all_months; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.all_months (
    month timestamp without time zone
);


--
-- Name: analyses_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.analyses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analyses; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.analyses (
    id integer DEFAULT nextval('oh.analyses_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    as_of timestamp without time zone,
    updated_on timestamp without time zone,
    main_language_id integer,
    relative_comments numeric,
    logic_total integer,
    markup_total integer,
    headcount integer,
    min_month date,
    max_month date,
    oldest_code_set_time timestamp without time zone,
    committers_all_time integer,
    first_commit_time timestamp without time zone,
    last_commit_time timestamp without time zone,
    commit_count integer,
    build_total integer,
    created_at timestamp without time zone,
    activity_score bigint,
    hotness_score double precision
);


--
-- Name: analysis_summaries; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.analysis_summaries (
    id integer NOT NULL,
    analysis_id integer NOT NULL,
    files_modified integer,
    lines_added integer,
    lines_removed integer,
    type text NOT NULL,
    created_at timestamp without time zone,
    recent_contributors text DEFAULT '--- []

'::text,
    new_contributors_count integer,
    affiliated_committers_count integer,
    affiliated_commits_count integer,
    outside_committers_count integer,
    outside_commits_count integer
);


--
-- Name: analysis_summaries_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.analysis_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analysis_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.analysis_summaries_id_seq OWNED BY oh.analysis_summaries.id;


--
-- Name: api_keys; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.api_keys (
    id integer NOT NULL,
    created_at timestamp without time zone,
    account_id integer NOT NULL,
    key text,
    description text,
    daily_count integer DEFAULT 0,
    daily_limit integer DEFAULT 1000 NOT NULL,
    day_began_at timestamp without time zone,
    last_access_at timestamp without time zone,
    total_count integer DEFAULT 0,
    status integer DEFAULT 0 NOT NULL,
    name text,
    url text,
    support_url text,
    callback_url text,
    secret text,
    oauth_application_id integer
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.api_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.api_keys_id_seq OWNED BY oh.api_keys.id;


--
-- Name: attachments; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.attachments (
    id integer NOT NULL,
    parent_id integer,
    type text NOT NULL,
    thumbnail text,
    filename text NOT NULL,
    content_type text,
    size integer,
    width integer,
    height integer,
    is_default boolean DEFAULT false NOT NULL
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.attachments_id_seq OWNED BY oh.attachments.id;


--
-- Name: authorizations; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.authorizations (
    id integer NOT NULL,
    account_id integer,
    type text,
    api_key_id integer NOT NULL,
    token text NOT NULL,
    secret text,
    authorized_at timestamp without time zone,
    invalidated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: authorizations_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.authorizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authorizations_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.authorizations_id_seq OWNED BY oh.authorizations.id;


--
-- Name: broken_links; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.broken_links (
    id integer NOT NULL,
    link_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    error text
);


--
-- Name: broken_links_fixed; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.broken_links_fixed (
    old_link_id integer NOT NULL,
    old_url text NOT NULL,
    new_link_id integer NOT NULL,
    url text NOT NULL
);


--
-- Name: broken_links_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.broken_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: broken_links_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.broken_links_id_seq OWNED BY oh.broken_links.id;


--
-- Name: broken_links_processed; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.broken_links_processed (
    link_id integer NOT NULL
);


--
-- Name: clumps; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.clumps (
    id integer NOT NULL,
    slave_id integer,
    code_set_id integer,
    updated_at timestamp without time zone,
    type text NOT NULL,
    fetched_at timestamp without time zone
);


--
-- Name: clumps_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.clumps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clumps_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.clumps_id_seq OWNED BY oh.clumps.id;


--
-- Name: code_location_scan; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.code_location_scan (
    id bigint NOT NULL,
    code_location_id integer,
    scan_project_id integer,
    language character varying,
    command_line character varying,
    project_token character varying,
    user_managed boolean DEFAULT false
);


--
-- Name: code_location_scan_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.code_location_scan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_location_scan_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.code_location_scan_id_seq OWNED BY oh.code_location_scan.id;


--
-- Name: name_facts_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.name_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: name_facts; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.name_facts (
    id integer DEFAULT nextval('oh.name_facts_id_seq'::regclass) NOT NULL,
    analysis_id integer,
    name_id integer,
    primary_language_id integer,
    total_code_added integer DEFAULT 0,
    last_checkin timestamp without time zone,
    comment_ratio double precision,
    man_months integer,
    commits integer DEFAULT 0,
    median_commits integer DEFAULT 0,
    median_activity_lines integer DEFAULT 0,
    first_checkin timestamp without time zone,
    vita_id integer,
    type text,
    thirty_day_commits integer,
    twelve_month_commits integer,
    commits_by_project text,
    commits_by_language text,
    email_address_ids integer[] DEFAULT '{}'::integer[]
);


--
-- Name: people; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.people (
    id bigint NOT NULL,
    effective_name text,
    account_id integer,
    project_id integer,
    name_id integer,
    name_fact_id integer,
    kudo_position integer,
    kudo_score numeric,
    kudo_rank integer,
    vector tsvector,
    popularity_factor numeric,
    CONSTRAINT people_name_fact_id_account_id CHECK ((((name_fact_id IS NOT NULL) AND (name_id IS NOT NULL) AND (project_id IS NOT NULL)) OR (account_id IS NOT NULL)))
);


--
-- Name: contributions; Type: VIEW; Schema: oh; Owner: -
--

CREATE VIEW oh.contributions AS
 SELECT people.id,
    people.id AS person_id,
    people.project_id,
    people.name_fact_id,
    NULL::integer AS position_id
   FROM oh.people
  WHERE (people.project_id IS NOT NULL)
UNION
 SELECT (((positions.project_id)::bigint << 32) + (positions.account_id)::bigint) AS id,
    people.id AS person_id,
    positions.project_id,
    name_facts.id AS name_fact_id,
    positions.id AS position_id
   FROM (((oh.people
     JOIN oh.positions ON ((positions.account_id = people.account_id)))
     LEFT JOIN oh.projects ON ((projects.id = positions.project_id)))
     LEFT JOIN oh.name_facts ON (((name_facts.analysis_id = projects.best_analysis_id) AND (name_facts.name_id = positions.name_id))));


--
-- Name: contributions2; Type: VIEW; Schema: oh; Owner: -
--

CREATE VIEW oh.contributions2 AS
 SELECT
        CASE
            WHEN (pos.id IS NULL) THEN ((((per.project_id)::bigint << 32) + (per.name_id)::bigint) + ('10000000000000000000000000000000'::"bit")::bigint)
            ELSE (((pos.project_id)::bigint << 32) + (pos.account_id)::bigint)
        END AS id,
        CASE
            WHEN (pos.id IS NULL) THEN per.name_fact_id
            ELSE ( SELECT name_facts.id
               FROM oh.name_facts
              WHERE ((name_facts.analysis_id = p.best_analysis_id) AND (name_facts.name_id = pos.name_id)))
        END AS name_fact_id,
    pos.id AS position_id,
    per.id AS person_id,
    COALESCE(pos.project_id, per.project_id) AS project_id
   FROM ((oh.people per
     LEFT JOIN oh.positions pos ON ((per.account_id = pos.account_id)))
     JOIN oh.projects p ON ((p.id = COALESCE(pos.project_id, per.project_id))));


--
-- Name: countries; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.countries (
    country_code text,
    continent_code text,
    name text,
    region text
);


--
-- Name: deleted_accounts; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.deleted_accounts (
    id integer NOT NULL,
    login text NOT NULL,
    email text NOT NULL,
    organization_id integer,
    claimed_project_ids integer[] DEFAULT '{}'::integer[],
    reasons integer[] DEFAULT '{}'::integer[],
    reason_other text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: deleted_accounts_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.deleted_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deleted_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.deleted_accounts_id_seq OWNED BY oh.deleted_accounts.id;


--
-- Name: diff_licenses_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.diff_licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: duplicates; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.duplicates (
    id integer NOT NULL,
    good_project_id integer NOT NULL,
    bad_project_id integer NOT NULL,
    account_id integer,
    comment text,
    created_at timestamp without time zone,
    resolved boolean DEFAULT false,
    CONSTRAINT duplicates_good_not_equal_bad CHECK ((good_project_id <> bad_project_id))
);


--
-- Name: duplicates_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.duplicates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: duplicates_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.duplicates_id_seq OWNED BY oh.duplicates.id;


--
-- Name: edits_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.edits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: edits; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.edits (
    id integer DEFAULT nextval('oh.edits_id_seq'::regclass) NOT NULL,
    type text,
    target_id integer NOT NULL,
    target_type text NOT NULL,
    key text,
    value text,
    account_id integer,
    ip text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    undone boolean DEFAULT false NOT NULL,
    undone_at timestamp without time zone,
    undone_by integer,
    project_id integer,
    organization_id integer
);


--
-- Name: edits_bad_link; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.edits_bad_link (
    id integer,
    value text
);


--
-- Name: enlistments_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.enlistments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enlistments; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.enlistments (
    id integer DEFAULT nextval('oh.enlistments_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    repository_id integer,
    deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    updated_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    ignore text,
    code_location_id integer,
    allowed_fyles text,
    CONSTRAINT project_id_not_null_constraint CHECK ((project_id IS NOT NULL))
);


--
-- Name: event_subscription; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.event_subscription (
    id integer NOT NULL,
    subscriber_id integer,
    klass text NOT NULL,
    project_id integer,
    topic_id integer,
    account_id integer,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: event_subscription_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.event_subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_subscription_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.event_subscription_id_seq OWNED BY oh.event_subscription.id;


--
-- Name: exhibits; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.exhibits (
    id integer NOT NULL,
    report_id integer NOT NULL,
    type text NOT NULL,
    title text,
    params text,
    result text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: exhibits_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.exhibits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exhibits_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.exhibits_id_seq OWNED BY oh.exhibits.id;


--
-- Name: factoids_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.factoids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: factoids; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.factoids (
    id integer DEFAULT nextval('oh.factoids_id_seq'::regclass) NOT NULL,
    severity integer DEFAULT 0,
    analysis_id integer NOT NULL,
    type text,
    license_id integer,
    language_id integer,
    previous_count integer DEFAULT 0,
    current_count integer DEFAULT 0,
    max_count integer DEFAULT 0
);


--
-- Name: feedbacks; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.feedbacks (
    id integer NOT NULL,
    rating integer,
    more_info integer,
    uuid character varying,
    ip_address inet,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: feedbacks_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.feedbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.feedbacks_id_seq OWNED BY oh.feedbacks.id;


--
-- Name: follows; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.follows (
    id integer NOT NULL,
    owner_id integer NOT NULL,
    project_id integer,
    account_id integer,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: message_account_tags; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.message_account_tags (
    id integer NOT NULL,
    message_id integer,
    account_id integer
);


--
-- Name: message_project_tags; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.message_project_tags (
    id integer NOT NULL,
    message_id integer,
    project_id integer
);


--
-- Name: messages; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.messages (
    id integer NOT NULL,
    account_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    body text,
    title text
);


--
-- Name: followed_messages; Type: VIEW; Schema: oh; Owner: -
--

CREATE VIEW oh.followed_messages AS
 SELECT f.owner_id,
    m.id,
    m.account_id,
    m.created_at,
    m.deleted_at,
    m.body,
    m.title
   FROM ((oh.messages m
     JOIN oh.message_project_tags mpt ON ((mpt.message_id = m.id)))
     JOIN oh.follows f ON ((f.project_id = mpt.project_id)))
  WHERE (m.deleted_at IS NULL)
UNION
 SELECT f.owner_id,
    m.id,
    m.account_id,
    m.created_at,
    m.deleted_at,
    m.body,
    m.title
   FROM (oh.messages m
     JOIN oh.follows f ON ((f.account_id = m.account_id)))
  WHERE (m.deleted_at IS NULL)
UNION
 SELECT mat.account_id AS owner_id,
    m.id,
    m.account_id,
    m.created_at,
    m.deleted_at,
    m.body,
    m.title
   FROM (oh.messages m
     JOIN oh.message_account_tags mat ON ((mat.message_id = m.id)))
  WHERE (m.deleted_at IS NULL);


--
-- Name: follows_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.follows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: follows_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.follows_id_seq OWNED BY oh.follows.id;


--
-- Name: forums_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.forums_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forums; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.forums (
    id integer DEFAULT nextval('oh.forums_id_seq'::regclass) NOT NULL,
    project_id integer,
    name text NOT NULL,
    topics_count integer DEFAULT 0,
    posts_count integer DEFAULT 0,
    "position" integer,
    description text
);


--
-- Name: github_project; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.github_project (
    project_id text NOT NULL,
    owner text NOT NULL,
    state_code integer DEFAULT 660 NOT NULL,
    description text,
    homepage text,
    has_downloads boolean,
    is_fork boolean,
    created timestamp without time zone DEFAULT now(),
    updated timestamp without time zone DEFAULT now(),
    last_spidered timestamp without time zone DEFAULT now(),
    parent text,
    source text,
    watchers integer,
    forks integer,
    project_created timestamp without time zone,
    note text,
    organization text
);


--
-- Name: guaranteed_spam_accounts; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.guaranteed_spam_accounts (
    id integer NOT NULL,
    login text NOT NULL,
    email text NOT NULL,
    crypted_password text NOT NULL,
    salt text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    activation_code text,
    activated_at timestamp without time zone,
    remember_token text,
    remember_token_expires_at timestamp without time zone,
    level integer NOT NULL,
    posts_count integer,
    last_seen_at timestamp without time zone,
    name text,
    country_code text,
    location text,
    latitude numeric,
    longitude numeric,
    best_vita_id integer,
    url text,
    about_markup_id integer,
    hide_experience boolean,
    email_master boolean,
    email_posts boolean,
    email_kudos boolean,
    email_md5 text,
    email_opportunities_visited timestamp without time zone,
    activation_resent_at timestamp without time zone,
    akas text,
    email_new_followers boolean,
    last_seen_ip text,
    twitter_account text,
    reset_password_tokens text,
    organization_id integer,
    affiliation_type text NOT NULL,
    organization_name text
);


--
-- Name: helpfuls_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.helpfuls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: helpfuls; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.helpfuls (
    id integer DEFAULT nextval('oh.helpfuls_id_seq'::regclass) NOT NULL,
    review_id integer,
    account_id integer NOT NULL,
    yes boolean DEFAULT true
);


--
-- Name: invites; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.invites (
    id integer NOT NULL,
    invitor_id integer NOT NULL,
    invitee_id integer,
    invitee_email text NOT NULL,
    project_id integer NOT NULL,
    activation_code text,
    created_at timestamp without time zone,
    activated_at timestamp without time zone,
    name_id integer,
    contribution_id bigint
);


--
-- Name: invites_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invites_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.invites_id_seq OWNED BY oh.invites.id;


--
-- Name: job_statuses; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.job_statuses (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: knowledge_base_statuses; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.knowledge_base_statuses (
    id integer NOT NULL,
    project_id integer NOT NULL,
    in_sync boolean DEFAULT false,
    updated_at timestamp without time zone
);


--
-- Name: knowledge_base_statuses_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.knowledge_base_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_base_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.knowledge_base_statuses_id_seq OWNED BY oh.knowledge_base_statuses.id;


--
-- Name: kudo_scores; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.kudo_scores (
    id integer NOT NULL,
    array_index integer,
    account_id integer,
    project_id integer,
    name_id integer,
    damping numeric DEFAULT 1.0,
    fraction numeric,
    score numeric,
    "position" integer,
    rank integer
);


--
-- Name: kudo_scores_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.kudo_scores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
    CYCLE;


--
-- Name: kudo_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.kudo_scores_id_seq OWNED BY oh.kudo_scores.id;


--
-- Name: kudos; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.kudos (
    id integer NOT NULL,
    sender_id integer NOT NULL,
    account_id integer,
    project_id integer,
    name_id integer,
    created_at timestamp without time zone,
    message character varying(80),
    CONSTRAINT not_all_null CHECK ((NOT ((account_id IS NULL) AND (project_id IS NULL) AND (name_id IS NULL))))
);


--
-- Name: kudos_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.kudos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kudos_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.kudos_id_seq OWNED BY oh.kudos.id;


--
-- Name: language_experiences; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.language_experiences (
    id integer NOT NULL,
    position_id integer NOT NULL,
    language_id integer NOT NULL
);


--
-- Name: language_experiences_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.language_experiences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: language_experiences_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.language_experiences_id_seq OWNED BY oh.language_experiences.id;


--
-- Name: language_facts; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.language_facts (
    id integer NOT NULL,
    month date,
    language_id integer,
    commits bigint,
    loc_changed bigint,
    loc_total bigint,
    projects bigint,
    contributors bigint
);


--
-- Name: language_facts_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.language_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: language_facts_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.language_facts_id_seq OWNED BY oh.language_facts.id;


--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: languages; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.languages (
    id integer DEFAULT nextval('oh.languages_id_seq'::regclass) NOT NULL,
    name text,
    nice_name text,
    category integer DEFAULT 0,
    avg_percent_comments double precision DEFAULT (0)::double precision,
    code bigint DEFAULT 0,
    comments bigint DEFAULT 0,
    blanks bigint DEFAULT 0,
    commits bigint DEFAULT 0,
    projects bigint DEFAULT 0,
    contributors bigint DEFAULT 0,
    active_contributors text,
    experienced_contributors text
);


--
-- Name: license_facts_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.license_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: license_facts; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.license_facts (
    license_id integer NOT NULL,
    file_count integer DEFAULT 0 NOT NULL,
    scope integer DEFAULT 0 NOT NULL,
    id integer DEFAULT nextval('oh.license_facts_id_seq'::regclass) NOT NULL,
    analysis_id integer NOT NULL
);


--
-- Name: license_license_permissions; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.license_license_permissions (
    id integer NOT NULL,
    license_id integer,
    license_permission_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: license_license_permissions_id_seq1; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.license_license_permissions_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: license_license_permissions_id_seq1; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.license_license_permissions_id_seq1 OWNED BY oh.license_license_permissions.id;


--
-- Name: license_permission_roles; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.license_permission_roles (
    id integer NOT NULL,
    license_id integer,
    license_permission_id integer,
    status integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: license_permission_roles_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.license_permission_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: license_permission_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.license_permission_roles_id_seq OWNED BY oh.license_permission_roles.id;


--
-- Name: license_permissions; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.license_permissions (
    id integer NOT NULL,
    license_right_id integer,
    status integer,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: license_permissions_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.license_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: license_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.license_permissions_id_seq OWNED BY oh.license_permissions.id;


--
-- Name: license_permissions_new; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.license_permissions_new (
    id integer,
    license_right_id integer,
    status integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: license_rights; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.license_rights (
    id integer NOT NULL,
    name character varying,
    icon character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: license_rights_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.license_rights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: license_rights_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.license_rights_id_seq OWNED BY oh.license_rights.id;


--
-- Name: licenses_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: licenses; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.licenses (
    id integer DEFAULT nextval('oh.licenses_id_seq'::regclass) NOT NULL,
    vanity_url text,
    name text,
    abbreviation text,
    url text,
    description text,
    deleted boolean DEFAULT false,
    locked boolean DEFAULT false,
    kb_id uuid
);


--
-- Name: link_categories_deleted; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.link_categories_deleted (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: link_categories_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.link_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: link_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.link_categories_id_seq OWNED BY oh.link_categories_deleted.id;


--
-- Name: links; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.links (
    id integer NOT NULL,
    title text NOT NULL,
    url text NOT NULL,
    project_id integer NOT NULL,
    link_category_id integer NOT NULL,
    deleted boolean DEFAULT false,
    created_at timestamp without time zone,
    helpful_score integer DEFAULT 0 NOT NULL
);


--
-- Name: links_copy; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.links_copy (
    id integer,
    title text,
    url text,
    project_id integer,
    link_category_id integer,
    deleted boolean,
    created_at timestamp without time zone,
    helpful_score integer
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.links_id_seq OWNED BY oh.links.id;


--
-- Name: links_old; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.links_old (
    id integer,
    title text,
    url text,
    project_id integer,
    link_category_id integer,
    deleted boolean,
    created_at timestamp without time zone,
    helpful_score integer
);


--
-- Name: links_truncated; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.links_truncated (
    id integer,
    url text
);


--
-- Name: manages; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.manages (
    id integer NOT NULL,
    account_id integer NOT NULL,
    target_id integer NOT NULL,
    message text,
    updated_at timestamp without time zone,
    created_at timestamp without time zone,
    approved_by integer,
    deleted_by integer,
    deleted_at timestamp without time zone,
    target_type text
);


--
-- Name: manages_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.manages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: manages_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.manages_id_seq OWNED BY oh.manages.id;


--
-- Name: markups; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.markups (
    id integer NOT NULL,
    raw text,
    formatted text
);


--
-- Name: markups_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.markups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: markups_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.markups_id_seq OWNED BY oh.markups.id;


--
-- Name: message_account_tags_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.message_account_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_account_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.message_account_tags_id_seq OWNED BY oh.message_account_tags.id;


--
-- Name: message_project_tags_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.message_project_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_project_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.message_project_tags_id_seq OWNED BY oh.message_project_tags.id;


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.messages_id_seq OWNED BY oh.messages.id;


--
-- Name: mistaken_jobs; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.mistaken_jobs (
    id integer,
    project_id integer,
    repository_id integer,
    status integer,
    type text,
    priority integer,
    current_step integer,
    current_step_at timestamp without time zone,
    max_steps integer,
    exception text,
    backtrace text,
    code_set_id integer,
    sloc_set_id integer,
    notes text,
    wait_until timestamp without time zone,
    account_id integer,
    logged_at timestamp without time zone,
    slave_id integer,
    started_at timestamp without time zone,
    retry_count integer,
    do_not_retry boolean,
    failure_group_id integer,
    organization_id integer
);


--
-- Name: moderatorships_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.moderatorships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitorships_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.monitorships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monthly_commit_histories; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.monthly_commit_histories (
    id integer NOT NULL,
    analysis_id integer,
    json text
);


--
-- Name: monthly_commit_histories_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.monthly_commit_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monthly_commit_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.monthly_commit_histories_id_seq OWNED BY oh.monthly_commit_histories.id;


--
-- Name: name_language_facts_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.name_language_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: name_language_facts; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.name_language_facts (
    id bigint DEFAULT nextval('oh.name_language_facts_id_seq'::regclass) NOT NULL,
    name_id integer,
    analysis_id integer,
    language_id integer,
    total_months integer DEFAULT 0,
    total_commits integer DEFAULT 0,
    total_activity_lines integer DEFAULT 0,
    vita_id integer,
    type text,
    comment_ratio numeric,
    most_commits_project_id integer,
    most_commits integer,
    recent_commit_project_id integer,
    recent_commit_month timestamp without time zone
);


--
-- Name: names_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: names; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.names (
    id integer DEFAULT nextval('oh.names_id_seq'::regclass) NOT NULL,
    name text NOT NULL
);


--
-- Name: oauth_access_grants; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.oauth_access_grants (
    id integer NOT NULL,
    resource_owner_id integer NOT NULL,
    application_id integer NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.oauth_access_grants_id_seq OWNED BY oh.oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.oauth_access_tokens (
    id integer NOT NULL,
    resource_owner_id integer,
    application_id integer,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.oauth_access_tokens_id_seq OWNED BY oh.oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.oauth_applications (
    id integer NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    confidential boolean DEFAULT true NOT NULL
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.oauth_applications_id_seq OWNED BY oh.oauth_applications.id;


--
-- Name: oauth_nonces; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.oauth_nonces (
    id integer NOT NULL,
    nonce text NOT NULL,
    "timestamp" integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: oauth_nonces_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.oauth_nonces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_nonces_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.oauth_nonces_id_seq OWNED BY oh.oauth_nonces.id;


--
-- Name: old_edits_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.old_edits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_stats_by_sectors; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.org_stats_by_sectors (
    id integer NOT NULL,
    org_type integer,
    organization_count integer,
    commits_count integer,
    affiliate_count integer,
    average_commits integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: org_stats_by_sectors_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.org_stats_by_sectors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_stats_by_sectors_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.org_stats_by_sectors_id_seq OWNED BY oh.org_stats_by_sectors.id;


--
-- Name: org_thirty_day_activities; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.org_thirty_day_activities (
    id integer NOT NULL,
    name character varying(255),
    organization_id integer,
    vanity_url character varying(255),
    org_type integer,
    project_count integer,
    affiliate_count integer,
    thirty_day_commit_count integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: org_thirty_day_activities_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.org_thirty_day_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_thirty_day_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.org_thirty_day_activities_id_seq OWNED BY oh.org_thirty_day_activities.id;


--
-- Name: organizations; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.organizations (
    id integer NOT NULL,
    name text,
    vanity_url text,
    description text,
    org_type integer,
    homepage_url text,
    logo_id integer,
    vector tsvector,
    popularity_factor numeric,
    deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    projects_count integer DEFAULT 0,
    thirty_day_activity_id integer
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.organizations_id_seq OWNED BY oh.organizations.id;


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pdp_spammer_ids; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.pdp_spammer_ids (
    account_id integer
);


--
-- Name: people_view; Type: VIEW; Schema: oh; Owner: -
--

CREATE VIEW oh.people_view AS
 SELECT a.id,
    a.name AS effective_name,
    a.id AS account_id,
    NULL::integer AS project_id,
    NULL::integer AS name_id,
    NULL::integer AS name_fact_id,
    ks."position" AS kudo_position,
    ks.score AS kudo_score,
    ks.rank AS kudo_rank
   FROM (oh.accounts a
     LEFT JOIN oh.kudo_scores ks ON ((ks.account_id = a.id)))
  WHERE (a.level <> '-20'::integer)
UNION
 SELECT ((((p.id)::bigint << 32) + (nf.name_id)::bigint) + ('10000000000000000000000000000000'::"bit")::bigint) AS id,
    n.name AS effective_name,
    NULL::integer AS account_id,
    p.id AS project_id,
    n.id AS name_id,
    nf.id AS name_fact_id,
    ks."position" AS kudo_position,
    ks.score AS kudo_score,
    ks.rank AS kudo_rank
   FROM (((oh.name_facts nf
     JOIN oh.names n ON ((nf.name_id = n.id)))
     JOIN oh.projects p ON (((p.best_analysis_id = nf.analysis_id) AND (NOT p.deleted))))
     LEFT JOIN oh.kudo_scores ks ON (((ks.name_id = nf.name_id) AND (ks.project_id = p.id))))
  WHERE (NOT (nf.name_id IN ( SELECT positions.name_id
           FROM oh.positions
          WHERE ((positions.project_id = p.id) AND (positions.name_id IS NOT NULL)))));


--
-- Name: permissions; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.permissions (
    id integer NOT NULL,
    target_id integer NOT NULL,
    updated_at timestamp without time zone,
    created_at timestamp without time zone,
    remainder boolean DEFAULT false,
    downloads boolean DEFAULT false,
    target_type text
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.permissions_id_seq OWNED BY oh.permissions.id;


--
-- Name: pg_ts_cfg; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.pg_ts_cfg (
    ts_name text NOT NULL,
    prs_name text NOT NULL,
    locale text
);


--
-- Name: pg_ts_cfgmap; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.pg_ts_cfgmap (
    ts_name text NOT NULL,
    tok_alias text NOT NULL,
    dict_name text[]
);


--
-- Name: positions_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.positions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: positions_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.positions_id_seq OWNED BY oh.positions.id;


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.posts (
    id integer DEFAULT nextval('oh.posts_id_seq'::regclass) NOT NULL,
    account_id integer NOT NULL,
    topic_id integer NOT NULL,
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    notified_at timestamp without time zone,
    vector tsvector,
    popularity_factor numeric
);


--
-- Name: reviewed_non_spammers; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.reviewed_non_spammers (
    id bigint NOT NULL,
    account_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: potential_spammers; Type: VIEW; Schema: oh; Owner: -
--

CREATE VIEW oh.potential_spammers AS
 SELECT ac.id
   FROM (oh.markups
     JOIN oh.accounts ac ON ((ac.about_markup_id = markups.id)))
  WHERE ((markups.raw ~ 'http'::text) AND (ac.level = 0) AND (NOT (ac.id IN ( SELECT reviewed_non_spammers.account_id
           FROM oh.reviewed_non_spammers))));


--
-- Name: profiles; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.profiles (
    id integer NOT NULL,
    job_id integer,
    name text NOT NULL,
    count integer NOT NULL,
    "time" numeric NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.profiles_id_seq OWNED BY oh.profiles.id;


--
-- Name: project_badges; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.project_badges (
    id integer NOT NULL,
    identifier character varying,
    type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 1,
    enlistment_id integer
);


--
-- Name: project_badges_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.project_badges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_badges_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.project_badges_id_seq OWNED BY oh.project_badges.id;


--
-- Name: project_counts_by_quarter_and_language; Type: VIEW; Schema: oh; Owner: -
--

CREATE VIEW oh.project_counts_by_quarter_and_language AS
 SELECT af.language_id,
    date_trunc('quarter'::text, timezone('utc'::text, (af.month)::timestamp with time zone)) AS quarter,
    count(DISTINCT af.analysis_id) AS project_count
   FROM ((oh.activity_facts af
     JOIN oh.analyses a ON ((a.id = af.analysis_id)))
     JOIN oh.projects p ON (((p.best_analysis_id = a.id) AND (NOT p.deleted))))
  GROUP BY af.language_id, (date_trunc('quarter'::text, timezone('utc'::text, (af.month)::timestamp with time zone)));


--
-- Name: project_events; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.project_events (
    id integer NOT NULL,
    project_id integer,
    type text NOT NULL,
    key text NOT NULL,
    data text,
    "time" timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: project_events_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.project_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_events_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.project_events_id_seq OWNED BY oh.project_events.id;


--
-- Name: project_experiences; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.project_experiences (
    id integer NOT NULL,
    position_id integer NOT NULL,
    project_id integer NOT NULL,
    promote boolean DEFAULT false NOT NULL
);


--
-- Name: project_experiences_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.project_experiences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_experiences_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.project_experiences_id_seq OWNED BY oh.project_experiences.id;


--
-- Name: project_gestalts_tmp; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.project_gestalts_tmp (
    id integer,
    date timestamp without time zone,
    project_id integer,
    gestalt_id integer
);


--
-- Name: project_licenses_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.project_licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_licenses; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.project_licenses (
    id integer DEFAULT nextval('oh.project_licenses_id_seq'::regclass) NOT NULL,
    project_id integer,
    license_id integer,
    deleted boolean DEFAULT false
);


--
-- Name: project_reports; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.project_reports (
    id integer NOT NULL,
    project_id integer NOT NULL,
    report_id integer NOT NULL
);


--
-- Name: project_reports_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.project_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.project_reports_id_seq OWNED BY oh.project_reports.id;


--
-- Name: project_sboms; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.project_sboms (
    id bigint NOT NULL,
    project_id integer,
    code_location_id integer,
    agent character varying NOT NULL,
    sbom_data json
);


--
-- Name: project_sboms_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.project_sboms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_sboms_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.project_sboms_id_seq OWNED BY oh.project_sboms.id;


--
-- Name: project_security_sets; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.project_security_sets (
    id integer NOT NULL,
    project_id integer,
    uuid character varying NOT NULL,
    etag character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: project_security_sets_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.project_security_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_security_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.project_security_sets_id_seq OWNED BY oh.project_security_sets.id;


--
-- Name: project_vulnerability_reports; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.project_vulnerability_reports (
    id integer NOT NULL,
    project_id integer,
    etag character varying(255),
    vulnerability_score numeric,
    security_score numeric,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: project_vulnerability_reports_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.project_vulnerability_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_vulnerability_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.project_vulnerability_reports_id_seq OWNED BY oh.project_vulnerability_reports.id;


--
-- Name: projects_by_month; Type: VIEW; Schema: oh; Owner: -
--

CREATE VIEW oh.projects_by_month AS
 SELECT m.month,
    ( SELECT count(*) AS count
           FROM (oh.projects p
             JOIN oh.analyses a ON (((p.best_analysis_id = a.id) AND (NOT p.deleted))))
          WHERE (date_trunc('quarter'::text, (a.min_month)::timestamp with time zone) <= date_trunc('quarter'::text, m.month))) AS project_count
   FROM oh.all_months m;


--
-- Name: ratings_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.ratings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ratings; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.ratings (
    id integer DEFAULT nextval('oh.ratings_id_seq'::regclass) NOT NULL,
    account_id integer NOT NULL,
    project_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('UTC'::text, now()),
    updated_at timestamp without time zone DEFAULT timezone('UTC'::text, now())
);


--
-- Name: recently_active_accounts_cache; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.recently_active_accounts_cache (
    id integer NOT NULL,
    accounts text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: recently_active_accounts_cache_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.recently_active_accounts_cache_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recently_active_accounts_cache_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.recently_active_accounts_cache_id_seq OWNED BY oh.recently_active_accounts_cache.id;


--
-- Name: recommend_entries; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.recommend_entries (
    id bigint NOT NULL,
    project_id integer,
    project_id_recommends integer,
    weight double precision
);


--
-- Name: recommend_entries_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.recommend_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
    CYCLE;


--
-- Name: recommend_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.recommend_entries_id_seq OWNED BY oh.recommend_entries.id;


--
-- Name: recommendations; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.recommendations (
    id integer NOT NULL,
    invitor_id integer NOT NULL,
    invitee_id integer,
    invitee_email text NOT NULL,
    updated_at timestamp without time zone,
    created_at timestamp without time zone,
    project_id integer,
    activation_code text
);


--
-- Name: recommendations_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.recommendations_id_seq OWNED BY oh.recommendations.id;


--
-- Name: releases; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.releases (
    id integer NOT NULL,
    kb_release_id character varying NOT NULL,
    released_on timestamp without time zone,
    version character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    project_security_set_id integer
);


--
-- Name: releases_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.releases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releases_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.releases_id_seq OWNED BY oh.releases.id;


--
-- Name: releases_vulnerabilities; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.releases_vulnerabilities (
    release_id integer NOT NULL,
    vulnerability_id integer NOT NULL
);


--
-- Name: reports; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.reports (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title text
);


--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.reports_id_seq OWNED BY oh.reports.id;


--
-- Name: reverification_trackers; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.reverification_trackers (
    id integer NOT NULL,
    account_id integer NOT NULL,
    message_id character varying NOT NULL,
    phase integer DEFAULT 0,
    status integer DEFAULT 0,
    feedback character varying,
    attempts integer DEFAULT 1,
    sent_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reverification_trackers_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.reverification_trackers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reverification_trackers_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.reverification_trackers_id_seq OWNED BY oh.reverification_trackers.id;


--
-- Name: reviewed_non_spammers_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.reviewed_non_spammers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviewed_non_spammers_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.reviewed_non_spammers_id_seq OWNED BY oh.reviewed_non_spammers.id;


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.reviews (
    id integer DEFAULT nextval('oh.reviews_id_seq'::regclass) NOT NULL,
    account_id integer NOT NULL,
    project_id integer NOT NULL,
    title text,
    comment text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    helpful_score integer DEFAULT 0 NOT NULL
);


--
-- Name: robins_contributions_test; Type: VIEW; Schema: oh; Owner: -
--

CREATE VIEW oh.robins_contributions_test AS
 SELECT
        CASE
            WHEN (pos.id IS NULL) THEN ((((per.project_id)::bigint << 32) + (per.name_id)::bigint) + ('10000000000000000000000000000000'::"bit")::bigint)
            ELSE (((pos.project_id)::bigint << 32) + (pos.account_id)::bigint)
        END AS id,
    per.id AS person_id,
    COALESCE(pos.project_id, per.project_id) AS project_id,
        CASE
            WHEN (pos.id IS NULL) THEN per.name_fact_id
            ELSE ( SELECT name_facts.id
               FROM oh.name_facts
              WHERE ((name_facts.analysis_id = p.best_analysis_id) AND (name_facts.name_id = pos.name_id)))
        END AS name_fact_id,
    pos.id AS position_id
   FROM ((oh.people per
     LEFT JOIN oh.positions pos ON ((per.account_id = pos.account_id)))
     JOIN oh.projects p ON ((p.id = COALESCE(pos.project_id, per.project_id))));


--
-- Name: rss_articles_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.rss_articles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rss_articles; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.rss_articles (
    id integer DEFAULT nextval('oh.rss_articles_id_seq'::regclass) NOT NULL,
    rss_feed_id integer,
    guid text NOT NULL,
    "time" timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    title text NOT NULL,
    description text,
    author text,
    link text
);


--
-- Name: rss_feeds_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.rss_feeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rss_feeds; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.rss_feeds (
    id integer DEFAULT nextval('oh.rss_feeds_id_seq'::regclass) NOT NULL,
    url text NOT NULL,
    last_fetch timestamp without time zone,
    next_fetch timestamp without time zone,
    error text
);


--
-- Name: rss_subscriptions_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.rss_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rss_subscriptions; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.rss_subscriptions (
    id integer DEFAULT nextval('oh.rss_subscriptions_id_seq'::regclass) NOT NULL,
    project_id integer,
    rss_feed_id integer,
    deleted boolean DEFAULT false
);


--
-- Name: scan_analytics; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.scan_analytics (
    id bigint NOT NULL,
    data_type character varying,
    analysis_id bigint,
    code_set_id bigint,
    data jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: scan_analytics_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.scan_analytics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scan_analytics_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.scan_analytics_id_seq OWNED BY oh.scan_analytics.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.sessions (
    id integer DEFAULT nextval('oh.sessions_id_seq'::regclass) NOT NULL,
    session_id character varying(255),
    data text,
    updated_at timestamp without time zone
);


--
-- Name: settings; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.settings (
    id integer NOT NULL,
    key character varying,
    value character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.settings_id_seq OWNED BY oh.settings.id;


--
-- Name: sf_vhosted; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.sf_vhosted (
    domain text NOT NULL
);


--
-- Name: sfprojects; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.sfprojects (
    project_id integer NOT NULL,
    hosted boolean DEFAULT false,
    vhosted boolean DEFAULT false,
    code boolean DEFAULT false,
    downloads boolean DEFAULT false,
    downloads_vhosted boolean DEFAULT false
);


--
-- Name: size_facts_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.size_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stack_entries_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.stack_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stack_entries; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.stack_entries (
    id integer DEFAULT nextval('oh.stack_entries_id_seq'::regclass) NOT NULL,
    stack_id integer,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    note text
);


--
-- Name: stack_ignores; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.stack_ignores (
    id integer NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    stack_id integer NOT NULL
);


--
-- Name: stack_ignores_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.stack_ignores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stack_ignores_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.stack_ignores_id_seq OWNED BY oh.stack_ignores.id;


--
-- Name: stacks_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.stacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stacks; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.stacks (
    id integer DEFAULT nextval('oh.stacks_id_seq'::regclass) NOT NULL,
    account_id integer,
    session_id character varying(255),
    project_count integer DEFAULT 0,
    updated_at timestamp without time zone,
    title text,
    description text,
    project_id integer,
    deleted_at timestamp without time zone
);


--
-- Name: successful_accounts; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.successful_accounts (
    id integer NOT NULL,
    account_id integer
);


--
-- Name: successful_accounts_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.successful_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: successful_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.successful_accounts_id_seq OWNED BY oh.successful_accounts.id;


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.taggings (
    id integer DEFAULT nextval('oh.taggings_id_seq'::regclass) NOT NULL,
    tag_id integer,
    taggable_id integer,
    taggable_type character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.tags (
    id integer DEFAULT nextval('oh.tags_id_seq'::regclass) NOT NULL,
    name text NOT NULL,
    taggings_count integer DEFAULT 0 NOT NULL,
    weight double precision DEFAULT 1.0 NOT NULL
);


--
-- Name: thirty_day_summaries; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.thirty_day_summaries (
    id integer NOT NULL,
    analysis_id integer NOT NULL,
    committer_count integer,
    commit_count integer,
    files_modified integer,
    lines_added integer,
    lines_removed integer,
    created_at timestamp without time zone
);


--
-- Name: thirty_day_summaries_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.thirty_day_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thirty_day_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.thirty_day_summaries_id_seq OWNED BY oh.thirty_day_summaries.id;


--
-- Name: tools; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.tools (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);


--
-- Name: tools_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.tools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tools_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.tools_id_seq OWNED BY oh.tools.id;


--
-- Name: topics_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topics; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.topics (
    id integer DEFAULT nextval('oh.topics_id_seq'::regclass) NOT NULL,
    forum_id integer,
    account_id integer NOT NULL,
    title text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    hits integer DEFAULT 0,
    sticky integer DEFAULT 0,
    posts_count integer DEFAULT 0,
    replied_at timestamp without time zone,
    closed boolean DEFAULT false,
    replied_by integer,
    last_post_id integer
);


--
-- Name: unknown_spam_accounts; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.unknown_spam_accounts (
    id integer NOT NULL,
    login text NOT NULL,
    email text NOT NULL,
    crypted_password text NOT NULL,
    salt text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    activation_code text,
    activated_at timestamp without time zone,
    remember_token text,
    remember_token_expires_at timestamp without time zone,
    level integer NOT NULL,
    posts_count integer,
    last_seen_at timestamp without time zone,
    name text,
    country_code text,
    location text,
    latitude numeric,
    longitude numeric,
    best_vita_id integer,
    url text,
    about_markup_id integer,
    hide_experience boolean,
    email_master boolean,
    email_posts boolean,
    email_kudos boolean,
    email_md5 text,
    email_opportunities_visited timestamp without time zone,
    activation_resent_at timestamp without time zone,
    akas text,
    email_new_followers boolean,
    last_seen_ip text,
    twitter_account text,
    reset_password_tokens text,
    organization_id integer,
    affiliation_type text NOT NULL,
    organization_name text
);


--
-- Name: verifications; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.verifications (
    id integer NOT NULL,
    account_id integer,
    type character varying,
    token character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unique_id character varying
);


--
-- Name: verifications_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.verifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.verifications_id_seq OWNED BY oh.verifications.id;


--
-- Name: vita_analyses; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.vita_analyses (
    id bigint NOT NULL,
    vita_id integer,
    analysis_id integer
);


--
-- Name: vita_analyses_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.vita_analyses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vita_analyses_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.vita_analyses_id_seq OWNED BY oh.vita_analyses.id;


--
-- Name: vitae; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.vitae (
    id integer NOT NULL,
    account_id integer NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: vitae_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.vitae_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vitae_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.vitae_id_seq OWNED BY oh.vitae.id;


--
-- Name: vulnerabilities; Type: TABLE; Schema: oh; Owner: -
--

CREATE TABLE oh.vulnerabilities (
    id integer NOT NULL,
    cve_id character varying NOT NULL,
    generated_on timestamp without time zone,
    published_on timestamp without time zone,
    severity integer,
    score numeric,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description text
);


--
-- Name: vulnerabilities_id_seq; Type: SEQUENCE; Schema: oh; Owner: -
--

CREATE SEQUENCE oh.vulnerabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vulnerabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: oh; Owner: -
--

ALTER SEQUENCE oh.vulnerabilities_id_seq OWNED BY oh.vulnerabilities.id;


--
-- Name: diffs_0; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_0 FOR VALUES WITH (modulus 100, remainder 0);


--
-- Name: diffs_1; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_1 FOR VALUES WITH (modulus 100, remainder 1);


--
-- Name: diffs_10; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_10 FOR VALUES WITH (modulus 100, remainder 10);


--
-- Name: diffs_11; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_11 FOR VALUES WITH (modulus 100, remainder 11);


--
-- Name: diffs_12; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_12 FOR VALUES WITH (modulus 100, remainder 12);


--
-- Name: diffs_13; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_13 FOR VALUES WITH (modulus 100, remainder 13);


--
-- Name: diffs_14; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_14 FOR VALUES WITH (modulus 100, remainder 14);


--
-- Name: diffs_15; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_15 FOR VALUES WITH (modulus 100, remainder 15);


--
-- Name: diffs_16; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_16 FOR VALUES WITH (modulus 100, remainder 16);


--
-- Name: diffs_17; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_17 FOR VALUES WITH (modulus 100, remainder 17);


--
-- Name: diffs_18; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_18 FOR VALUES WITH (modulus 100, remainder 18);


--
-- Name: diffs_19; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_19 FOR VALUES WITH (modulus 100, remainder 19);


--
-- Name: diffs_2; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_2 FOR VALUES WITH (modulus 100, remainder 2);


--
-- Name: diffs_20; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_20 FOR VALUES WITH (modulus 100, remainder 20);


--
-- Name: diffs_21; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_21 FOR VALUES WITH (modulus 100, remainder 21);


--
-- Name: diffs_22; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_22 FOR VALUES WITH (modulus 100, remainder 22);


--
-- Name: diffs_23; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_23 FOR VALUES WITH (modulus 100, remainder 23);


--
-- Name: diffs_24; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_24 FOR VALUES WITH (modulus 100, remainder 24);


--
-- Name: diffs_25; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_25 FOR VALUES WITH (modulus 100, remainder 25);


--
-- Name: diffs_26; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_26 FOR VALUES WITH (modulus 100, remainder 26);


--
-- Name: diffs_27; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_27 FOR VALUES WITH (modulus 100, remainder 27);


--
-- Name: diffs_28; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_28 FOR VALUES WITH (modulus 100, remainder 28);


--
-- Name: diffs_29; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_29 FOR VALUES WITH (modulus 100, remainder 29);


--
-- Name: diffs_3; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_3 FOR VALUES WITH (modulus 100, remainder 3);


--
-- Name: diffs_30; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_30 FOR VALUES WITH (modulus 100, remainder 30);


--
-- Name: diffs_31; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_31 FOR VALUES WITH (modulus 100, remainder 31);


--
-- Name: diffs_32; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_32 FOR VALUES WITH (modulus 100, remainder 32);


--
-- Name: diffs_33; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_33 FOR VALUES WITH (modulus 100, remainder 33);


--
-- Name: diffs_34; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_34 FOR VALUES WITH (modulus 100, remainder 34);


--
-- Name: diffs_35; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_35 FOR VALUES WITH (modulus 100, remainder 35);


--
-- Name: diffs_36; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_36 FOR VALUES WITH (modulus 100, remainder 36);


--
-- Name: diffs_37; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_37 FOR VALUES WITH (modulus 100, remainder 37);


--
-- Name: diffs_38; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_38 FOR VALUES WITH (modulus 100, remainder 38);


--
-- Name: diffs_39; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_39 FOR VALUES WITH (modulus 100, remainder 39);


--
-- Name: diffs_4; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_4 FOR VALUES WITH (modulus 100, remainder 4);


--
-- Name: diffs_40; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_40 FOR VALUES WITH (modulus 100, remainder 40);


--
-- Name: diffs_41; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_41 FOR VALUES WITH (modulus 100, remainder 41);


--
-- Name: diffs_42; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_42 FOR VALUES WITH (modulus 100, remainder 42);


--
-- Name: diffs_43; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_43 FOR VALUES WITH (modulus 100, remainder 43);


--
-- Name: diffs_44; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_44 FOR VALUES WITH (modulus 100, remainder 44);


--
-- Name: diffs_45; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_45 FOR VALUES WITH (modulus 100, remainder 45);


--
-- Name: diffs_46; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_46 FOR VALUES WITH (modulus 100, remainder 46);


--
-- Name: diffs_47; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_47 FOR VALUES WITH (modulus 100, remainder 47);


--
-- Name: diffs_48; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_48 FOR VALUES WITH (modulus 100, remainder 48);


--
-- Name: diffs_49; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_49 FOR VALUES WITH (modulus 100, remainder 49);


--
-- Name: diffs_5; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_5 FOR VALUES WITH (modulus 100, remainder 5);


--
-- Name: diffs_50; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_50 FOR VALUES WITH (modulus 100, remainder 50);


--
-- Name: diffs_51; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_51 FOR VALUES WITH (modulus 100, remainder 51);


--
-- Name: diffs_52; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_52 FOR VALUES WITH (modulus 100, remainder 52);


--
-- Name: diffs_53; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_53 FOR VALUES WITH (modulus 100, remainder 53);


--
-- Name: diffs_54; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_54 FOR VALUES WITH (modulus 100, remainder 54);


--
-- Name: diffs_55; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_55 FOR VALUES WITH (modulus 100, remainder 55);


--
-- Name: diffs_56; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_56 FOR VALUES WITH (modulus 100, remainder 56);


--
-- Name: diffs_57; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_57 FOR VALUES WITH (modulus 100, remainder 57);


--
-- Name: diffs_58; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_58 FOR VALUES WITH (modulus 100, remainder 58);


--
-- Name: diffs_59; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_59 FOR VALUES WITH (modulus 100, remainder 59);


--
-- Name: diffs_6; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_6 FOR VALUES WITH (modulus 100, remainder 6);


--
-- Name: diffs_60; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_60 FOR VALUES WITH (modulus 100, remainder 60);


--
-- Name: diffs_61; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_61 FOR VALUES WITH (modulus 100, remainder 61);


--
-- Name: diffs_62; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_62 FOR VALUES WITH (modulus 100, remainder 62);


--
-- Name: diffs_63; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_63 FOR VALUES WITH (modulus 100, remainder 63);


--
-- Name: diffs_64; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_64 FOR VALUES WITH (modulus 100, remainder 64);


--
-- Name: diffs_65; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_65 FOR VALUES WITH (modulus 100, remainder 65);


--
-- Name: diffs_66; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_66 FOR VALUES WITH (modulus 100, remainder 66);


--
-- Name: diffs_67; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_67 FOR VALUES WITH (modulus 100, remainder 67);


--
-- Name: diffs_68; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_68 FOR VALUES WITH (modulus 100, remainder 68);


--
-- Name: diffs_69; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_69 FOR VALUES WITH (modulus 100, remainder 69);


--
-- Name: diffs_7; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_7 FOR VALUES WITH (modulus 100, remainder 7);


--
-- Name: diffs_70; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_70 FOR VALUES WITH (modulus 100, remainder 70);


--
-- Name: diffs_71; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_71 FOR VALUES WITH (modulus 100, remainder 71);


--
-- Name: diffs_72; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_72 FOR VALUES WITH (modulus 100, remainder 72);


--
-- Name: diffs_73; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_73 FOR VALUES WITH (modulus 100, remainder 73);


--
-- Name: diffs_74; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_74 FOR VALUES WITH (modulus 100, remainder 74);


--
-- Name: diffs_75; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_75 FOR VALUES WITH (modulus 100, remainder 75);


--
-- Name: diffs_76; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_76 FOR VALUES WITH (modulus 100, remainder 76);


--
-- Name: diffs_77; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_77 FOR VALUES WITH (modulus 100, remainder 77);


--
-- Name: diffs_78; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_78 FOR VALUES WITH (modulus 100, remainder 78);


--
-- Name: diffs_79; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_79 FOR VALUES WITH (modulus 100, remainder 79);


--
-- Name: diffs_8; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_8 FOR VALUES WITH (modulus 100, remainder 8);


--
-- Name: diffs_80; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_80 FOR VALUES WITH (modulus 100, remainder 80);


--
-- Name: diffs_81; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_81 FOR VALUES WITH (modulus 100, remainder 81);


--
-- Name: diffs_82; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_82 FOR VALUES WITH (modulus 100, remainder 82);


--
-- Name: diffs_83; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_83 FOR VALUES WITH (modulus 100, remainder 83);


--
-- Name: diffs_84; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_84 FOR VALUES WITH (modulus 100, remainder 84);


--
-- Name: diffs_85; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_85 FOR VALUES WITH (modulus 100, remainder 85);


--
-- Name: diffs_86; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_86 FOR VALUES WITH (modulus 100, remainder 86);


--
-- Name: diffs_87; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_87 FOR VALUES WITH (modulus 100, remainder 87);


--
-- Name: diffs_88; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_88 FOR VALUES WITH (modulus 100, remainder 88);


--
-- Name: diffs_89; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_89 FOR VALUES WITH (modulus 100, remainder 89);


--
-- Name: diffs_9; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_9 FOR VALUES WITH (modulus 100, remainder 9);


--
-- Name: diffs_90; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_90 FOR VALUES WITH (modulus 100, remainder 90);


--
-- Name: diffs_91; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_91 FOR VALUES WITH (modulus 100, remainder 91);


--
-- Name: diffs_92; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_92 FOR VALUES WITH (modulus 100, remainder 92);


--
-- Name: diffs_93; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_93 FOR VALUES WITH (modulus 100, remainder 93);


--
-- Name: diffs_94; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_94 FOR VALUES WITH (modulus 100, remainder 94);


--
-- Name: diffs_95; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_95 FOR VALUES WITH (modulus 100, remainder 95);


--
-- Name: diffs_96; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_96 FOR VALUES WITH (modulus 100, remainder 96);


--
-- Name: diffs_97; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_97 FOR VALUES WITH (modulus 100, remainder 97);


--
-- Name: diffs_98; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_98 FOR VALUES WITH (modulus 100, remainder 98);


--
-- Name: diffs_99; Type: TABLE ATTACH; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs ATTACH PARTITION fis.diffs_99 FOR VALUES WITH (modulus 100, remainder 99);


--
-- Name: admin_dashboard_stats id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.admin_dashboard_stats ALTER COLUMN id SET DEFAULT nextval('fis.admin_dashboard_stats_id_seq'::regclass);


--
-- Name: analysis_aliases id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.analysis_aliases ALTER COLUMN id SET DEFAULT nextval('fis.analysis_aliases_id_seq'::regclass);


--
-- Name: code_location_dnfs id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.code_location_dnfs ALTER COLUMN id SET DEFAULT nextval('fis.code_location_dnfs_id_seq'::regclass);


--
-- Name: code_location_job_feeders id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.code_location_job_feeders ALTER COLUMN id SET DEFAULT nextval('fis.code_location_job_feeders_id_seq'::regclass);


--
-- Name: code_location_tarballs id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.code_location_tarballs ALTER COLUMN id SET DEFAULT nextval('fis.code_location_tarballs_id_seq'::regclass);


--
-- Name: code_locations id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.code_locations ALTER COLUMN id SET DEFAULT nextval('fis.code_locations_id_seq'::regclass);


--
-- Name: commit_flags id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.commit_flags ALTER COLUMN id SET DEFAULT nextval('fis.commit_flags_id_seq'::regclass);


--
-- Name: email_addresses id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.email_addresses ALTER COLUMN id SET DEFAULT nextval('fis.email_addresses_id_seq'::regclass);


--
-- Name: failure_groups id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.failure_groups ALTER COLUMN id SET DEFAULT nextval('fis.failure_groups_id_seq'::regclass);


--
-- Name: fisbot_events id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.fisbot_events ALTER COLUMN id SET DEFAULT nextval('fis.fisbot_events_id_seq'::regclass);


--
-- Name: load_averages id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.load_averages ALTER COLUMN id SET DEFAULT nextval('fis.load_averages_id_seq'::regclass);


--
-- Name: old_code_sets id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.old_code_sets ALTER COLUMN id SET DEFAULT nextval('fis.old_code_sets_id_seq'::regclass);


--
-- Name: repository_directories id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.repository_directories ALTER COLUMN id SET DEFAULT nextval('fis.repository_directories_id_seq'::regclass);


--
-- Name: repository_tags id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.repository_tags ALTER COLUMN id SET DEFAULT nextval('fis.repository_tags_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.subscriptions ALTER COLUMN id SET DEFAULT nextval('fis.subscriptions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.users ALTER COLUMN id SET DEFAULT nextval('fis.users_id_seq'::regclass);


--
-- Name: failure_groups id; Type: DEFAULT; Schema: oa; Owner: -
--

ALTER TABLE ONLY oa.failure_groups ALTER COLUMN id SET DEFAULT nextval('oa.failure_groups_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: oa; Owner: -
--

ALTER TABLE ONLY oa.jobs ALTER COLUMN id SET DEFAULT nextval('oa.jobs_id_seq'::regclass);


--
-- Name: worker_logs id; Type: DEFAULT; Schema: oa; Owner: -
--

ALTER TABLE ONLY oa.worker_logs ALTER COLUMN id SET DEFAULT nextval('oa.worker_logs_id_seq'::regclass);


--
-- Name: workers id; Type: DEFAULT; Schema: oa; Owner: -
--

ALTER TABLE ONLY oa.workers ALTER COLUMN id SET DEFAULT nextval('oa.workers_id_seq'::regclass);


--
-- Name: account_reports id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.account_reports ALTER COLUMN id SET DEFAULT nextval('oh.account_reports_id_seq'::regclass);


--
-- Name: actions id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.actions ALTER COLUMN id SET DEFAULT nextval('oh.actions_id_seq'::regclass);


--
-- Name: aliases id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.aliases ALTER COLUMN id SET DEFAULT nextval('oh.aliases_id_seq'::regclass);


--
-- Name: analysis_summaries id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.analysis_summaries ALTER COLUMN id SET DEFAULT nextval('oh.analysis_summaries_id_seq'::regclass);


--
-- Name: api_keys id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.api_keys ALTER COLUMN id SET DEFAULT nextval('oh.api_keys_id_seq'::regclass);


--
-- Name: attachments id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.attachments ALTER COLUMN id SET DEFAULT nextval('oh.attachments_id_seq'::regclass);


--
-- Name: authorizations id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.authorizations ALTER COLUMN id SET DEFAULT nextval('oh.authorizations_id_seq'::regclass);


--
-- Name: broken_links id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.broken_links ALTER COLUMN id SET DEFAULT nextval('oh.broken_links_id_seq'::regclass);


--
-- Name: clumps id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.clumps ALTER COLUMN id SET DEFAULT nextval('oh.clumps_id_seq'::regclass);


--
-- Name: code_location_scan id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.code_location_scan ALTER COLUMN id SET DEFAULT nextval('oh.code_location_scan_id_seq'::regclass);


--
-- Name: deleted_accounts id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.deleted_accounts ALTER COLUMN id SET DEFAULT nextval('oh.deleted_accounts_id_seq'::regclass);


--
-- Name: duplicates id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.duplicates ALTER COLUMN id SET DEFAULT nextval('oh.duplicates_id_seq'::regclass);


--
-- Name: event_subscription id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.event_subscription ALTER COLUMN id SET DEFAULT nextval('oh.event_subscription_id_seq'::regclass);


--
-- Name: exhibits id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.exhibits ALTER COLUMN id SET DEFAULT nextval('oh.exhibits_id_seq'::regclass);


--
-- Name: feedbacks id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.feedbacks ALTER COLUMN id SET DEFAULT nextval('oh.feedbacks_id_seq'::regclass);


--
-- Name: follows id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.follows ALTER COLUMN id SET DEFAULT nextval('oh.follows_id_seq'::regclass);


--
-- Name: invites id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.invites ALTER COLUMN id SET DEFAULT nextval('oh.invites_id_seq'::regclass);


--
-- Name: knowledge_base_statuses id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.knowledge_base_statuses ALTER COLUMN id SET DEFAULT nextval('oh.knowledge_base_statuses_id_seq'::regclass);


--
-- Name: kudo_scores id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.kudo_scores ALTER COLUMN id SET DEFAULT nextval('oh.kudo_scores_id_seq'::regclass);


--
-- Name: kudos id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.kudos ALTER COLUMN id SET DEFAULT nextval('oh.kudos_id_seq'::regclass);


--
-- Name: language_experiences id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.language_experiences ALTER COLUMN id SET DEFAULT nextval('oh.language_experiences_id_seq'::regclass);


--
-- Name: language_facts id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.language_facts ALTER COLUMN id SET DEFAULT nextval('oh.language_facts_id_seq'::regclass);


--
-- Name: license_license_permissions id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.license_license_permissions ALTER COLUMN id SET DEFAULT nextval('oh.license_license_permissions_id_seq1'::regclass);


--
-- Name: license_permission_roles id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.license_permission_roles ALTER COLUMN id SET DEFAULT nextval('oh.license_permission_roles_id_seq'::regclass);


--
-- Name: license_permissions id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.license_permissions ALTER COLUMN id SET DEFAULT nextval('oh.license_permissions_id_seq'::regclass);


--
-- Name: license_rights id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.license_rights ALTER COLUMN id SET DEFAULT nextval('oh.license_rights_id_seq'::regclass);


--
-- Name: link_categories_deleted id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.link_categories_deleted ALTER COLUMN id SET DEFAULT nextval('oh.link_categories_id_seq'::regclass);


--
-- Name: links id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.links ALTER COLUMN id SET DEFAULT nextval('oh.links_id_seq'::regclass);


--
-- Name: manages id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.manages ALTER COLUMN id SET DEFAULT nextval('oh.manages_id_seq'::regclass);


--
-- Name: markups id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.markups ALTER COLUMN id SET DEFAULT nextval('oh.markups_id_seq'::regclass);


--
-- Name: message_account_tags id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.message_account_tags ALTER COLUMN id SET DEFAULT nextval('oh.message_account_tags_id_seq'::regclass);


--
-- Name: message_project_tags id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.message_project_tags ALTER COLUMN id SET DEFAULT nextval('oh.message_project_tags_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.messages ALTER COLUMN id SET DEFAULT nextval('oh.messages_id_seq'::regclass);


--
-- Name: monthly_commit_histories id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.monthly_commit_histories ALTER COLUMN id SET DEFAULT nextval('oh.monthly_commit_histories_id_seq'::regclass);


--
-- Name: oauth_access_grants id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oh.oauth_access_grants_id_seq'::regclass);


--
-- Name: oauth_access_tokens id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oh.oauth_access_tokens_id_seq'::regclass);


--
-- Name: oauth_applications id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.oauth_applications ALTER COLUMN id SET DEFAULT nextval('oh.oauth_applications_id_seq'::regclass);


--
-- Name: oauth_nonces id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.oauth_nonces ALTER COLUMN id SET DEFAULT nextval('oh.oauth_nonces_id_seq'::regclass);


--
-- Name: org_stats_by_sectors id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.org_stats_by_sectors ALTER COLUMN id SET DEFAULT nextval('oh.org_stats_by_sectors_id_seq'::regclass);


--
-- Name: org_thirty_day_activities id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.org_thirty_day_activities ALTER COLUMN id SET DEFAULT nextval('oh.org_thirty_day_activities_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.organizations ALTER COLUMN id SET DEFAULT nextval('oh.organizations_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.permissions ALTER COLUMN id SET DEFAULT nextval('oh.permissions_id_seq'::regclass);


--
-- Name: positions id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.positions ALTER COLUMN id SET DEFAULT nextval('oh.positions_id_seq'::regclass);


--
-- Name: profiles id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.profiles ALTER COLUMN id SET DEFAULT nextval('oh.profiles_id_seq'::regclass);


--
-- Name: project_badges id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_badges ALTER COLUMN id SET DEFAULT nextval('oh.project_badges_id_seq'::regclass);


--
-- Name: project_events id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_events ALTER COLUMN id SET DEFAULT nextval('oh.project_events_id_seq'::regclass);


--
-- Name: project_experiences id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_experiences ALTER COLUMN id SET DEFAULT nextval('oh.project_experiences_id_seq'::regclass);


--
-- Name: project_reports id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_reports ALTER COLUMN id SET DEFAULT nextval('oh.project_reports_id_seq'::regclass);


--
-- Name: project_sboms id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_sboms ALTER COLUMN id SET DEFAULT nextval('oh.project_sboms_id_seq'::regclass);


--
-- Name: project_security_sets id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_security_sets ALTER COLUMN id SET DEFAULT nextval('oh.project_security_sets_id_seq'::regclass);


--
-- Name: project_vulnerability_reports id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_vulnerability_reports ALTER COLUMN id SET DEFAULT nextval('oh.project_vulnerability_reports_id_seq'::regclass);


--
-- Name: recently_active_accounts_cache id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.recently_active_accounts_cache ALTER COLUMN id SET DEFAULT nextval('oh.recently_active_accounts_cache_id_seq'::regclass);


--
-- Name: recommend_entries id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.recommend_entries ALTER COLUMN id SET DEFAULT nextval('oh.recommend_entries_id_seq'::regclass);


--
-- Name: recommendations id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.recommendations ALTER COLUMN id SET DEFAULT nextval('oh.recommendations_id_seq'::regclass);


--
-- Name: releases id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.releases ALTER COLUMN id SET DEFAULT nextval('oh.releases_id_seq'::regclass);


--
-- Name: reports id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.reports ALTER COLUMN id SET DEFAULT nextval('oh.reports_id_seq'::regclass);


--
-- Name: reverification_trackers id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.reverification_trackers ALTER COLUMN id SET DEFAULT nextval('oh.reverification_trackers_id_seq'::regclass);


--
-- Name: reviewed_non_spammers id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.reviewed_non_spammers ALTER COLUMN id SET DEFAULT nextval('oh.reviewed_non_spammers_id_seq'::regclass);


--
-- Name: scan_analytics id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.scan_analytics ALTER COLUMN id SET DEFAULT nextval('oh.scan_analytics_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.settings ALTER COLUMN id SET DEFAULT nextval('oh.settings_id_seq'::regclass);


--
-- Name: stack_ignores id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.stack_ignores ALTER COLUMN id SET DEFAULT nextval('oh.stack_ignores_id_seq'::regclass);


--
-- Name: successful_accounts id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.successful_accounts ALTER COLUMN id SET DEFAULT nextval('oh.successful_accounts_id_seq'::regclass);


--
-- Name: thirty_day_summaries id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.thirty_day_summaries ALTER COLUMN id SET DEFAULT nextval('oh.thirty_day_summaries_id_seq'::regclass);


--
-- Name: tools id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.tools ALTER COLUMN id SET DEFAULT nextval('oh.tools_id_seq'::regclass);


--
-- Name: verifications id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.verifications ALTER COLUMN id SET DEFAULT nextval('oh.verifications_id_seq'::regclass);


--
-- Name: vita_analyses id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.vita_analyses ALTER COLUMN id SET DEFAULT nextval('oh.vita_analyses_id_seq'::regclass);


--
-- Name: vitae id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.vitae ALTER COLUMN id SET DEFAULT nextval('oh.vitae_id_seq'::regclass);


--
-- Name: vulnerabilities id; Type: DEFAULT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.vulnerabilities ALTER COLUMN id SET DEFAULT nextval('oh.vulnerabilities_id_seq'::regclass);


--
-- Name: admin_dashboard_stats admin_dashboard_stats_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.admin_dashboard_stats
    ADD CONSTRAINT admin_dashboard_stats_pkey PRIMARY KEY (id);


--
-- Name: analysis_aliases analysis_aliases_analysis_id_commit_name_id; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.analysis_aliases
    ADD CONSTRAINT analysis_aliases_analysis_id_commit_name_id UNIQUE (analysis_id, commit_name_id);


--
-- Name: analysis_aliases analysis_aliases_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.analysis_aliases
    ADD CONSTRAINT analysis_aliases_pkey PRIMARY KEY (id);


--
-- Name: analysis_sloc_sets analysis_sloc_sets_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.analysis_sloc_sets
    ADD CONSTRAINT analysis_sloc_sets_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: code_location_dnfs code_location_dnfs_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.code_location_dnfs
    ADD CONSTRAINT code_location_dnfs_pkey PRIMARY KEY (id);


--
-- Name: code_location_job_feeders code_location_job_feeders_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.code_location_job_feeders
    ADD CONSTRAINT code_location_job_feeders_pkey PRIMARY KEY (id);


--
-- Name: code_location_tarballs code_location_tarballs_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.code_location_tarballs
    ADD CONSTRAINT code_location_tarballs_pkey PRIMARY KEY (id);


--
-- Name: code_locations code_locations_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.code_locations
    ADD CONSTRAINT code_locations_pkey PRIMARY KEY (id);


--
-- Name: code_sets code_sets_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.code_sets
    ADD CONSTRAINT code_sets_pkey PRIMARY KEY (id);


--
-- Name: commit_flags commit_flags_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.commit_flags
    ADD CONSTRAINT commit_flags_pkey PRIMARY KEY (id);


--
-- Name: commits commits_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.commits
    ADD CONSTRAINT commits_pkey PRIMARY KEY (id);


--
-- Name: diffs_orig diffs_orig_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs_orig
    ADD CONSTRAINT diffs_orig_pkey PRIMARY KEY (id);


--
-- Name: email_addresses email_addresses_address_key; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.email_addresses
    ADD CONSTRAINT email_addresses_address_key UNIQUE (address);


--
-- Name: email_addresses email_addresses_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.email_addresses
    ADD CONSTRAINT email_addresses_pkey PRIMARY KEY (id);


--
-- Name: failure_groups failure_groups_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.failure_groups
    ADD CONSTRAINT failure_groups_pkey PRIMARY KEY (id);


--
-- Name: fisbot_events fisbot_events_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.fisbot_events
    ADD CONSTRAINT fisbot_events_pkey PRIMARY KEY (id);


--
-- Name: fyles fyles_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.fyles
    ADD CONSTRAINT fyles_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: load_averages load_averages_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.load_averages
    ADD CONSTRAINT load_averages_pkey PRIMARY KEY (id);


--
-- Name: old_code_sets old_code_sets_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.old_code_sets
    ADD CONSTRAINT old_code_sets_pkey PRIMARY KEY (id);


--
-- Name: registration_keys registration_keys_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.registration_keys
    ADD CONSTRAINT registration_keys_pkey PRIMARY KEY (id);


--
-- Name: repositories repositories_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: repository_directories repository_directories_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.repository_directories
    ADD CONSTRAINT repository_directories_pkey PRIMARY KEY (id);


--
-- Name: repository_tags repository_tags_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.repository_tags
    ADD CONSTRAINT repository_tags_pkey PRIMARY KEY (id);


--
-- Name: slave_logs slave_logs_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.slave_logs
    ADD CONSTRAINT slave_logs_pkey PRIMARY KEY (id);


--
-- Name: slaves slave_permissions_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.slaves
    ADD CONSTRAINT slave_permissions_pkey PRIMARY KEY (id);


--
-- Name: sloc_sets sloc_sets_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.sloc_sets
    ADD CONSTRAINT sloc_sets_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: diffs_orig unique_diffs_on_commit_id_fyle_id; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.diffs_orig
    ADD CONSTRAINT unique_diffs_on_commit_id_fyle_id UNIQUE (commit_id, fyle_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: failure_groups failure_groups_pkey; Type: CONSTRAINT; Schema: oa; Owner: -
--

ALTER TABLE ONLY oa.failure_groups
    ADD CONSTRAINT failure_groups_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: oa; Owner: -
--

ALTER TABLE ONLY oa.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: registration_keys registration_keys_pkey; Type: CONSTRAINT; Schema: oa; Owner: -
--

ALTER TABLE ONLY oa.registration_keys
    ADD CONSTRAINT registration_keys_pkey PRIMARY KEY (id);


--
-- Name: worker_logs worker_logs_pkey; Type: CONSTRAINT; Schema: oa; Owner: -
--

ALTER TABLE ONLY oa.worker_logs
    ADD CONSTRAINT worker_logs_pkey PRIMARY KEY (id);


--
-- Name: workers workers_pkey; Type: CONSTRAINT; Schema: oa; Owner: -
--

ALTER TABLE ONLY oa.workers
    ADD CONSTRAINT workers_pkey PRIMARY KEY (id);


--
-- Name: account_reports account_reports_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.account_reports
    ADD CONSTRAINT account_reports_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_email_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.accounts
    ADD CONSTRAINT accounts_email_key UNIQUE (email);


--
-- Name: accounts accounts_login_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.accounts
    ADD CONSTRAINT accounts_login_key UNIQUE (login);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: actions actions_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (id);


--
-- Name: activity_facts activity_facts_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.activity_facts
    ADD CONSTRAINT activity_facts_pkey PRIMARY KEY (id);


--
-- Name: aliases aliases_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.aliases
    ADD CONSTRAINT aliases_pkey PRIMARY KEY (id);


--
-- Name: aliases aliases_project_id_name_id; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.aliases
    ADD CONSTRAINT aliases_project_id_name_id UNIQUE (project_id, commit_name_id);


--
-- Name: analyses analyses_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.analyses
    ADD CONSTRAINT analyses_pkey PRIMARY KEY (id);


--
-- Name: analysis_summaries analysis_summaries_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.analysis_summaries
    ADD CONSTRAINT analysis_summaries_pkey PRIMARY KEY (id);


--
-- Name: api_keys api_keys_key_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.api_keys
    ADD CONSTRAINT api_keys_key_key UNIQUE (key);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authorizations authorizations_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.authorizations
    ADD CONSTRAINT authorizations_pkey PRIMARY KEY (id);


--
-- Name: broken_links broken_links_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.broken_links
    ADD CONSTRAINT broken_links_pkey PRIMARY KEY (id);


--
-- Name: positions claims_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.positions
    ADD CONSTRAINT claims_pkey PRIMARY KEY (id);


--
-- Name: clumps clumps_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.clumps
    ADD CONSTRAINT clumps_pkey PRIMARY KEY (id);


--
-- Name: code_location_scan code_location_scan_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.code_location_scan
    ADD CONSTRAINT code_location_scan_pkey PRIMARY KEY (id);


--
-- Name: deleted_accounts deleted_accounts_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.deleted_accounts
    ADD CONSTRAINT deleted_accounts_pkey PRIMARY KEY (id);


--
-- Name: duplicates duplicates_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.duplicates
    ADD CONSTRAINT duplicates_pkey PRIMARY KEY (id);


--
-- Name: edits edits_pkey1; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.edits
    ADD CONSTRAINT edits_pkey1 PRIMARY KEY (id);


--
-- Name: enlistments enlistments_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.enlistments
    ADD CONSTRAINT enlistments_pkey PRIMARY KEY (id);


--
-- Name: event_subscription event_subscription_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.event_subscription
    ADD CONSTRAINT event_subscription_pkey PRIMARY KEY (id);


--
-- Name: exhibits exhibits_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.exhibits
    ADD CONSTRAINT exhibits_pkey PRIMARY KEY (id);


--
-- Name: factoids factoids_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.factoids
    ADD CONSTRAINT factoids_pkey PRIMARY KEY (id);


--
-- Name: feedbacks feedbacks_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (id);


--
-- Name: follows follows_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.follows
    ADD CONSTRAINT follows_pkey PRIMARY KEY (id);


--
-- Name: forums forums_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.forums
    ADD CONSTRAINT forums_pkey PRIMARY KEY (id);


--
-- Name: github_project github_project_project_id_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.github_project
    ADD CONSTRAINT github_project_project_id_key UNIQUE (project_id, owner);


--
-- Name: helpfuls helpfuls_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.helpfuls
    ADD CONSTRAINT helpfuls_pkey PRIMARY KEY (id);


--
-- Name: invites invites_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_statuses knowledge_base_statuses_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.knowledge_base_statuses
    ADD CONSTRAINT knowledge_base_statuses_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_statuses knowledge_base_statuses_project_id_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.knowledge_base_statuses
    ADD CONSTRAINT knowledge_base_statuses_project_id_key UNIQUE (project_id);


--
-- Name: kudo_scores kudo_scores_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.kudo_scores
    ADD CONSTRAINT kudo_scores_pkey PRIMARY KEY (id);


--
-- Name: kudos kudos_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.kudos
    ADD CONSTRAINT kudos_pkey PRIMARY KEY (id);


--
-- Name: language_experiences language_experiences_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.language_experiences
    ADD CONSTRAINT language_experiences_pkey PRIMARY KEY (id);


--
-- Name: language_facts language_facts_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.language_facts
    ADD CONSTRAINT language_facts_pkey PRIMARY KEY (id);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: license_facts license_facts_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.license_facts
    ADD CONSTRAINT license_facts_pkey PRIMARY KEY (id);


--
-- Name: license_license_permissions license_license_permissions_pkey1; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.license_license_permissions
    ADD CONSTRAINT license_license_permissions_pkey1 PRIMARY KEY (id);


--
-- Name: license_permission_roles license_permission_roles_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.license_permission_roles
    ADD CONSTRAINT license_permission_roles_pkey PRIMARY KEY (id);


--
-- Name: license_permissions license_permissions_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.license_permissions
    ADD CONSTRAINT license_permissions_pkey PRIMARY KEY (id);


--
-- Name: license_rights license_rights_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.license_rights
    ADD CONSTRAINT license_rights_pkey PRIMARY KEY (id);


--
-- Name: licenses licenses_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (id);


--
-- Name: link_categories_deleted link_categories_name_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.link_categories_deleted
    ADD CONSTRAINT link_categories_name_key UNIQUE (name);


--
-- Name: link_categories_deleted link_categories_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.link_categories_deleted
    ADD CONSTRAINT link_categories_pkey PRIMARY KEY (id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: manages manages_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.manages
    ADD CONSTRAINT manages_pkey PRIMARY KEY (id);


--
-- Name: markups markups_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.markups
    ADD CONSTRAINT markups_pkey PRIMARY KEY (id);


--
-- Name: message_account_tags message_account_tags_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.message_account_tags
    ADD CONSTRAINT message_account_tags_pkey PRIMARY KEY (id);


--
-- Name: message_project_tags message_project_tags_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.message_project_tags
    ADD CONSTRAINT message_project_tags_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: monthly_commit_histories monthly_commit_histories_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.monthly_commit_histories
    ADD CONSTRAINT monthly_commit_histories_pkey PRIMARY KEY (id);


--
-- Name: name_facts name_facts_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.name_facts
    ADD CONSTRAINT name_facts_pkey PRIMARY KEY (id);


--
-- Name: name_language_facts name_language_facts_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.name_language_facts
    ADD CONSTRAINT name_language_facts_pkey PRIMARY KEY (id);


--
-- Name: names names_name_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.names
    ADD CONSTRAINT names_name_key UNIQUE (name);


--
-- Name: names names_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.names
    ADD CONSTRAINT names_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: oauth_nonces oauth_nonces_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.oauth_nonces
    ADD CONSTRAINT oauth_nonces_pkey PRIMARY KEY (id);


--
-- Name: org_stats_by_sectors org_stats_by_sectors_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.org_stats_by_sectors
    ADD CONSTRAINT org_stats_by_sectors_pkey PRIMARY KEY (id);


--
-- Name: org_thirty_day_activities org_thirty_day_activities_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.org_thirty_day_activities
    ADD CONSTRAINT org_thirty_day_activities_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: people people_id_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.people
    ADD CONSTRAINT people_id_key UNIQUE (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: pg_ts_cfg pg_ts_cfg_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.pg_ts_cfg
    ADD CONSTRAINT pg_ts_cfg_pkey PRIMARY KEY (ts_name);


--
-- Name: pg_ts_cfgmap pg_ts_cfgmap_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.pg_ts_cfgmap
    ADD CONSTRAINT pg_ts_cfgmap_pkey PRIMARY KEY (ts_name, tok_alias);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: project_badges project_badges_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_badges
    ADD CONSTRAINT project_badges_pkey PRIMARY KEY (id);


--
-- Name: project_events project_events_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_events
    ADD CONSTRAINT project_events_pkey PRIMARY KEY (id);


--
-- Name: project_experiences project_experiences_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_experiences
    ADD CONSTRAINT project_experiences_pkey PRIMARY KEY (id);


--
-- Name: project_licenses project_licenses_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_licenses
    ADD CONSTRAINT project_licenses_pkey PRIMARY KEY (id);


--
-- Name: project_reports project_reports_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_reports
    ADD CONSTRAINT project_reports_pkey PRIMARY KEY (id);


--
-- Name: project_reports project_reports_project_id_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_reports
    ADD CONSTRAINT project_reports_project_id_key UNIQUE (project_id, report_id);


--
-- Name: project_sboms project_sboms_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_sboms
    ADD CONSTRAINT project_sboms_pkey PRIMARY KEY (id);


--
-- Name: project_security_sets project_security_sets_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_security_sets
    ADD CONSTRAINT project_security_sets_pkey PRIMARY KEY (id);


--
-- Name: project_vulnerability_reports project_vulnerability_reports_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_vulnerability_reports
    ADD CONSTRAINT project_vulnerability_reports_pkey PRIMARY KEY (id);


--
-- Name: projects projects_kb_id_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.projects
    ADD CONSTRAINT projects_kb_id_key UNIQUE (kb_id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: projects projects_url_name_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.projects
    ADD CONSTRAINT projects_url_name_key UNIQUE (vanity_url);


--
-- Name: ratings ratings_account_id_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.ratings
    ADD CONSTRAINT ratings_account_id_key UNIQUE (account_id, project_id);


--
-- Name: ratings ratings_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (id);


--
-- Name: recommend_entries recommend_entries_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.recommend_entries
    ADD CONSTRAINT recommend_entries_pkey PRIMARY KEY (id);


--
-- Name: recommendations recommendations_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.recommendations
    ADD CONSTRAINT recommendations_pkey PRIMARY KEY (id);


--
-- Name: releases releases_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.releases
    ADD CONSTRAINT releases_pkey PRIMARY KEY (id);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: reverification_trackers reverification_trackers_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.reverification_trackers
    ADD CONSTRAINT reverification_trackers_pkey PRIMARY KEY (id);


--
-- Name: reviewed_non_spammers reviewed_non_spammers_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.reviewed_non_spammers
    ADD CONSTRAINT reviewed_non_spammers_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_account_id_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.reviews
    ADD CONSTRAINT reviews_account_id_key UNIQUE (account_id, project_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: rss_articles rss_articles_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.rss_articles
    ADD CONSTRAINT rss_articles_pkey PRIMARY KEY (id);


--
-- Name: rss_feeds rss_feeds_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.rss_feeds
    ADD CONSTRAINT rss_feeds_pkey PRIMARY KEY (id);


--
-- Name: rss_subscriptions rss_subscriptions_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.rss_subscriptions
    ADD CONSTRAINT rss_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: scan_analytics scan_analytics_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.scan_analytics
    ADD CONSTRAINT scan_analytics_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_session_id_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.sessions
    ADD CONSTRAINT sessions_session_id_key UNIQUE (session_id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: stack_entries stack_entries_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.stack_entries
    ADD CONSTRAINT stack_entries_pkey PRIMARY KEY (id);


--
-- Name: stack_ignores stack_ignores_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.stack_ignores
    ADD CONSTRAINT stack_ignores_pkey PRIMARY KEY (id);


--
-- Name: stacks stacks_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.stacks
    ADD CONSTRAINT stacks_pkey PRIMARY KEY (id);


--
-- Name: successful_accounts successful_accounts_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.successful_accounts
    ADD CONSTRAINT successful_accounts_pkey PRIMARY KEY (id);


--
-- Name: taggings taggings_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: thirty_day_summaries thirty_day_summaries_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.thirty_day_summaries
    ADD CONSTRAINT thirty_day_summaries_pkey PRIMARY KEY (id);


--
-- Name: tools tools_name_key; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.tools
    ADD CONSTRAINT tools_name_key UNIQUE (name);


--
-- Name: tools tools_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.tools
    ADD CONSTRAINT tools_pkey PRIMARY KEY (id);


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: positions unique_account_id_project_id; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.positions
    ADD CONSTRAINT unique_account_id_project_id UNIQUE (account_id, project_id);


--
-- Name: authorizations unique_authorizations_token; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.authorizations
    ADD CONSTRAINT unique_authorizations_token UNIQUE (token);


--
-- Name: oauth_nonces unique_oauth_nonces_nonce_timestamp; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.oauth_nonces
    ADD CONSTRAINT unique_oauth_nonces_nonce_timestamp UNIQUE (nonce, "timestamp");


--
-- Name: project_events unique_project_events; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_events
    ADD CONSTRAINT unique_project_events UNIQUE (project_id, type, key);


--
-- Name: positions unique_project_id_name_id; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.positions
    ADD CONSTRAINT unique_project_id_name_id UNIQUE (project_id, name_id);


--
-- Name: rss_subscriptions unique_project_id_rss_feed_id; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.rss_subscriptions
    ADD CONSTRAINT unique_project_id_rss_feed_id UNIQUE (project_id, rss_feed_id);


--
-- Name: rss_articles unique_rss_feed_id_guid; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.rss_articles
    ADD CONSTRAINT unique_rss_feed_id_guid UNIQUE (rss_feed_id, guid);


--
-- Name: taggings unique_taggings_tag_id_taggable_id_taggable_type; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.taggings
    ADD CONSTRAINT unique_taggings_tag_id_taggable_id_taggable_type UNIQUE (tag_id, taggable_id, taggable_type);


--
-- Name: verifications verifications_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.verifications
    ADD CONSTRAINT verifications_pkey PRIMARY KEY (id);


--
-- Name: vita_analyses vita_analyses_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.vita_analyses
    ADD CONSTRAINT vita_analyses_pkey PRIMARY KEY (id);


--
-- Name: vitae vitae_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.vitae
    ADD CONSTRAINT vitae_pkey PRIMARY KEY (id);


--
-- Name: vulnerabilities vulnerabilities_pkey; Type: CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.vulnerabilities
    ADD CONSTRAINT vulnerabilities_pkey PRIMARY KEY (id);


--
-- Name: index_diffs_on_code_set_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_diffs_on_code_set_id ON ONLY fis.diffs USING btree (code_set_id);


--
-- Name: diffs_0_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_0_code_set_id_idx ON fis.diffs_0 USING btree (code_set_id);


--
-- Name: index_diffs_on_commit_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_diffs_on_commit_id ON ONLY fis.diffs USING btree (commit_id);


--
-- Name: diffs_0_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_0_commit_id_idx ON fis.diffs_0 USING btree (commit_id);


--
-- Name: index_diffs_on_fyle_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_diffs_on_fyle_id ON ONLY fis.diffs USING btree (fyle_id);


--
-- Name: diffs_0_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_0_fyle_id_idx ON fis.diffs_0 USING btree (fyle_id);


--
-- Name: index_diffs_on_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_diffs_on_id ON ONLY fis.diffs USING btree (id);


--
-- Name: diffs_0_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_0_id_idx ON fis.diffs_0 USING btree (id);


--
-- Name: diffs_10_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_10_code_set_id_idx ON fis.diffs_10 USING btree (code_set_id);


--
-- Name: diffs_10_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_10_commit_id_idx ON fis.diffs_10 USING btree (commit_id);


--
-- Name: diffs_10_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_10_fyle_id_idx ON fis.diffs_10 USING btree (fyle_id);


--
-- Name: diffs_10_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_10_id_idx ON fis.diffs_10 USING btree (id);


--
-- Name: diffs_11_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_11_code_set_id_idx ON fis.diffs_11 USING btree (code_set_id);


--
-- Name: diffs_11_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_11_commit_id_idx ON fis.diffs_11 USING btree (commit_id);


--
-- Name: diffs_11_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_11_fyle_id_idx ON fis.diffs_11 USING btree (fyle_id);


--
-- Name: diffs_11_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_11_id_idx ON fis.diffs_11 USING btree (id);


--
-- Name: diffs_12_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_12_code_set_id_idx ON fis.diffs_12 USING btree (code_set_id);


--
-- Name: diffs_12_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_12_commit_id_idx ON fis.diffs_12 USING btree (commit_id);


--
-- Name: diffs_12_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_12_fyle_id_idx ON fis.diffs_12 USING btree (fyle_id);


--
-- Name: diffs_12_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_12_id_idx ON fis.diffs_12 USING btree (id);


--
-- Name: diffs_13_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_13_code_set_id_idx ON fis.diffs_13 USING btree (code_set_id);


--
-- Name: diffs_13_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_13_commit_id_idx ON fis.diffs_13 USING btree (commit_id);


--
-- Name: diffs_13_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_13_fyle_id_idx ON fis.diffs_13 USING btree (fyle_id);


--
-- Name: diffs_13_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_13_id_idx ON fis.diffs_13 USING btree (id);


--
-- Name: diffs_14_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_14_code_set_id_idx ON fis.diffs_14 USING btree (code_set_id);


--
-- Name: diffs_14_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_14_commit_id_idx ON fis.diffs_14 USING btree (commit_id);


--
-- Name: diffs_14_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_14_fyle_id_idx ON fis.diffs_14 USING btree (fyle_id);


--
-- Name: diffs_14_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_14_id_idx ON fis.diffs_14 USING btree (id);


--
-- Name: diffs_15_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_15_code_set_id_idx ON fis.diffs_15 USING btree (code_set_id);


--
-- Name: diffs_15_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_15_commit_id_idx ON fis.diffs_15 USING btree (commit_id);


--
-- Name: diffs_15_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_15_fyle_id_idx ON fis.diffs_15 USING btree (fyle_id);


--
-- Name: diffs_15_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_15_id_idx ON fis.diffs_15 USING btree (id);


--
-- Name: diffs_16_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_16_code_set_id_idx ON fis.diffs_16 USING btree (code_set_id);


--
-- Name: diffs_16_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_16_commit_id_idx ON fis.diffs_16 USING btree (commit_id);


--
-- Name: diffs_16_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_16_fyle_id_idx ON fis.diffs_16 USING btree (fyle_id);


--
-- Name: diffs_16_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_16_id_idx ON fis.diffs_16 USING btree (id);


--
-- Name: diffs_17_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_17_code_set_id_idx ON fis.diffs_17 USING btree (code_set_id);


--
-- Name: diffs_17_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_17_commit_id_idx ON fis.diffs_17 USING btree (commit_id);


--
-- Name: diffs_17_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_17_fyle_id_idx ON fis.diffs_17 USING btree (fyle_id);


--
-- Name: diffs_17_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_17_id_idx ON fis.diffs_17 USING btree (id);


--
-- Name: diffs_18_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_18_code_set_id_idx ON fis.diffs_18 USING btree (code_set_id);


--
-- Name: diffs_18_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_18_commit_id_idx ON fis.diffs_18 USING btree (commit_id);


--
-- Name: diffs_18_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_18_fyle_id_idx ON fis.diffs_18 USING btree (fyle_id);


--
-- Name: diffs_18_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_18_id_idx ON fis.diffs_18 USING btree (id);


--
-- Name: diffs_19_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_19_code_set_id_idx ON fis.diffs_19 USING btree (code_set_id);


--
-- Name: diffs_19_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_19_commit_id_idx ON fis.diffs_19 USING btree (commit_id);


--
-- Name: diffs_19_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_19_fyle_id_idx ON fis.diffs_19 USING btree (fyle_id);


--
-- Name: diffs_19_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_19_id_idx ON fis.diffs_19 USING btree (id);


--
-- Name: diffs_1_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_1_code_set_id_idx ON fis.diffs_1 USING btree (code_set_id);


--
-- Name: diffs_1_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_1_commit_id_idx ON fis.diffs_1 USING btree (commit_id);


--
-- Name: diffs_1_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_1_fyle_id_idx ON fis.diffs_1 USING btree (fyle_id);


--
-- Name: diffs_1_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_1_id_idx ON fis.diffs_1 USING btree (id);


--
-- Name: diffs_20_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_20_code_set_id_idx ON fis.diffs_20 USING btree (code_set_id);


--
-- Name: diffs_20_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_20_commit_id_idx ON fis.diffs_20 USING btree (commit_id);


--
-- Name: diffs_20_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_20_fyle_id_idx ON fis.diffs_20 USING btree (fyle_id);


--
-- Name: diffs_20_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_20_id_idx ON fis.diffs_20 USING btree (id);


--
-- Name: diffs_21_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_21_code_set_id_idx ON fis.diffs_21 USING btree (code_set_id);


--
-- Name: diffs_21_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_21_commit_id_idx ON fis.diffs_21 USING btree (commit_id);


--
-- Name: diffs_21_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_21_fyle_id_idx ON fis.diffs_21 USING btree (fyle_id);


--
-- Name: diffs_21_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_21_id_idx ON fis.diffs_21 USING btree (id);


--
-- Name: diffs_22_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_22_code_set_id_idx ON fis.diffs_22 USING btree (code_set_id);


--
-- Name: diffs_22_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_22_commit_id_idx ON fis.diffs_22 USING btree (commit_id);


--
-- Name: diffs_22_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_22_fyle_id_idx ON fis.diffs_22 USING btree (fyle_id);


--
-- Name: diffs_22_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_22_id_idx ON fis.diffs_22 USING btree (id);


--
-- Name: diffs_23_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_23_code_set_id_idx ON fis.diffs_23 USING btree (code_set_id);


--
-- Name: diffs_23_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_23_commit_id_idx ON fis.diffs_23 USING btree (commit_id);


--
-- Name: diffs_23_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_23_fyle_id_idx ON fis.diffs_23 USING btree (fyle_id);


--
-- Name: diffs_23_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_23_id_idx ON fis.diffs_23 USING btree (id);


--
-- Name: diffs_24_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_24_code_set_id_idx ON fis.diffs_24 USING btree (code_set_id);


--
-- Name: diffs_24_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_24_commit_id_idx ON fis.diffs_24 USING btree (commit_id);


--
-- Name: diffs_24_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_24_fyle_id_idx ON fis.diffs_24 USING btree (fyle_id);


--
-- Name: diffs_24_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_24_id_idx ON fis.diffs_24 USING btree (id);


--
-- Name: diffs_25_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_25_code_set_id_idx ON fis.diffs_25 USING btree (code_set_id);


--
-- Name: diffs_25_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_25_commit_id_idx ON fis.diffs_25 USING btree (commit_id);


--
-- Name: diffs_25_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_25_fyle_id_idx ON fis.diffs_25 USING btree (fyle_id);


--
-- Name: diffs_25_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_25_id_idx ON fis.diffs_25 USING btree (id);


--
-- Name: diffs_26_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_26_code_set_id_idx ON fis.diffs_26 USING btree (code_set_id);


--
-- Name: diffs_26_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_26_commit_id_idx ON fis.diffs_26 USING btree (commit_id);


--
-- Name: diffs_26_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_26_fyle_id_idx ON fis.diffs_26 USING btree (fyle_id);


--
-- Name: diffs_26_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_26_id_idx ON fis.diffs_26 USING btree (id);


--
-- Name: diffs_27_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_27_code_set_id_idx ON fis.diffs_27 USING btree (code_set_id);


--
-- Name: diffs_27_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_27_commit_id_idx ON fis.diffs_27 USING btree (commit_id);


--
-- Name: diffs_27_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_27_fyle_id_idx ON fis.diffs_27 USING btree (fyle_id);


--
-- Name: diffs_27_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_27_id_idx ON fis.diffs_27 USING btree (id);


--
-- Name: diffs_28_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_28_code_set_id_idx ON fis.diffs_28 USING btree (code_set_id);


--
-- Name: diffs_28_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_28_commit_id_idx ON fis.diffs_28 USING btree (commit_id);


--
-- Name: diffs_28_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_28_fyle_id_idx ON fis.diffs_28 USING btree (fyle_id);


--
-- Name: diffs_28_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_28_id_idx ON fis.diffs_28 USING btree (id);


--
-- Name: diffs_29_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_29_code_set_id_idx ON fis.diffs_29 USING btree (code_set_id);


--
-- Name: diffs_29_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_29_commit_id_idx ON fis.diffs_29 USING btree (commit_id);


--
-- Name: diffs_29_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_29_fyle_id_idx ON fis.diffs_29 USING btree (fyle_id);


--
-- Name: diffs_29_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_29_id_idx ON fis.diffs_29 USING btree (id);


--
-- Name: diffs_2_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_2_code_set_id_idx ON fis.diffs_2 USING btree (code_set_id);


--
-- Name: diffs_2_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_2_commit_id_idx ON fis.diffs_2 USING btree (commit_id);


--
-- Name: diffs_2_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_2_fyle_id_idx ON fis.diffs_2 USING btree (fyle_id);


--
-- Name: diffs_2_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_2_id_idx ON fis.diffs_2 USING btree (id);


--
-- Name: diffs_30_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_30_code_set_id_idx ON fis.diffs_30 USING btree (code_set_id);


--
-- Name: diffs_30_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_30_commit_id_idx ON fis.diffs_30 USING btree (commit_id);


--
-- Name: diffs_30_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_30_fyle_id_idx ON fis.diffs_30 USING btree (fyle_id);


--
-- Name: diffs_30_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_30_id_idx ON fis.diffs_30 USING btree (id);


--
-- Name: diffs_31_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_31_code_set_id_idx ON fis.diffs_31 USING btree (code_set_id);


--
-- Name: diffs_31_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_31_commit_id_idx ON fis.diffs_31 USING btree (commit_id);


--
-- Name: diffs_31_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_31_fyle_id_idx ON fis.diffs_31 USING btree (fyle_id);


--
-- Name: diffs_31_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_31_id_idx ON fis.diffs_31 USING btree (id);


--
-- Name: diffs_32_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_32_code_set_id_idx ON fis.diffs_32 USING btree (code_set_id);


--
-- Name: diffs_32_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_32_commit_id_idx ON fis.diffs_32 USING btree (commit_id);


--
-- Name: diffs_32_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_32_fyle_id_idx ON fis.diffs_32 USING btree (fyle_id);


--
-- Name: diffs_32_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_32_id_idx ON fis.diffs_32 USING btree (id);


--
-- Name: diffs_33_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_33_code_set_id_idx ON fis.diffs_33 USING btree (code_set_id);


--
-- Name: diffs_33_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_33_commit_id_idx ON fis.diffs_33 USING btree (commit_id);


--
-- Name: diffs_33_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_33_fyle_id_idx ON fis.diffs_33 USING btree (fyle_id);


--
-- Name: diffs_33_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_33_id_idx ON fis.diffs_33 USING btree (id);


--
-- Name: diffs_34_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_34_code_set_id_idx ON fis.diffs_34 USING btree (code_set_id);


--
-- Name: diffs_34_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_34_commit_id_idx ON fis.diffs_34 USING btree (commit_id);


--
-- Name: diffs_34_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_34_fyle_id_idx ON fis.diffs_34 USING btree (fyle_id);


--
-- Name: diffs_34_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_34_id_idx ON fis.diffs_34 USING btree (id);


--
-- Name: diffs_35_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_35_code_set_id_idx ON fis.diffs_35 USING btree (code_set_id);


--
-- Name: diffs_35_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_35_commit_id_idx ON fis.diffs_35 USING btree (commit_id);


--
-- Name: diffs_35_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_35_fyle_id_idx ON fis.diffs_35 USING btree (fyle_id);


--
-- Name: diffs_35_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_35_id_idx ON fis.diffs_35 USING btree (id);


--
-- Name: diffs_36_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_36_code_set_id_idx ON fis.diffs_36 USING btree (code_set_id);


--
-- Name: diffs_36_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_36_commit_id_idx ON fis.diffs_36 USING btree (commit_id);


--
-- Name: diffs_36_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_36_fyle_id_idx ON fis.diffs_36 USING btree (fyle_id);


--
-- Name: diffs_36_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_36_id_idx ON fis.diffs_36 USING btree (id);


--
-- Name: diffs_37_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_37_code_set_id_idx ON fis.diffs_37 USING btree (code_set_id);


--
-- Name: diffs_37_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_37_commit_id_idx ON fis.diffs_37 USING btree (commit_id);


--
-- Name: diffs_37_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_37_fyle_id_idx ON fis.diffs_37 USING btree (fyle_id);


--
-- Name: diffs_37_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_37_id_idx ON fis.diffs_37 USING btree (id);


--
-- Name: diffs_38_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_38_code_set_id_idx ON fis.diffs_38 USING btree (code_set_id);


--
-- Name: diffs_38_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_38_commit_id_idx ON fis.diffs_38 USING btree (commit_id);


--
-- Name: diffs_38_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_38_fyle_id_idx ON fis.diffs_38 USING btree (fyle_id);


--
-- Name: diffs_38_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_38_id_idx ON fis.diffs_38 USING btree (id);


--
-- Name: diffs_39_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_39_code_set_id_idx ON fis.diffs_39 USING btree (code_set_id);


--
-- Name: diffs_39_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_39_commit_id_idx ON fis.diffs_39 USING btree (commit_id);


--
-- Name: diffs_39_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_39_fyle_id_idx ON fis.diffs_39 USING btree (fyle_id);


--
-- Name: diffs_39_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_39_id_idx ON fis.diffs_39 USING btree (id);


--
-- Name: diffs_3_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_3_code_set_id_idx ON fis.diffs_3 USING btree (code_set_id);


--
-- Name: diffs_3_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_3_commit_id_idx ON fis.diffs_3 USING btree (commit_id);


--
-- Name: diffs_3_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_3_fyle_id_idx ON fis.diffs_3 USING btree (fyle_id);


--
-- Name: diffs_3_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_3_id_idx ON fis.diffs_3 USING btree (id);


--
-- Name: diffs_40_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_40_code_set_id_idx ON fis.diffs_40 USING btree (code_set_id);


--
-- Name: diffs_40_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_40_commit_id_idx ON fis.diffs_40 USING btree (commit_id);


--
-- Name: diffs_40_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_40_fyle_id_idx ON fis.diffs_40 USING btree (fyle_id);


--
-- Name: diffs_40_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_40_id_idx ON fis.diffs_40 USING btree (id);


--
-- Name: diffs_41_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_41_code_set_id_idx ON fis.diffs_41 USING btree (code_set_id);


--
-- Name: diffs_41_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_41_commit_id_idx ON fis.diffs_41 USING btree (commit_id);


--
-- Name: diffs_41_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_41_fyle_id_idx ON fis.diffs_41 USING btree (fyle_id);


--
-- Name: diffs_41_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_41_id_idx ON fis.diffs_41 USING btree (id);


--
-- Name: diffs_42_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_42_code_set_id_idx ON fis.diffs_42 USING btree (code_set_id);


--
-- Name: diffs_42_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_42_commit_id_idx ON fis.diffs_42 USING btree (commit_id);


--
-- Name: diffs_42_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_42_fyle_id_idx ON fis.diffs_42 USING btree (fyle_id);


--
-- Name: diffs_42_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_42_id_idx ON fis.diffs_42 USING btree (id);


--
-- Name: diffs_43_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_43_code_set_id_idx ON fis.diffs_43 USING btree (code_set_id);


--
-- Name: diffs_43_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_43_commit_id_idx ON fis.diffs_43 USING btree (commit_id);


--
-- Name: diffs_43_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_43_fyle_id_idx ON fis.diffs_43 USING btree (fyle_id);


--
-- Name: diffs_43_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_43_id_idx ON fis.diffs_43 USING btree (id);


--
-- Name: diffs_44_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_44_code_set_id_idx ON fis.diffs_44 USING btree (code_set_id);


--
-- Name: diffs_44_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_44_commit_id_idx ON fis.diffs_44 USING btree (commit_id);


--
-- Name: diffs_44_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_44_fyle_id_idx ON fis.diffs_44 USING btree (fyle_id);


--
-- Name: diffs_44_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_44_id_idx ON fis.diffs_44 USING btree (id);


--
-- Name: diffs_45_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_45_code_set_id_idx ON fis.diffs_45 USING btree (code_set_id);


--
-- Name: diffs_45_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_45_commit_id_idx ON fis.diffs_45 USING btree (commit_id);


--
-- Name: diffs_45_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_45_fyle_id_idx ON fis.diffs_45 USING btree (fyle_id);


--
-- Name: diffs_45_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_45_id_idx ON fis.diffs_45 USING btree (id);


--
-- Name: diffs_46_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_46_code_set_id_idx ON fis.diffs_46 USING btree (code_set_id);


--
-- Name: diffs_46_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_46_commit_id_idx ON fis.diffs_46 USING btree (commit_id);


--
-- Name: diffs_46_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_46_fyle_id_idx ON fis.diffs_46 USING btree (fyle_id);


--
-- Name: diffs_46_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_46_id_idx ON fis.diffs_46 USING btree (id);


--
-- Name: diffs_47_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_47_code_set_id_idx ON fis.diffs_47 USING btree (code_set_id);


--
-- Name: diffs_47_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_47_commit_id_idx ON fis.diffs_47 USING btree (commit_id);


--
-- Name: diffs_47_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_47_fyle_id_idx ON fis.diffs_47 USING btree (fyle_id);


--
-- Name: diffs_47_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_47_id_idx ON fis.diffs_47 USING btree (id);


--
-- Name: diffs_48_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_48_code_set_id_idx ON fis.diffs_48 USING btree (code_set_id);


--
-- Name: diffs_48_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_48_commit_id_idx ON fis.diffs_48 USING btree (commit_id);


--
-- Name: diffs_48_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_48_fyle_id_idx ON fis.diffs_48 USING btree (fyle_id);


--
-- Name: diffs_48_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_48_id_idx ON fis.diffs_48 USING btree (id);


--
-- Name: diffs_49_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_49_code_set_id_idx ON fis.diffs_49 USING btree (code_set_id);


--
-- Name: diffs_49_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_49_commit_id_idx ON fis.diffs_49 USING btree (commit_id);


--
-- Name: diffs_49_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_49_fyle_id_idx ON fis.diffs_49 USING btree (fyle_id);


--
-- Name: diffs_49_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_49_id_idx ON fis.diffs_49 USING btree (id);


--
-- Name: diffs_4_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_4_code_set_id_idx ON fis.diffs_4 USING btree (code_set_id);


--
-- Name: diffs_4_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_4_commit_id_idx ON fis.diffs_4 USING btree (commit_id);


--
-- Name: diffs_4_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_4_fyle_id_idx ON fis.diffs_4 USING btree (fyle_id);


--
-- Name: diffs_4_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_4_id_idx ON fis.diffs_4 USING btree (id);


--
-- Name: diffs_50_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_50_code_set_id_idx ON fis.diffs_50 USING btree (code_set_id);


--
-- Name: diffs_50_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_50_commit_id_idx ON fis.diffs_50 USING btree (commit_id);


--
-- Name: diffs_50_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_50_fyle_id_idx ON fis.diffs_50 USING btree (fyle_id);


--
-- Name: diffs_50_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_50_id_idx ON fis.diffs_50 USING btree (id);


--
-- Name: diffs_51_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_51_code_set_id_idx ON fis.diffs_51 USING btree (code_set_id);


--
-- Name: diffs_51_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_51_commit_id_idx ON fis.diffs_51 USING btree (commit_id);


--
-- Name: diffs_51_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_51_fyle_id_idx ON fis.diffs_51 USING btree (fyle_id);


--
-- Name: diffs_51_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_51_id_idx ON fis.diffs_51 USING btree (id);


--
-- Name: diffs_52_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_52_code_set_id_idx ON fis.diffs_52 USING btree (code_set_id);


--
-- Name: diffs_52_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_52_commit_id_idx ON fis.diffs_52 USING btree (commit_id);


--
-- Name: diffs_52_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_52_fyle_id_idx ON fis.diffs_52 USING btree (fyle_id);


--
-- Name: diffs_52_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_52_id_idx ON fis.diffs_52 USING btree (id);


--
-- Name: diffs_53_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_53_code_set_id_idx ON fis.diffs_53 USING btree (code_set_id);


--
-- Name: diffs_53_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_53_commit_id_idx ON fis.diffs_53 USING btree (commit_id);


--
-- Name: diffs_53_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_53_fyle_id_idx ON fis.diffs_53 USING btree (fyle_id);


--
-- Name: diffs_53_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_53_id_idx ON fis.diffs_53 USING btree (id);


--
-- Name: diffs_54_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_54_code_set_id_idx ON fis.diffs_54 USING btree (code_set_id);


--
-- Name: diffs_54_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_54_commit_id_idx ON fis.diffs_54 USING btree (commit_id);


--
-- Name: diffs_54_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_54_fyle_id_idx ON fis.diffs_54 USING btree (fyle_id);


--
-- Name: diffs_54_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_54_id_idx ON fis.diffs_54 USING btree (id);


--
-- Name: diffs_55_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_55_code_set_id_idx ON fis.diffs_55 USING btree (code_set_id);


--
-- Name: diffs_55_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_55_commit_id_idx ON fis.diffs_55 USING btree (commit_id);


--
-- Name: diffs_55_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_55_fyle_id_idx ON fis.diffs_55 USING btree (fyle_id);


--
-- Name: diffs_55_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_55_id_idx ON fis.diffs_55 USING btree (id);


--
-- Name: diffs_56_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_56_code_set_id_idx ON fis.diffs_56 USING btree (code_set_id);


--
-- Name: diffs_56_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_56_commit_id_idx ON fis.diffs_56 USING btree (commit_id);


--
-- Name: diffs_56_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_56_fyle_id_idx ON fis.diffs_56 USING btree (fyle_id);


--
-- Name: diffs_56_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_56_id_idx ON fis.diffs_56 USING btree (id);


--
-- Name: diffs_57_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_57_code_set_id_idx ON fis.diffs_57 USING btree (code_set_id);


--
-- Name: diffs_57_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_57_commit_id_idx ON fis.diffs_57 USING btree (commit_id);


--
-- Name: diffs_57_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_57_fyle_id_idx ON fis.diffs_57 USING btree (fyle_id);


--
-- Name: diffs_57_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_57_id_idx ON fis.diffs_57 USING btree (id);


--
-- Name: diffs_58_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_58_code_set_id_idx ON fis.diffs_58 USING btree (code_set_id);


--
-- Name: diffs_58_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_58_commit_id_idx ON fis.diffs_58 USING btree (commit_id);


--
-- Name: diffs_58_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_58_fyle_id_idx ON fis.diffs_58 USING btree (fyle_id);


--
-- Name: diffs_58_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_58_id_idx ON fis.diffs_58 USING btree (id);


--
-- Name: diffs_59_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_59_code_set_id_idx ON fis.diffs_59 USING btree (code_set_id);


--
-- Name: diffs_59_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_59_commit_id_idx ON fis.diffs_59 USING btree (commit_id);


--
-- Name: diffs_59_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_59_fyle_id_idx ON fis.diffs_59 USING btree (fyle_id);


--
-- Name: diffs_59_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_59_id_idx ON fis.diffs_59 USING btree (id);


--
-- Name: diffs_5_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_5_code_set_id_idx ON fis.diffs_5 USING btree (code_set_id);


--
-- Name: diffs_5_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_5_commit_id_idx ON fis.diffs_5 USING btree (commit_id);


--
-- Name: diffs_5_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_5_fyle_id_idx ON fis.diffs_5 USING btree (fyle_id);


--
-- Name: diffs_5_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_5_id_idx ON fis.diffs_5 USING btree (id);


--
-- Name: diffs_60_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_60_code_set_id_idx ON fis.diffs_60 USING btree (code_set_id);


--
-- Name: diffs_60_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_60_commit_id_idx ON fis.diffs_60 USING btree (commit_id);


--
-- Name: diffs_60_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_60_fyle_id_idx ON fis.diffs_60 USING btree (fyle_id);


--
-- Name: diffs_60_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_60_id_idx ON fis.diffs_60 USING btree (id);


--
-- Name: diffs_61_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_61_code_set_id_idx ON fis.diffs_61 USING btree (code_set_id);


--
-- Name: diffs_61_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_61_commit_id_idx ON fis.diffs_61 USING btree (commit_id);


--
-- Name: diffs_61_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_61_fyle_id_idx ON fis.diffs_61 USING btree (fyle_id);


--
-- Name: diffs_61_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_61_id_idx ON fis.diffs_61 USING btree (id);


--
-- Name: diffs_62_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_62_code_set_id_idx ON fis.diffs_62 USING btree (code_set_id);


--
-- Name: diffs_62_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_62_commit_id_idx ON fis.diffs_62 USING btree (commit_id);


--
-- Name: diffs_62_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_62_fyle_id_idx ON fis.diffs_62 USING btree (fyle_id);


--
-- Name: diffs_62_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_62_id_idx ON fis.diffs_62 USING btree (id);


--
-- Name: diffs_63_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_63_code_set_id_idx ON fis.diffs_63 USING btree (code_set_id);


--
-- Name: diffs_63_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_63_commit_id_idx ON fis.diffs_63 USING btree (commit_id);


--
-- Name: diffs_63_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_63_fyle_id_idx ON fis.diffs_63 USING btree (fyle_id);


--
-- Name: diffs_63_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_63_id_idx ON fis.diffs_63 USING btree (id);


--
-- Name: diffs_64_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_64_code_set_id_idx ON fis.diffs_64 USING btree (code_set_id);


--
-- Name: diffs_64_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_64_commit_id_idx ON fis.diffs_64 USING btree (commit_id);


--
-- Name: diffs_64_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_64_fyle_id_idx ON fis.diffs_64 USING btree (fyle_id);


--
-- Name: diffs_64_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_64_id_idx ON fis.diffs_64 USING btree (id);


--
-- Name: diffs_65_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_65_code_set_id_idx ON fis.diffs_65 USING btree (code_set_id);


--
-- Name: diffs_65_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_65_commit_id_idx ON fis.diffs_65 USING btree (commit_id);


--
-- Name: diffs_65_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_65_fyle_id_idx ON fis.diffs_65 USING btree (fyle_id);


--
-- Name: diffs_65_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_65_id_idx ON fis.diffs_65 USING btree (id);


--
-- Name: diffs_66_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_66_code_set_id_idx ON fis.diffs_66 USING btree (code_set_id);


--
-- Name: diffs_66_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_66_commit_id_idx ON fis.diffs_66 USING btree (commit_id);


--
-- Name: diffs_66_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_66_fyle_id_idx ON fis.diffs_66 USING btree (fyle_id);


--
-- Name: diffs_66_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_66_id_idx ON fis.diffs_66 USING btree (id);


--
-- Name: diffs_67_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_67_code_set_id_idx ON fis.diffs_67 USING btree (code_set_id);


--
-- Name: diffs_67_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_67_commit_id_idx ON fis.diffs_67 USING btree (commit_id);


--
-- Name: diffs_67_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_67_fyle_id_idx ON fis.diffs_67 USING btree (fyle_id);


--
-- Name: diffs_67_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_67_id_idx ON fis.diffs_67 USING btree (id);


--
-- Name: diffs_68_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_68_code_set_id_idx ON fis.diffs_68 USING btree (code_set_id);


--
-- Name: diffs_68_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_68_commit_id_idx ON fis.diffs_68 USING btree (commit_id);


--
-- Name: diffs_68_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_68_fyle_id_idx ON fis.diffs_68 USING btree (fyle_id);


--
-- Name: diffs_68_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_68_id_idx ON fis.diffs_68 USING btree (id);


--
-- Name: diffs_69_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_69_code_set_id_idx ON fis.diffs_69 USING btree (code_set_id);


--
-- Name: diffs_69_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_69_commit_id_idx ON fis.diffs_69 USING btree (commit_id);


--
-- Name: diffs_69_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_69_fyle_id_idx ON fis.diffs_69 USING btree (fyle_id);


--
-- Name: diffs_69_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_69_id_idx ON fis.diffs_69 USING btree (id);


--
-- Name: diffs_6_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_6_code_set_id_idx ON fis.diffs_6 USING btree (code_set_id);


--
-- Name: diffs_6_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_6_commit_id_idx ON fis.diffs_6 USING btree (commit_id);


--
-- Name: diffs_6_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_6_fyle_id_idx ON fis.diffs_6 USING btree (fyle_id);


--
-- Name: diffs_6_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_6_id_idx ON fis.diffs_6 USING btree (id);


--
-- Name: diffs_70_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_70_code_set_id_idx ON fis.diffs_70 USING btree (code_set_id);


--
-- Name: diffs_70_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_70_commit_id_idx ON fis.diffs_70 USING btree (commit_id);


--
-- Name: diffs_70_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_70_fyle_id_idx ON fis.diffs_70 USING btree (fyle_id);


--
-- Name: diffs_70_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_70_id_idx ON fis.diffs_70 USING btree (id);


--
-- Name: diffs_71_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_71_code_set_id_idx ON fis.diffs_71 USING btree (code_set_id);


--
-- Name: diffs_71_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_71_commit_id_idx ON fis.diffs_71 USING btree (commit_id);


--
-- Name: diffs_71_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_71_fyle_id_idx ON fis.diffs_71 USING btree (fyle_id);


--
-- Name: diffs_71_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_71_id_idx ON fis.diffs_71 USING btree (id);


--
-- Name: diffs_72_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_72_code_set_id_idx ON fis.diffs_72 USING btree (code_set_id);


--
-- Name: diffs_72_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_72_commit_id_idx ON fis.diffs_72 USING btree (commit_id);


--
-- Name: diffs_72_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_72_fyle_id_idx ON fis.diffs_72 USING btree (fyle_id);


--
-- Name: diffs_72_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_72_id_idx ON fis.diffs_72 USING btree (id);


--
-- Name: diffs_73_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_73_code_set_id_idx ON fis.diffs_73 USING btree (code_set_id);


--
-- Name: diffs_73_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_73_commit_id_idx ON fis.diffs_73 USING btree (commit_id);


--
-- Name: diffs_73_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_73_fyle_id_idx ON fis.diffs_73 USING btree (fyle_id);


--
-- Name: diffs_73_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_73_id_idx ON fis.diffs_73 USING btree (id);


--
-- Name: diffs_74_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_74_code_set_id_idx ON fis.diffs_74 USING btree (code_set_id);


--
-- Name: diffs_74_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_74_commit_id_idx ON fis.diffs_74 USING btree (commit_id);


--
-- Name: diffs_74_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_74_fyle_id_idx ON fis.diffs_74 USING btree (fyle_id);


--
-- Name: diffs_74_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_74_id_idx ON fis.diffs_74 USING btree (id);


--
-- Name: diffs_75_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_75_code_set_id_idx ON fis.diffs_75 USING btree (code_set_id);


--
-- Name: diffs_75_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_75_commit_id_idx ON fis.diffs_75 USING btree (commit_id);


--
-- Name: diffs_75_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_75_fyle_id_idx ON fis.diffs_75 USING btree (fyle_id);


--
-- Name: diffs_75_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_75_id_idx ON fis.diffs_75 USING btree (id);


--
-- Name: diffs_76_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_76_code_set_id_idx ON fis.diffs_76 USING btree (code_set_id);


--
-- Name: diffs_76_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_76_commit_id_idx ON fis.diffs_76 USING btree (commit_id);


--
-- Name: diffs_76_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_76_fyle_id_idx ON fis.diffs_76 USING btree (fyle_id);


--
-- Name: diffs_76_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_76_id_idx ON fis.diffs_76 USING btree (id);


--
-- Name: diffs_77_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_77_code_set_id_idx ON fis.diffs_77 USING btree (code_set_id);


--
-- Name: diffs_77_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_77_commit_id_idx ON fis.diffs_77 USING btree (commit_id);


--
-- Name: diffs_77_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_77_fyle_id_idx ON fis.diffs_77 USING btree (fyle_id);


--
-- Name: diffs_77_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_77_id_idx ON fis.diffs_77 USING btree (id);


--
-- Name: diffs_78_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_78_code_set_id_idx ON fis.diffs_78 USING btree (code_set_id);


--
-- Name: diffs_78_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_78_commit_id_idx ON fis.diffs_78 USING btree (commit_id);


--
-- Name: diffs_78_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_78_fyle_id_idx ON fis.diffs_78 USING btree (fyle_id);


--
-- Name: diffs_78_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_78_id_idx ON fis.diffs_78 USING btree (id);


--
-- Name: diffs_79_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_79_code_set_id_idx ON fis.diffs_79 USING btree (code_set_id);


--
-- Name: diffs_79_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_79_commit_id_idx ON fis.diffs_79 USING btree (commit_id);


--
-- Name: diffs_79_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_79_fyle_id_idx ON fis.diffs_79 USING btree (fyle_id);


--
-- Name: diffs_79_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_79_id_idx ON fis.diffs_79 USING btree (id);


--
-- Name: diffs_7_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_7_code_set_id_idx ON fis.diffs_7 USING btree (code_set_id);


--
-- Name: diffs_7_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_7_commit_id_idx ON fis.diffs_7 USING btree (commit_id);


--
-- Name: diffs_7_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_7_fyle_id_idx ON fis.diffs_7 USING btree (fyle_id);


--
-- Name: diffs_7_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_7_id_idx ON fis.diffs_7 USING btree (id);


--
-- Name: diffs_80_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_80_code_set_id_idx ON fis.diffs_80 USING btree (code_set_id);


--
-- Name: diffs_80_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_80_commit_id_idx ON fis.diffs_80 USING btree (commit_id);


--
-- Name: diffs_80_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_80_fyle_id_idx ON fis.diffs_80 USING btree (fyle_id);


--
-- Name: diffs_80_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_80_id_idx ON fis.diffs_80 USING btree (id);


--
-- Name: diffs_81_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_81_code_set_id_idx ON fis.diffs_81 USING btree (code_set_id);


--
-- Name: diffs_81_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_81_commit_id_idx ON fis.diffs_81 USING btree (commit_id);


--
-- Name: diffs_81_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_81_fyle_id_idx ON fis.diffs_81 USING btree (fyle_id);


--
-- Name: diffs_81_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_81_id_idx ON fis.diffs_81 USING btree (id);


--
-- Name: diffs_82_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_82_code_set_id_idx ON fis.diffs_82 USING btree (code_set_id);


--
-- Name: diffs_82_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_82_commit_id_idx ON fis.diffs_82 USING btree (commit_id);


--
-- Name: diffs_82_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_82_fyle_id_idx ON fis.diffs_82 USING btree (fyle_id);


--
-- Name: diffs_82_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_82_id_idx ON fis.diffs_82 USING btree (id);


--
-- Name: diffs_83_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_83_code_set_id_idx ON fis.diffs_83 USING btree (code_set_id);


--
-- Name: diffs_83_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_83_commit_id_idx ON fis.diffs_83 USING btree (commit_id);


--
-- Name: diffs_83_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_83_fyle_id_idx ON fis.diffs_83 USING btree (fyle_id);


--
-- Name: diffs_83_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_83_id_idx ON fis.diffs_83 USING btree (id);


--
-- Name: diffs_84_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_84_code_set_id_idx ON fis.diffs_84 USING btree (code_set_id);


--
-- Name: diffs_84_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_84_commit_id_idx ON fis.diffs_84 USING btree (commit_id);


--
-- Name: diffs_84_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_84_fyle_id_idx ON fis.diffs_84 USING btree (fyle_id);


--
-- Name: diffs_84_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_84_id_idx ON fis.diffs_84 USING btree (id);


--
-- Name: diffs_85_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_85_code_set_id_idx ON fis.diffs_85 USING btree (code_set_id);


--
-- Name: diffs_85_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_85_commit_id_idx ON fis.diffs_85 USING btree (commit_id);


--
-- Name: diffs_85_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_85_fyle_id_idx ON fis.diffs_85 USING btree (fyle_id);


--
-- Name: diffs_85_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_85_id_idx ON fis.diffs_85 USING btree (id);


--
-- Name: diffs_86_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_86_code_set_id_idx ON fis.diffs_86 USING btree (code_set_id);


--
-- Name: diffs_86_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_86_commit_id_idx ON fis.diffs_86 USING btree (commit_id);


--
-- Name: diffs_86_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_86_fyle_id_idx ON fis.diffs_86 USING btree (fyle_id);


--
-- Name: diffs_86_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_86_id_idx ON fis.diffs_86 USING btree (id);


--
-- Name: diffs_87_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_87_code_set_id_idx ON fis.diffs_87 USING btree (code_set_id);


--
-- Name: diffs_87_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_87_commit_id_idx ON fis.diffs_87 USING btree (commit_id);


--
-- Name: diffs_87_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_87_fyle_id_idx ON fis.diffs_87 USING btree (fyle_id);


--
-- Name: diffs_87_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_87_id_idx ON fis.diffs_87 USING btree (id);


--
-- Name: diffs_88_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_88_code_set_id_idx ON fis.diffs_88 USING btree (code_set_id);


--
-- Name: diffs_88_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_88_commit_id_idx ON fis.diffs_88 USING btree (commit_id);


--
-- Name: diffs_88_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_88_fyle_id_idx ON fis.diffs_88 USING btree (fyle_id);


--
-- Name: diffs_88_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_88_id_idx ON fis.diffs_88 USING btree (id);


--
-- Name: diffs_89_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_89_code_set_id_idx ON fis.diffs_89 USING btree (code_set_id);


--
-- Name: diffs_89_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_89_commit_id_idx ON fis.diffs_89 USING btree (commit_id);


--
-- Name: diffs_89_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_89_fyle_id_idx ON fis.diffs_89 USING btree (fyle_id);


--
-- Name: diffs_89_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_89_id_idx ON fis.diffs_89 USING btree (id);


--
-- Name: diffs_8_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_8_code_set_id_idx ON fis.diffs_8 USING btree (code_set_id);


--
-- Name: diffs_8_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_8_commit_id_idx ON fis.diffs_8 USING btree (commit_id);


--
-- Name: diffs_8_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_8_fyle_id_idx ON fis.diffs_8 USING btree (fyle_id);


--
-- Name: diffs_8_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_8_id_idx ON fis.diffs_8 USING btree (id);


--
-- Name: diffs_90_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_90_code_set_id_idx ON fis.diffs_90 USING btree (code_set_id);


--
-- Name: diffs_90_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_90_commit_id_idx ON fis.diffs_90 USING btree (commit_id);


--
-- Name: diffs_90_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_90_fyle_id_idx ON fis.diffs_90 USING btree (fyle_id);


--
-- Name: diffs_90_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_90_id_idx ON fis.diffs_90 USING btree (id);


--
-- Name: diffs_91_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_91_code_set_id_idx ON fis.diffs_91 USING btree (code_set_id);


--
-- Name: diffs_91_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_91_commit_id_idx ON fis.diffs_91 USING btree (commit_id);


--
-- Name: diffs_91_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_91_fyle_id_idx ON fis.diffs_91 USING btree (fyle_id);


--
-- Name: diffs_91_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_91_id_idx ON fis.diffs_91 USING btree (id);


--
-- Name: diffs_92_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_92_code_set_id_idx ON fis.diffs_92 USING btree (code_set_id);


--
-- Name: diffs_92_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_92_commit_id_idx ON fis.diffs_92 USING btree (commit_id);


--
-- Name: diffs_92_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_92_fyle_id_idx ON fis.diffs_92 USING btree (fyle_id);


--
-- Name: diffs_92_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_92_id_idx ON fis.diffs_92 USING btree (id);


--
-- Name: diffs_93_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_93_code_set_id_idx ON fis.diffs_93 USING btree (code_set_id);


--
-- Name: diffs_93_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_93_commit_id_idx ON fis.diffs_93 USING btree (commit_id);


--
-- Name: diffs_93_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_93_fyle_id_idx ON fis.diffs_93 USING btree (fyle_id);


--
-- Name: diffs_93_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_93_id_idx ON fis.diffs_93 USING btree (id);


--
-- Name: diffs_94_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_94_code_set_id_idx ON fis.diffs_94 USING btree (code_set_id);


--
-- Name: diffs_94_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_94_commit_id_idx ON fis.diffs_94 USING btree (commit_id);


--
-- Name: diffs_94_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_94_fyle_id_idx ON fis.diffs_94 USING btree (fyle_id);


--
-- Name: diffs_94_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_94_id_idx ON fis.diffs_94 USING btree (id);


--
-- Name: diffs_95_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_95_code_set_id_idx ON fis.diffs_95 USING btree (code_set_id);


--
-- Name: diffs_95_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_95_commit_id_idx ON fis.diffs_95 USING btree (commit_id);


--
-- Name: diffs_95_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_95_fyle_id_idx ON fis.diffs_95 USING btree (fyle_id);


--
-- Name: diffs_95_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_95_id_idx ON fis.diffs_95 USING btree (id);


--
-- Name: diffs_96_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_96_code_set_id_idx ON fis.diffs_96 USING btree (code_set_id);


--
-- Name: diffs_96_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_96_commit_id_idx ON fis.diffs_96 USING btree (commit_id);


--
-- Name: diffs_96_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_96_fyle_id_idx ON fis.diffs_96 USING btree (fyle_id);


--
-- Name: diffs_96_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_96_id_idx ON fis.diffs_96 USING btree (id);


--
-- Name: diffs_97_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_97_code_set_id_idx ON fis.diffs_97 USING btree (code_set_id);


--
-- Name: diffs_97_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_97_commit_id_idx ON fis.diffs_97 USING btree (commit_id);


--
-- Name: diffs_97_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_97_fyle_id_idx ON fis.diffs_97 USING btree (fyle_id);


--
-- Name: diffs_97_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_97_id_idx ON fis.diffs_97 USING btree (id);


--
-- Name: diffs_98_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_98_code_set_id_idx ON fis.diffs_98 USING btree (code_set_id);


--
-- Name: diffs_98_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_98_commit_id_idx ON fis.diffs_98 USING btree (commit_id);


--
-- Name: diffs_98_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_98_fyle_id_idx ON fis.diffs_98 USING btree (fyle_id);


--
-- Name: diffs_98_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_98_id_idx ON fis.diffs_98 USING btree (id);


--
-- Name: diffs_99_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_99_code_set_id_idx ON fis.diffs_99 USING btree (code_set_id);


--
-- Name: diffs_99_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_99_commit_id_idx ON fis.diffs_99 USING btree (commit_id);


--
-- Name: diffs_99_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_99_fyle_id_idx ON fis.diffs_99 USING btree (fyle_id);


--
-- Name: diffs_99_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_99_id_idx ON fis.diffs_99 USING btree (id);


--
-- Name: diffs_9_code_set_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_9_code_set_id_idx ON fis.diffs_9 USING btree (code_set_id);


--
-- Name: diffs_9_commit_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_9_commit_id_idx ON fis.diffs_9 USING btree (commit_id);


--
-- Name: diffs_9_fyle_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_9_fyle_id_idx ON fis.diffs_9 USING btree (fyle_id);


--
-- Name: diffs_9_id_idx; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX diffs_9_id_idx ON fis.diffs_9 USING btree (id);


--
-- Name: index_admin_dashboard_stats_on_data; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_admin_dashboard_stats_on_data ON fis.admin_dashboard_stats USING gin (data);


--
-- Name: index_admin_dashboard_stats_on_stat_type; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_admin_dashboard_stats_on_stat_type ON fis.admin_dashboard_stats USING btree (stat_type);


--
-- Name: index_analysis_aliases_on_analysis_id_preferred_name_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_analysis_aliases_on_analysis_id_preferred_name_id ON fis.analysis_aliases USING btree (analysis_id, preferred_name_id);


--
-- Name: index_analysis_sloc_sets_on_analysis_id_sloc_set_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_analysis_sloc_sets_on_analysis_id_sloc_set_id ON fis.analysis_sloc_sets USING btree (analysis_id, sloc_set_id);


--
-- Name: index_analysis_sloc_sets_on_sloc_set_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_analysis_sloc_sets_on_sloc_set_id ON fis.analysis_sloc_sets USING btree (sloc_set_id);


--
-- Name: index_code_location_dnfs_on_code_location_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_code_location_dnfs_on_code_location_id ON fis.code_location_dnfs USING btree (code_location_id);


--
-- Name: index_code_location_dnfs_on_job_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_code_location_dnfs_on_job_id ON fis.code_location_dnfs USING btree (job_id);


--
-- Name: index_code_location_tarballs_on_code_location_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_code_location_tarballs_on_code_location_id ON fis.code_location_tarballs USING btree (code_location_id);


--
-- Name: index_code_location_tarballs_on_reference; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_code_location_tarballs_on_reference ON fis.code_location_tarballs USING btree (reference);


--
-- Name: index_code_locations_last_job_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE UNIQUE INDEX index_code_locations_last_job_id ON fis.code_locations USING btree (last_job_id);


--
-- Name: index_code_locations_on_best_code_set_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_code_locations_on_best_code_set_id ON fis.code_locations USING btree (best_code_set_id);


--
-- Name: index_code_locations_on_repository_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_code_locations_on_repository_id ON fis.code_locations USING btree (repository_id);


--
-- Name: index_code_sets_on_best_sloc_set_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_code_sets_on_best_sloc_set_id ON fis.code_sets USING btree (best_sloc_set_id);


--
-- Name: index_code_sets_on_code_location_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_code_sets_on_code_location_id ON fis.code_sets USING btree (code_location_id);


--
-- Name: index_commit_flags_on_sloc_set_id_commit_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_commit_flags_on_sloc_set_id_commit_id ON fis.commit_flags USING btree (sloc_set_id, commit_id);


--
-- Name: index_commit_flags_on_sloc_set_id_time; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_commit_flags_on_sloc_set_id_time ON fis.commit_flags USING btree (sloc_set_id, "time" DESC);


--
-- Name: index_commits_on_code_set_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_commits_on_code_set_id ON fis.commits USING btree (code_set_id);


--
-- Name: index_commits_on_code_set_id_time; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_commits_on_code_set_id_time ON fis.commits USING btree (code_set_id, "time");


--
-- Name: index_commits_on_name_id_month; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_commits_on_name_id_month ON fis.commits USING btree (name_id, date_trunc('month'::text, "time"));


--
-- Name: index_commits_on_sha1; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_commits_on_sha1 ON fis.commits USING btree (sha1);


--
-- Name: index_diffs_orig_on_commit_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_diffs_orig_on_commit_id ON fis.diffs_orig USING btree (commit_id);


--
-- Name: index_diffs_orig_on_fyle_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_diffs_orig_on_fyle_id ON fis.diffs_orig USING btree (fyle_id);


--
-- Name: index_fisbot_events_on_code_location_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_fisbot_events_on_code_location_id ON fis.fisbot_events USING btree (code_location_id);


--
-- Name: index_fyles_on_code_set_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_fyles_on_code_set_id ON fis.fyles USING btree (code_set_id);


--
-- Name: index_fyles_on_name; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_fyles_on_name ON fis.fyles USING btree (name);


--
-- Name: index_jobs_on_account_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_jobs_on_account_id ON fis.jobs USING btree (account_id);


--
-- Name: index_jobs_on_code_location_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_jobs_on_code_location_id ON fis.jobs USING btree (code_location_id);


--
-- Name: index_jobs_on_code_set_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_jobs_on_code_set_id ON fis.jobs USING btree (code_set_id);


--
-- Name: index_jobs_on_priority; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_jobs_on_priority ON fis.jobs USING btree (priority);


--
-- Name: index_jobs_on_project_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_jobs_on_project_id ON fis.jobs USING btree (project_id);


--
-- Name: index_jobs_on_sloc_set_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_jobs_on_sloc_set_id ON fis.jobs USING btree (sloc_set_id);


--
-- Name: index_jobs_on_status_type_wait_until; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_jobs_on_status_type_wait_until ON fis.jobs USING btree (status, type, COALESCE(wait_until, '1980-01-01 00:00:00'::timestamp without time zone));


--
-- Name: index_on_commits_code_set_id_position; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_on_commits_code_set_id_position ON fis.commits USING btree (code_set_id, "position");


--
-- Name: index_repositories_on_url; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_repositories_on_url ON fis.repositories USING btree (url);


--
-- Name: index_repository_directories_on_code_location_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_repository_directories_on_code_location_id ON fis.repository_directories USING btree (code_location_id);


--
-- Name: index_repository_directories_on_repository_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_repository_directories_on_repository_id ON fis.repository_directories USING btree (repository_id);


--
-- Name: index_repository_tags_on_repository_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_repository_tags_on_repository_id ON fis.repository_tags USING btree (repository_id);


--
-- Name: index_slave_logs_on_code_sets_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_slave_logs_on_code_sets_id ON fis.slave_logs USING btree (code_set_id);


--
-- Name: index_slave_logs_on_created_on; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_slave_logs_on_created_on ON fis.slave_logs USING btree (created_on);


--
-- Name: index_slave_logs_on_job_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_slave_logs_on_job_id ON fis.slave_logs USING btree (job_id);


--
-- Name: index_slave_logs_on_slave_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_slave_logs_on_slave_id ON fis.slave_logs USING btree (slave_id);


--
-- Name: index_sloc_metrics_on_diff_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_sloc_metrics_on_diff_id ON fis.sloc_metrics USING btree (diff_id);


--
-- Name: index_sloc_metrics_on_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_sloc_metrics_on_id ON fis.sloc_metrics USING btree (id);


--
-- Name: index_sloc_metrics_on_sloc_set_id_language_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_sloc_metrics_on_sloc_set_id_language_id ON fis.sloc_metrics USING btree (sloc_set_id, language_id);


--
-- Name: index_sloc_sets_on_code_set_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_sloc_sets_on_code_set_id ON fis.sloc_sets USING btree (code_set_id);


--
-- Name: index_subscriptions_client_relation_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_subscriptions_client_relation_id ON fis.subscriptions USING btree (code_location_id, registration_key_id, client_relation_id) WHERE (client_relation_id IS NOT NULL);


--
-- Name: index_subscriptions_null_client_relation_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_subscriptions_null_client_relation_id ON fis.subscriptions USING btree (code_location_id, registration_key_id) WHERE (client_relation_id IS NULL);


--
-- Name: index_subscriptions_on_code_location_id; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_subscriptions_on_code_location_id ON fis.subscriptions USING btree (code_location_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: fis; Owner: -
--

CREATE INDEX index_users_on_email ON fis.users USING btree (email);


--
-- Name: edits_organization_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX edits_organization_id ON oh.edits USING btree (organization_id) WHERE (organization_id IS NOT NULL);


--
-- Name: edits_project_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX edits_project_id ON oh.edits USING btree (project_id) WHERE (project_id IS NOT NULL);


--
-- Name: index_account_reports_on_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_account_reports_on_account_id ON oh.account_reports USING btree (account_id);


--
-- Name: index_accounts_on_best_vita_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_accounts_on_best_vita_id ON oh.accounts USING btree (best_vita_id) WHERE (best_vita_id IS NOT NULL);


--
-- Name: index_accounts_on_email_md5; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_accounts_on_email_md5 ON oh.accounts USING btree (email_md5);


--
-- Name: index_accounts_on_lower_login; Type: INDEX; Schema: oh; Owner: -
--

CREATE UNIQUE INDEX index_accounts_on_lower_login ON oh.accounts USING btree (lower(login));


--
-- Name: index_accounts_on_organization_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_accounts_on_organization_id ON oh.accounts USING btree (organization_id);


--
-- Name: index_accounts_on_remember_token; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_accounts_on_remember_token ON oh.accounts USING btree (remember_token);


--
-- Name: index_actions_on_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_actions_on_account_id ON oh.actions USING btree (account_id);


--
-- Name: index_activity_facts_on_analysis_id_month; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_activity_facts_on_analysis_id_month ON oh.activity_facts USING btree (analysis_id, month);


--
-- Name: index_activity_facts_on_language_id_month; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_activity_facts_on_language_id_month ON oh.activity_facts USING btree (language_id, month);


--
-- Name: index_activity_facts_on_name_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_activity_facts_on_name_id ON oh.activity_facts USING btree (name_id);


--
-- Name: index_analyses_on_logged_at_day; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_analyses_on_logged_at_day ON oh.analyses USING btree (oldest_code_set_time, date_trunc('day'::text, oldest_code_set_time)) WHERE (oldest_code_set_time IS NOT NULL);


--
-- Name: index_analyses_on_project_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_analyses_on_project_id ON oh.analyses USING btree (project_id);


--
-- Name: index_analysis_summaries_on_analysis_id_type; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_analysis_summaries_on_analysis_id_type ON oh.analysis_summaries USING btree (analysis_id, type);


--
-- Name: index_api_keys_on_oauth_application_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_api_keys_on_oauth_application_id ON oh.api_keys USING btree (oauth_application_id);


--
-- Name: index_authorizations_on_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_authorizations_on_account_id ON oh.authorizations USING btree (account_id);


--
-- Name: index_authorizations_on_api_key_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_authorizations_on_api_key_id ON oh.authorizations USING btree (api_key_id);


--
-- Name: index_claims_on_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_claims_on_account_id ON oh.positions USING btree (account_id);


--
-- Name: index_duplicates_on_bad_project_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_duplicates_on_bad_project_id ON oh.duplicates USING btree (bad_project_id);


--
-- Name: index_duplicates_on_created_at; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_duplicates_on_created_at ON oh.duplicates USING btree (created_at);


--
-- Name: index_duplicates_on_good_project_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_duplicates_on_good_project_id ON oh.duplicates USING btree (good_project_id);


--
-- Name: index_edits_on_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_edits_on_account_id ON oh.edits USING btree (account_id);


--
-- Name: index_edits_on_created_at; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_edits_on_created_at ON oh.edits USING btree (created_at);


--
-- Name: index_edits_on_edits; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_edits_on_edits ON oh.edits USING btree (target_type, target_id, key);


--
-- Name: index_enlistments_on_code_location_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_enlistments_on_code_location_id ON oh.enlistments USING btree (code_location_id);


--
-- Name: index_enlistments_on_project_id_and_code_location_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE UNIQUE INDEX index_enlistments_on_project_id_and_code_location_id ON oh.enlistments USING btree (project_id, code_location_id);


--
-- Name: index_factoids_on_analysis_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_factoids_on_analysis_id ON oh.factoids USING btree (analysis_id);


--
-- Name: index_follows_on_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_follows_on_account_id ON oh.follows USING btree (account_id);


--
-- Name: index_helpfuls_on_review_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_helpfuls_on_review_id ON oh.helpfuls USING btree (review_id);


--
-- Name: index_kudo_scores_on_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_kudo_scores_on_account_id ON oh.kudo_scores USING btree (account_id);


--
-- Name: index_kudo_scores_on_array_index; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_kudo_scores_on_array_index ON oh.kudo_scores USING btree (array_index);


--
-- Name: index_kudo_scores_on_project_id_name_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_kudo_scores_on_project_id_name_id ON oh.kudo_scores USING btree (project_id, name_id);


--
-- Name: index_kudos_on_from_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_kudos_on_from_account_id ON oh.kudos USING btree (sender_id);


--
-- Name: index_language_facts_on_month_language_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_language_facts_on_month_language_id ON oh.language_facts USING btree (month, language_id);


--
-- Name: index_license_facts_on_analysis_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_license_facts_on_analysis_id ON oh.license_facts USING btree (analysis_id);


--
-- Name: index_licenses_on_vanity_url; Type: INDEX; Schema: oh; Owner: -
--

CREATE UNIQUE INDEX index_licenses_on_vanity_url ON oh.licenses USING btree (vanity_url);


--
-- Name: index_links_project_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_links_project_id ON oh.links USING btree (project_id);


--
-- Name: index_manages_on_target_account_deleted_by; Type: INDEX; Schema: oh; Owner: -
--

CREATE UNIQUE INDEX index_manages_on_target_account_deleted_by ON oh.manages USING btree (target_id, target_type, account_id) WHERE ((deleted_at IS NULL) AND (deleted_by IS NULL));


--
-- Name: index_message_account_tags_on_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_message_account_tags_on_account_id ON oh.message_account_tags USING btree (account_id);


--
-- Name: index_message_account_tags_on_message_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_message_account_tags_on_message_id ON oh.message_account_tags USING btree (message_id);


--
-- Name: index_messages_on_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_messages_on_account_id ON oh.messages USING btree (account_id);


--
-- Name: index_monthly_commit_histories_on_analysis_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_monthly_commit_histories_on_analysis_id ON oh.monthly_commit_histories USING btree (analysis_id);


--
-- Name: index_name_facts_email_address_ids; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_name_facts_email_address_ids ON oh.name_facts USING gin (email_address_ids) WHERE (type = 'ContributorFact'::text);


--
-- Name: index_name_facts_on_analysis_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_name_facts_on_analysis_id ON oh.name_facts USING btree (analysis_id);


--
-- Name: index_name_facts_on_analysis_id_and_name_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_name_facts_on_analysis_id_and_name_id ON oh.name_facts USING btree (analysis_id, name_id);


--
-- Name: index_name_facts_on_analysis_id_contributors; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_name_facts_on_analysis_id_contributors ON oh.name_facts USING btree (analysis_id) WHERE (type = 'ContributorFact'::text);


--
-- Name: index_name_facts_on_vita_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_name_facts_on_vita_id ON oh.name_facts USING btree (vita_id);


--
-- Name: index_name_language_facts_analysis_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_name_language_facts_analysis_id ON oh.name_language_facts USING btree (analysis_id);


--
-- Name: index_name_language_facts_name_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_name_language_facts_name_id ON oh.name_language_facts USING btree (name_id);


--
-- Name: index_name_language_facts_on_language_id_total_months; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_name_language_facts_on_language_id_total_months ON oh.name_language_facts USING btree (language_id, total_months DESC) WHERE (vita_id IS NOT NULL);


--
-- Name: index_name_language_facts_on_vita_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_name_language_facts_on_vita_id ON oh.name_language_facts USING btree (vita_id);


--
-- Name: index_names_on_name; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_names_on_name ON oh.names USING btree (name);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oh.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: oh; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oh.oauth_applications USING btree (uid);


--
-- Name: index_organizations_on_lower_url_name; Type: INDEX; Schema: oh; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_lower_url_name ON oh.organizations USING btree (lower(vanity_url));


--
-- Name: index_organizations_on_name; Type: INDEX; Schema: oh; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_name ON oh.organizations USING btree (lower(name));


--
-- Name: index_organizations_on_vector; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_organizations_on_vector ON oh.organizations USING gin (vector);


--
-- Name: index_people_gin; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_people_gin ON oh.people USING gin (vector);


--
-- Name: index_people_name_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_people_name_id ON oh.people USING btree (name_id) WHERE (name_id IS NOT NULL);


--
-- Name: index_people_on_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_people_on_account_id ON oh.people USING btree (account_id);


--
-- Name: index_people_on_project_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_people_on_project_id ON oh.people USING btree (project_id);


--
-- Name: index_people_on_vector_gin; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_people_on_vector_gin ON oh.people USING gin (vector);


--
-- Name: index_permissions_on_target; Type: INDEX; Schema: oh; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_target ON oh.permissions USING btree (target_id, target_type);


--
-- Name: index_positions_on_organization_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_positions_on_organization_id ON oh.positions USING btree (organization_id);


--
-- Name: index_posts_on_vector; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_posts_on_vector ON oh.posts USING gist (vector);


--
-- Name: index_profiles_on_job_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_profiles_on_job_id ON oh.profiles USING btree (job_id);


--
-- Name: index_project_badges_on_enlistment_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_project_badges_on_enlistment_id ON oh.project_badges USING btree (enlistment_id);


--
-- Name: index_project_experiences_on_position_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_project_experiences_on_position_id ON oh.project_experiences USING btree (position_id);


--
-- Name: index_project_licenses_project_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_project_licenses_project_id ON oh.project_licenses USING btree (project_id);


--
-- Name: index_project_security_sets_on_project_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_project_security_sets_on_project_id ON oh.project_security_sets USING btree (project_id);


--
-- Name: index_project_vulnerability_reports_on_project_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_project_vulnerability_reports_on_project_id ON oh.project_vulnerability_reports USING btree (project_id);


--
-- Name: index_projects_deleted; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_projects_deleted ON oh.projects USING btree (deleted, id);


--
-- Name: index_projects_on_best_analysis_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_projects_on_best_analysis_id ON oh.projects USING btree (best_analysis_id);


--
-- Name: index_projects_on_best_project_security_set_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_projects_on_best_project_security_set_id ON oh.projects USING btree (best_project_security_set_id);


--
-- Name: index_projects_on_lower_url_name; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_projects_on_lower_url_name ON oh.projects USING btree (lower(vanity_url));


--
-- Name: index_projects_on_name; Type: INDEX; Schema: oh; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_name ON oh.projects USING btree (lower(name));


--
-- Name: index_projects_on_organization_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_projects_on_organization_id ON oh.projects USING btree (organization_id);


--
-- Name: index_projects_on_user_count; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_projects_on_user_count ON oh.projects USING btree (user_count DESC) WHERE (NOT deleted);


--
-- Name: index_projects_on_vector_gin; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_projects_on_vector_gin ON oh.projects USING gin (vector);


--
-- Name: index_ratings_on_project_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_ratings_on_project_id ON oh.ratings USING btree (project_id);


--
-- Name: index_recommend_entries_on_project_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_recommend_entries_on_project_id ON oh.recommend_entries USING btree (project_id);


--
-- Name: index_releases_on_project_security_set_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_releases_on_project_security_set_id ON oh.releases USING btree (project_security_set_id);


--
-- Name: index_releases_on_released_on; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_releases_on_released_on ON oh.releases USING btree (released_on);


--
-- Name: index_releases_vulnerabilities_on_release_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_releases_vulnerabilities_on_release_id ON oh.releases_vulnerabilities USING btree (release_id);


--
-- Name: index_releases_vulnerabilities_on_vulnerability_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_releases_vulnerabilities_on_vulnerability_id ON oh.releases_vulnerabilities USING btree (vulnerability_id);


--
-- Name: index_reviewed_non_spammers_on_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_reviewed_non_spammers_on_account_id ON oh.reviewed_non_spammers USING btree (account_id);


--
-- Name: index_reviews_on_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_reviews_on_account_id ON oh.reviews USING btree (account_id);


--
-- Name: index_reviews_on_project_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_reviews_on_project_id ON oh.reviews USING btree (project_id);


--
-- Name: index_rss_articles_rss_feed_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_rss_articles_rss_feed_id ON oh.rss_articles USING btree (rss_feed_id);


--
-- Name: index_rss_articles_time; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_rss_articles_time ON oh.rss_articles USING btree ("time");


--
-- Name: index_rss_subscriptions_project_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_rss_subscriptions_project_id ON oh.rss_subscriptions USING btree (project_id);


--
-- Name: index_scan_analytics_on_data; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_scan_analytics_on_data ON oh.scan_analytics USING gin (data);


--
-- Name: index_settings_on_key; Type: INDEX; Schema: oh; Owner: -
--

CREATE UNIQUE INDEX index_settings_on_key ON oh.settings USING btree (key);


--
-- Name: index_stack_entries_on_project_stack_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE UNIQUE INDEX index_stack_entries_on_project_stack_id ON oh.stack_entries USING btree (project_id, stack_id) WHERE (deleted_at IS NULL);


--
-- Name: index_stacks_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_stacks_account_id ON oh.stacks USING btree (account_id);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_taggings_on_tag_id ON oh.taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_taggings_on_taggable_id ON oh.taggings USING btree (taggable_id);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_tags_on_name ON oh.tags USING btree (name);


--
-- Name: index_thirty_day_summaries_on_analysis_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_thirty_day_summaries_on_analysis_id ON oh.thirty_day_summaries USING btree (analysis_id);


--
-- Name: index_vita_analyses_on_analysis_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_vita_analyses_on_analysis_id ON oh.vita_analyses USING btree (analysis_id);


--
-- Name: index_vita_analyses_on_vita_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_vita_analyses_on_vita_id ON oh.vita_analyses USING btree (vita_id);


--
-- Name: index_vitae_on_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX index_vitae_on_account_id ON oh.vitae USING btree (account_id);


--
-- Name: pdp_spammer_ids_pkey; Type: INDEX; Schema: oh; Owner: -
--

CREATE UNIQUE INDEX pdp_spammer_ids_pkey ON oh.pdp_spammer_ids USING btree (account_id);


--
-- Name: people_on_name_fact_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX people_on_name_fact_id ON oh.people USING btree (name_fact_id);


--
-- Name: posts_account_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX posts_account_id ON oh.posts USING btree (account_id);


--
-- Name: posts_topic_ic; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX posts_topic_ic ON oh.posts USING btree (topic_id);


--
-- Name: releases_vulnerabilities_release_id_vulnerability_id_idx; Type: INDEX; Schema: oh; Owner: -
--

CREATE UNIQUE INDEX releases_vulnerabilities_release_id_vulnerability_id_idx ON oh.releases_vulnerabilities USING btree (release_id, vulnerability_id);


--
-- Name: robin; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX robin ON oh.name_facts USING btree (last_checkin) WHERE (type = 'VitaFact'::text);


--
-- Name: stack_entry_project_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX stack_entry_project_id ON oh.stack_entries USING btree (project_id);


--
-- Name: stack_entry_stack_id; Type: INDEX; Schema: oh; Owner: -
--

CREATE INDEX stack_entry_stack_id ON oh.stack_entries USING btree (stack_id);


--
-- Name: unique_stacks_titles_per_account; Type: INDEX; Schema: oh; Owner: -
--

CREATE UNIQUE INDEX unique_stacks_titles_per_account ON oh.stacks USING btree (account_id, title);


--
-- Name: diffs_0_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_0_code_set_id_idx;


--
-- Name: diffs_0_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_0_commit_id_idx;


--
-- Name: diffs_0_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_0_fyle_id_idx;


--
-- Name: diffs_0_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_0_id_idx;


--
-- Name: diffs_10_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_10_code_set_id_idx;


--
-- Name: diffs_10_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_10_commit_id_idx;


--
-- Name: diffs_10_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_10_fyle_id_idx;


--
-- Name: diffs_10_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_10_id_idx;


--
-- Name: diffs_11_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_11_code_set_id_idx;


--
-- Name: diffs_11_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_11_commit_id_idx;


--
-- Name: diffs_11_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_11_fyle_id_idx;


--
-- Name: diffs_11_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_11_id_idx;


--
-- Name: diffs_12_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_12_code_set_id_idx;


--
-- Name: diffs_12_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_12_commit_id_idx;


--
-- Name: diffs_12_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_12_fyle_id_idx;


--
-- Name: diffs_12_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_12_id_idx;


--
-- Name: diffs_13_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_13_code_set_id_idx;


--
-- Name: diffs_13_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_13_commit_id_idx;


--
-- Name: diffs_13_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_13_fyle_id_idx;


--
-- Name: diffs_13_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_13_id_idx;


--
-- Name: diffs_14_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_14_code_set_id_idx;


--
-- Name: diffs_14_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_14_commit_id_idx;


--
-- Name: diffs_14_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_14_fyle_id_idx;


--
-- Name: diffs_14_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_14_id_idx;


--
-- Name: diffs_15_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_15_code_set_id_idx;


--
-- Name: diffs_15_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_15_commit_id_idx;


--
-- Name: diffs_15_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_15_fyle_id_idx;


--
-- Name: diffs_15_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_15_id_idx;


--
-- Name: diffs_16_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_16_code_set_id_idx;


--
-- Name: diffs_16_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_16_commit_id_idx;


--
-- Name: diffs_16_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_16_fyle_id_idx;


--
-- Name: diffs_16_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_16_id_idx;


--
-- Name: diffs_17_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_17_code_set_id_idx;


--
-- Name: diffs_17_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_17_commit_id_idx;


--
-- Name: diffs_17_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_17_fyle_id_idx;


--
-- Name: diffs_17_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_17_id_idx;


--
-- Name: diffs_18_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_18_code_set_id_idx;


--
-- Name: diffs_18_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_18_commit_id_idx;


--
-- Name: diffs_18_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_18_fyle_id_idx;


--
-- Name: diffs_18_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_18_id_idx;


--
-- Name: diffs_19_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_19_code_set_id_idx;


--
-- Name: diffs_19_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_19_commit_id_idx;


--
-- Name: diffs_19_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_19_fyle_id_idx;


--
-- Name: diffs_19_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_19_id_idx;


--
-- Name: diffs_1_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_1_code_set_id_idx;


--
-- Name: diffs_1_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_1_commit_id_idx;


--
-- Name: diffs_1_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_1_fyle_id_idx;


--
-- Name: diffs_1_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_1_id_idx;


--
-- Name: diffs_20_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_20_code_set_id_idx;


--
-- Name: diffs_20_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_20_commit_id_idx;


--
-- Name: diffs_20_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_20_fyle_id_idx;


--
-- Name: diffs_20_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_20_id_idx;


--
-- Name: diffs_21_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_21_code_set_id_idx;


--
-- Name: diffs_21_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_21_commit_id_idx;


--
-- Name: diffs_21_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_21_fyle_id_idx;


--
-- Name: diffs_21_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_21_id_idx;


--
-- Name: diffs_22_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_22_code_set_id_idx;


--
-- Name: diffs_22_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_22_commit_id_idx;


--
-- Name: diffs_22_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_22_fyle_id_idx;


--
-- Name: diffs_22_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_22_id_idx;


--
-- Name: diffs_23_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_23_code_set_id_idx;


--
-- Name: diffs_23_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_23_commit_id_idx;


--
-- Name: diffs_23_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_23_fyle_id_idx;


--
-- Name: diffs_23_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_23_id_idx;


--
-- Name: diffs_24_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_24_code_set_id_idx;


--
-- Name: diffs_24_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_24_commit_id_idx;


--
-- Name: diffs_24_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_24_fyle_id_idx;


--
-- Name: diffs_24_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_24_id_idx;


--
-- Name: diffs_25_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_25_code_set_id_idx;


--
-- Name: diffs_25_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_25_commit_id_idx;


--
-- Name: diffs_25_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_25_fyle_id_idx;


--
-- Name: diffs_25_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_25_id_idx;


--
-- Name: diffs_26_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_26_code_set_id_idx;


--
-- Name: diffs_26_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_26_commit_id_idx;


--
-- Name: diffs_26_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_26_fyle_id_idx;


--
-- Name: diffs_26_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_26_id_idx;


--
-- Name: diffs_27_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_27_code_set_id_idx;


--
-- Name: diffs_27_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_27_commit_id_idx;


--
-- Name: diffs_27_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_27_fyle_id_idx;


--
-- Name: diffs_27_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_27_id_idx;


--
-- Name: diffs_28_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_28_code_set_id_idx;


--
-- Name: diffs_28_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_28_commit_id_idx;


--
-- Name: diffs_28_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_28_fyle_id_idx;


--
-- Name: diffs_28_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_28_id_idx;


--
-- Name: diffs_29_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_29_code_set_id_idx;


--
-- Name: diffs_29_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_29_commit_id_idx;


--
-- Name: diffs_29_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_29_fyle_id_idx;


--
-- Name: diffs_29_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_29_id_idx;


--
-- Name: diffs_2_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_2_code_set_id_idx;


--
-- Name: diffs_2_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_2_commit_id_idx;


--
-- Name: diffs_2_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_2_fyle_id_idx;


--
-- Name: diffs_2_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_2_id_idx;


--
-- Name: diffs_30_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_30_code_set_id_idx;


--
-- Name: diffs_30_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_30_commit_id_idx;


--
-- Name: diffs_30_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_30_fyle_id_idx;


--
-- Name: diffs_30_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_30_id_idx;


--
-- Name: diffs_31_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_31_code_set_id_idx;


--
-- Name: diffs_31_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_31_commit_id_idx;


--
-- Name: diffs_31_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_31_fyle_id_idx;


--
-- Name: diffs_31_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_31_id_idx;


--
-- Name: diffs_32_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_32_code_set_id_idx;


--
-- Name: diffs_32_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_32_commit_id_idx;


--
-- Name: diffs_32_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_32_fyle_id_idx;


--
-- Name: diffs_32_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_32_id_idx;


--
-- Name: diffs_33_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_33_code_set_id_idx;


--
-- Name: diffs_33_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_33_commit_id_idx;


--
-- Name: diffs_33_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_33_fyle_id_idx;


--
-- Name: diffs_33_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_33_id_idx;


--
-- Name: diffs_34_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_34_code_set_id_idx;


--
-- Name: diffs_34_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_34_commit_id_idx;


--
-- Name: diffs_34_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_34_fyle_id_idx;


--
-- Name: diffs_34_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_34_id_idx;


--
-- Name: diffs_35_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_35_code_set_id_idx;


--
-- Name: diffs_35_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_35_commit_id_idx;


--
-- Name: diffs_35_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_35_fyle_id_idx;


--
-- Name: diffs_35_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_35_id_idx;


--
-- Name: diffs_36_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_36_code_set_id_idx;


--
-- Name: diffs_36_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_36_commit_id_idx;


--
-- Name: diffs_36_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_36_fyle_id_idx;


--
-- Name: diffs_36_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_36_id_idx;


--
-- Name: diffs_37_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_37_code_set_id_idx;


--
-- Name: diffs_37_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_37_commit_id_idx;


--
-- Name: diffs_37_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_37_fyle_id_idx;


--
-- Name: diffs_37_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_37_id_idx;


--
-- Name: diffs_38_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_38_code_set_id_idx;


--
-- Name: diffs_38_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_38_commit_id_idx;


--
-- Name: diffs_38_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_38_fyle_id_idx;


--
-- Name: diffs_38_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_38_id_idx;


--
-- Name: diffs_39_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_39_code_set_id_idx;


--
-- Name: diffs_39_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_39_commit_id_idx;


--
-- Name: diffs_39_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_39_fyle_id_idx;


--
-- Name: diffs_39_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_39_id_idx;


--
-- Name: diffs_3_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_3_code_set_id_idx;


--
-- Name: diffs_3_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_3_commit_id_idx;


--
-- Name: diffs_3_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_3_fyle_id_idx;


--
-- Name: diffs_3_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_3_id_idx;


--
-- Name: diffs_40_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_40_code_set_id_idx;


--
-- Name: diffs_40_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_40_commit_id_idx;


--
-- Name: diffs_40_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_40_fyle_id_idx;


--
-- Name: diffs_40_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_40_id_idx;


--
-- Name: diffs_41_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_41_code_set_id_idx;


--
-- Name: diffs_41_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_41_commit_id_idx;


--
-- Name: diffs_41_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_41_fyle_id_idx;


--
-- Name: diffs_41_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_41_id_idx;


--
-- Name: diffs_42_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_42_code_set_id_idx;


--
-- Name: diffs_42_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_42_commit_id_idx;


--
-- Name: diffs_42_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_42_fyle_id_idx;


--
-- Name: diffs_42_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_42_id_idx;


--
-- Name: diffs_43_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_43_code_set_id_idx;


--
-- Name: diffs_43_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_43_commit_id_idx;


--
-- Name: diffs_43_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_43_fyle_id_idx;


--
-- Name: diffs_43_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_43_id_idx;


--
-- Name: diffs_44_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_44_code_set_id_idx;


--
-- Name: diffs_44_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_44_commit_id_idx;


--
-- Name: diffs_44_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_44_fyle_id_idx;


--
-- Name: diffs_44_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_44_id_idx;


--
-- Name: diffs_45_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_45_code_set_id_idx;


--
-- Name: diffs_45_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_45_commit_id_idx;


--
-- Name: diffs_45_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_45_fyle_id_idx;


--
-- Name: diffs_45_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_45_id_idx;


--
-- Name: diffs_46_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_46_code_set_id_idx;


--
-- Name: diffs_46_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_46_commit_id_idx;


--
-- Name: diffs_46_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_46_fyle_id_idx;


--
-- Name: diffs_46_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_46_id_idx;


--
-- Name: diffs_47_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_47_code_set_id_idx;


--
-- Name: diffs_47_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_47_commit_id_idx;


--
-- Name: diffs_47_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_47_fyle_id_idx;


--
-- Name: diffs_47_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_47_id_idx;


--
-- Name: diffs_48_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_48_code_set_id_idx;


--
-- Name: diffs_48_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_48_commit_id_idx;


--
-- Name: diffs_48_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_48_fyle_id_idx;


--
-- Name: diffs_48_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_48_id_idx;


--
-- Name: diffs_49_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_49_code_set_id_idx;


--
-- Name: diffs_49_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_49_commit_id_idx;


--
-- Name: diffs_49_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_49_fyle_id_idx;


--
-- Name: diffs_49_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_49_id_idx;


--
-- Name: diffs_4_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_4_code_set_id_idx;


--
-- Name: diffs_4_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_4_commit_id_idx;


--
-- Name: diffs_4_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_4_fyle_id_idx;


--
-- Name: diffs_4_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_4_id_idx;


--
-- Name: diffs_50_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_50_code_set_id_idx;


--
-- Name: diffs_50_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_50_commit_id_idx;


--
-- Name: diffs_50_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_50_fyle_id_idx;


--
-- Name: diffs_50_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_50_id_idx;


--
-- Name: diffs_51_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_51_code_set_id_idx;


--
-- Name: diffs_51_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_51_commit_id_idx;


--
-- Name: diffs_51_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_51_fyle_id_idx;


--
-- Name: diffs_51_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_51_id_idx;


--
-- Name: diffs_52_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_52_code_set_id_idx;


--
-- Name: diffs_52_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_52_commit_id_idx;


--
-- Name: diffs_52_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_52_fyle_id_idx;


--
-- Name: diffs_52_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_52_id_idx;


--
-- Name: diffs_53_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_53_code_set_id_idx;


--
-- Name: diffs_53_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_53_commit_id_idx;


--
-- Name: diffs_53_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_53_fyle_id_idx;


--
-- Name: diffs_53_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_53_id_idx;


--
-- Name: diffs_54_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_54_code_set_id_idx;


--
-- Name: diffs_54_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_54_commit_id_idx;


--
-- Name: diffs_54_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_54_fyle_id_idx;


--
-- Name: diffs_54_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_54_id_idx;


--
-- Name: diffs_55_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_55_code_set_id_idx;


--
-- Name: diffs_55_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_55_commit_id_idx;


--
-- Name: diffs_55_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_55_fyle_id_idx;


--
-- Name: diffs_55_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_55_id_idx;


--
-- Name: diffs_56_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_56_code_set_id_idx;


--
-- Name: diffs_56_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_56_commit_id_idx;


--
-- Name: diffs_56_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_56_fyle_id_idx;


--
-- Name: diffs_56_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_56_id_idx;


--
-- Name: diffs_57_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_57_code_set_id_idx;


--
-- Name: diffs_57_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_57_commit_id_idx;


--
-- Name: diffs_57_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_57_fyle_id_idx;


--
-- Name: diffs_57_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_57_id_idx;


--
-- Name: diffs_58_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_58_code_set_id_idx;


--
-- Name: diffs_58_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_58_commit_id_idx;


--
-- Name: diffs_58_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_58_fyle_id_idx;


--
-- Name: diffs_58_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_58_id_idx;


--
-- Name: diffs_59_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_59_code_set_id_idx;


--
-- Name: diffs_59_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_59_commit_id_idx;


--
-- Name: diffs_59_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_59_fyle_id_idx;


--
-- Name: diffs_59_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_59_id_idx;


--
-- Name: diffs_5_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_5_code_set_id_idx;


--
-- Name: diffs_5_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_5_commit_id_idx;


--
-- Name: diffs_5_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_5_fyle_id_idx;


--
-- Name: diffs_5_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_5_id_idx;


--
-- Name: diffs_60_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_60_code_set_id_idx;


--
-- Name: diffs_60_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_60_commit_id_idx;


--
-- Name: diffs_60_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_60_fyle_id_idx;


--
-- Name: diffs_60_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_60_id_idx;


--
-- Name: diffs_61_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_61_code_set_id_idx;


--
-- Name: diffs_61_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_61_commit_id_idx;


--
-- Name: diffs_61_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_61_fyle_id_idx;


--
-- Name: diffs_61_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_61_id_idx;


--
-- Name: diffs_62_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_62_code_set_id_idx;


--
-- Name: diffs_62_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_62_commit_id_idx;


--
-- Name: diffs_62_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_62_fyle_id_idx;


--
-- Name: diffs_62_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_62_id_idx;


--
-- Name: diffs_63_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_63_code_set_id_idx;


--
-- Name: diffs_63_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_63_commit_id_idx;


--
-- Name: diffs_63_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_63_fyle_id_idx;


--
-- Name: diffs_63_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_63_id_idx;


--
-- Name: diffs_64_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_64_code_set_id_idx;


--
-- Name: diffs_64_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_64_commit_id_idx;


--
-- Name: diffs_64_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_64_fyle_id_idx;


--
-- Name: diffs_64_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_64_id_idx;


--
-- Name: diffs_65_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_65_code_set_id_idx;


--
-- Name: diffs_65_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_65_commit_id_idx;


--
-- Name: diffs_65_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_65_fyle_id_idx;


--
-- Name: diffs_65_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_65_id_idx;


--
-- Name: diffs_66_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_66_code_set_id_idx;


--
-- Name: diffs_66_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_66_commit_id_idx;


--
-- Name: diffs_66_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_66_fyle_id_idx;


--
-- Name: diffs_66_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_66_id_idx;


--
-- Name: diffs_67_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_67_code_set_id_idx;


--
-- Name: diffs_67_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_67_commit_id_idx;


--
-- Name: diffs_67_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_67_fyle_id_idx;


--
-- Name: diffs_67_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_67_id_idx;


--
-- Name: diffs_68_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_68_code_set_id_idx;


--
-- Name: diffs_68_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_68_commit_id_idx;


--
-- Name: diffs_68_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_68_fyle_id_idx;


--
-- Name: diffs_68_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_68_id_idx;


--
-- Name: diffs_69_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_69_code_set_id_idx;


--
-- Name: diffs_69_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_69_commit_id_idx;


--
-- Name: diffs_69_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_69_fyle_id_idx;


--
-- Name: diffs_69_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_69_id_idx;


--
-- Name: diffs_6_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_6_code_set_id_idx;


--
-- Name: diffs_6_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_6_commit_id_idx;


--
-- Name: diffs_6_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_6_fyle_id_idx;


--
-- Name: diffs_6_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_6_id_idx;


--
-- Name: diffs_70_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_70_code_set_id_idx;


--
-- Name: diffs_70_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_70_commit_id_idx;


--
-- Name: diffs_70_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_70_fyle_id_idx;


--
-- Name: diffs_70_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_70_id_idx;


--
-- Name: diffs_71_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_71_code_set_id_idx;


--
-- Name: diffs_71_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_71_commit_id_idx;


--
-- Name: diffs_71_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_71_fyle_id_idx;


--
-- Name: diffs_71_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_71_id_idx;


--
-- Name: diffs_72_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_72_code_set_id_idx;


--
-- Name: diffs_72_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_72_commit_id_idx;


--
-- Name: diffs_72_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_72_fyle_id_idx;


--
-- Name: diffs_72_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_72_id_idx;


--
-- Name: diffs_73_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_73_code_set_id_idx;


--
-- Name: diffs_73_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_73_commit_id_idx;


--
-- Name: diffs_73_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_73_fyle_id_idx;


--
-- Name: diffs_73_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_73_id_idx;


--
-- Name: diffs_74_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_74_code_set_id_idx;


--
-- Name: diffs_74_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_74_commit_id_idx;


--
-- Name: diffs_74_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_74_fyle_id_idx;


--
-- Name: diffs_74_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_74_id_idx;


--
-- Name: diffs_75_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_75_code_set_id_idx;


--
-- Name: diffs_75_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_75_commit_id_idx;


--
-- Name: diffs_75_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_75_fyle_id_idx;


--
-- Name: diffs_75_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_75_id_idx;


--
-- Name: diffs_76_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_76_code_set_id_idx;


--
-- Name: diffs_76_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_76_commit_id_idx;


--
-- Name: diffs_76_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_76_fyle_id_idx;


--
-- Name: diffs_76_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_76_id_idx;


--
-- Name: diffs_77_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_77_code_set_id_idx;


--
-- Name: diffs_77_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_77_commit_id_idx;


--
-- Name: diffs_77_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_77_fyle_id_idx;


--
-- Name: diffs_77_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_77_id_idx;


--
-- Name: diffs_78_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_78_code_set_id_idx;


--
-- Name: diffs_78_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_78_commit_id_idx;


--
-- Name: diffs_78_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_78_fyle_id_idx;


--
-- Name: diffs_78_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_78_id_idx;


--
-- Name: diffs_79_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_79_code_set_id_idx;


--
-- Name: diffs_79_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_79_commit_id_idx;


--
-- Name: diffs_79_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_79_fyle_id_idx;


--
-- Name: diffs_79_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_79_id_idx;


--
-- Name: diffs_7_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_7_code_set_id_idx;


--
-- Name: diffs_7_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_7_commit_id_idx;


--
-- Name: diffs_7_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_7_fyle_id_idx;


--
-- Name: diffs_7_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_7_id_idx;


--
-- Name: diffs_80_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_80_code_set_id_idx;


--
-- Name: diffs_80_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_80_commit_id_idx;


--
-- Name: diffs_80_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_80_fyle_id_idx;


--
-- Name: diffs_80_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_80_id_idx;


--
-- Name: diffs_81_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_81_code_set_id_idx;


--
-- Name: diffs_81_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_81_commit_id_idx;


--
-- Name: diffs_81_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_81_fyle_id_idx;


--
-- Name: diffs_81_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_81_id_idx;


--
-- Name: diffs_82_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_82_code_set_id_idx;


--
-- Name: diffs_82_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_82_commit_id_idx;


--
-- Name: diffs_82_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_82_fyle_id_idx;


--
-- Name: diffs_82_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_82_id_idx;


--
-- Name: diffs_83_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_83_code_set_id_idx;


--
-- Name: diffs_83_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_83_commit_id_idx;


--
-- Name: diffs_83_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_83_fyle_id_idx;


--
-- Name: diffs_83_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_83_id_idx;


--
-- Name: diffs_84_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_84_code_set_id_idx;


--
-- Name: diffs_84_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_84_commit_id_idx;


--
-- Name: diffs_84_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_84_fyle_id_idx;


--
-- Name: diffs_84_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_84_id_idx;


--
-- Name: diffs_85_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_85_code_set_id_idx;


--
-- Name: diffs_85_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_85_commit_id_idx;


--
-- Name: diffs_85_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_85_fyle_id_idx;


--
-- Name: diffs_85_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_85_id_idx;


--
-- Name: diffs_86_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_86_code_set_id_idx;


--
-- Name: diffs_86_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_86_commit_id_idx;


--
-- Name: diffs_86_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_86_fyle_id_idx;


--
-- Name: diffs_86_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_86_id_idx;


--
-- Name: diffs_87_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_87_code_set_id_idx;


--
-- Name: diffs_87_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_87_commit_id_idx;


--
-- Name: diffs_87_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_87_fyle_id_idx;


--
-- Name: diffs_87_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_87_id_idx;


--
-- Name: diffs_88_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_88_code_set_id_idx;


--
-- Name: diffs_88_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_88_commit_id_idx;


--
-- Name: diffs_88_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_88_fyle_id_idx;


--
-- Name: diffs_88_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_88_id_idx;


--
-- Name: diffs_89_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_89_code_set_id_idx;


--
-- Name: diffs_89_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_89_commit_id_idx;


--
-- Name: diffs_89_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_89_fyle_id_idx;


--
-- Name: diffs_89_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_89_id_idx;


--
-- Name: diffs_8_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_8_code_set_id_idx;


--
-- Name: diffs_8_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_8_commit_id_idx;


--
-- Name: diffs_8_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_8_fyle_id_idx;


--
-- Name: diffs_8_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_8_id_idx;


--
-- Name: diffs_90_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_90_code_set_id_idx;


--
-- Name: diffs_90_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_90_commit_id_idx;


--
-- Name: diffs_90_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_90_fyle_id_idx;


--
-- Name: diffs_90_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_90_id_idx;


--
-- Name: diffs_91_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_91_code_set_id_idx;


--
-- Name: diffs_91_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_91_commit_id_idx;


--
-- Name: diffs_91_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_91_fyle_id_idx;


--
-- Name: diffs_91_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_91_id_idx;


--
-- Name: diffs_92_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_92_code_set_id_idx;


--
-- Name: diffs_92_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_92_commit_id_idx;


--
-- Name: diffs_92_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_92_fyle_id_idx;


--
-- Name: diffs_92_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_92_id_idx;


--
-- Name: diffs_93_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_93_code_set_id_idx;


--
-- Name: diffs_93_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_93_commit_id_idx;


--
-- Name: diffs_93_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_93_fyle_id_idx;


--
-- Name: diffs_93_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_93_id_idx;


--
-- Name: diffs_94_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_94_code_set_id_idx;


--
-- Name: diffs_94_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_94_commit_id_idx;


--
-- Name: diffs_94_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_94_fyle_id_idx;


--
-- Name: diffs_94_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_94_id_idx;


--
-- Name: diffs_95_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_95_code_set_id_idx;


--
-- Name: diffs_95_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_95_commit_id_idx;


--
-- Name: diffs_95_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_95_fyle_id_idx;


--
-- Name: diffs_95_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_95_id_idx;


--
-- Name: diffs_96_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_96_code_set_id_idx;


--
-- Name: diffs_96_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_96_commit_id_idx;


--
-- Name: diffs_96_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_96_fyle_id_idx;


--
-- Name: diffs_96_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_96_id_idx;


--
-- Name: diffs_97_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_97_code_set_id_idx;


--
-- Name: diffs_97_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_97_commit_id_idx;


--
-- Name: diffs_97_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_97_fyle_id_idx;


--
-- Name: diffs_97_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_97_id_idx;


--
-- Name: diffs_98_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_98_code_set_id_idx;


--
-- Name: diffs_98_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_98_commit_id_idx;


--
-- Name: diffs_98_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_98_fyle_id_idx;


--
-- Name: diffs_98_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_98_id_idx;


--
-- Name: diffs_99_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_99_code_set_id_idx;


--
-- Name: diffs_99_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_99_commit_id_idx;


--
-- Name: diffs_99_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_99_fyle_id_idx;


--
-- Name: diffs_99_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_99_id_idx;


--
-- Name: diffs_9_code_set_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_code_set_id ATTACH PARTITION fis.diffs_9_code_set_id_idx;


--
-- Name: diffs_9_commit_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_commit_id ATTACH PARTITION fis.diffs_9_commit_id_idx;


--
-- Name: diffs_9_fyle_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_fyle_id ATTACH PARTITION fis.diffs_9_fyle_id_idx;


--
-- Name: diffs_9_id_idx; Type: INDEX ATTACH; Schema: fis; Owner: -
--

ALTER INDEX fis.index_diffs_on_id ATTACH PARTITION fis.diffs_9_id_idx;


--
-- Name: analysis_sloc_sets analysis_sloc_sets_sloc_set_id_fkey; Type: FK CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.analysis_sloc_sets
    ADD CONSTRAINT analysis_sloc_sets_sloc_set_id_fkey FOREIGN KEY (sloc_set_id) REFERENCES fis.sloc_sets(id);


--
-- Name: code_locations fk_rails_10af29f194; Type: FK CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.code_locations
    ADD CONSTRAINT fk_rails_10af29f194 FOREIGN KEY (last_job_id) REFERENCES fis.jobs(id);


--
-- Name: subscriptions fk_rails_481c653bad; Type: FK CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.subscriptions
    ADD CONSTRAINT fk_rails_481c653bad FOREIGN KEY (registration_key_id) REFERENCES fis.registration_keys(id);


--
-- Name: code_location_dnfs fk_rails_7c58333612; Type: FK CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.code_location_dnfs
    ADD CONSTRAINT fk_rails_7c58333612 FOREIGN KEY (code_location_id) REFERENCES fis.code_locations(id);


--
-- Name: repository_directories fk_rails_d33c461543; Type: FK CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.repository_directories
    ADD CONSTRAINT fk_rails_d33c461543 FOREIGN KEY (code_location_id) REFERENCES fis.code_locations(id);


--
-- Name: jobs jobs_failure_group_id_fkey; Type: FK CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.jobs
    ADD CONSTRAINT jobs_failure_group_id_fkey FOREIGN KEY (failure_group_id) REFERENCES fis.failure_groups(id);


--
-- Name: slave_logs slave_logs_slave_id_fkey; Type: FK CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.slave_logs
    ADD CONSTRAINT slave_logs_slave_id_fkey FOREIGN KEY (slave_id) REFERENCES fis.slaves(id) ON DELETE CASCADE;


--
-- Name: sloc_sets sloc_sets_code_set_id_fkey; Type: FK CONSTRAINT; Schema: fis; Owner: -
--

ALTER TABLE ONLY fis.sloc_sets
    ADD CONSTRAINT sloc_sets_code_set_id_fkey FOREIGN KEY (code_set_id) REFERENCES fis.code_sets(id) ON DELETE CASCADE;


--
-- Name: account_reports account_reports_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.account_reports
    ADD CONSTRAINT account_reports_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: account_reports account_reports_report_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.account_reports
    ADD CONSTRAINT account_reports_report_id_fkey FOREIGN KEY (report_id) REFERENCES oh.reports(id) ON DELETE CASCADE;


--
-- Name: accounts accounts_about_markup_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.accounts
    ADD CONSTRAINT accounts_about_markup_id_fkey FOREIGN KEY (about_markup_id) REFERENCES oh.markups(id) ON DELETE CASCADE;


--
-- Name: accounts accounts_best_vita_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.accounts
    ADD CONSTRAINT accounts_best_vita_id_fkey FOREIGN KEY (best_vita_id) REFERENCES oh.vitae(id);


--
-- Name: accounts accounts_organization_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.accounts
    ADD CONSTRAINT accounts_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES oh.organizations(id) ON DELETE CASCADE;


--
-- Name: actions actions_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.actions
    ADD CONSTRAINT actions_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: actions actions_claim_person_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.actions
    ADD CONSTRAINT actions_claim_person_id_fkey FOREIGN KEY (claim_person_id) REFERENCES oh.people(id);


--
-- Name: actions actions_stack_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.actions
    ADD CONSTRAINT actions_stack_project_id_fkey FOREIGN KEY (stack_project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: activity_facts activity_facts_analysis_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.activity_facts
    ADD CONSTRAINT activity_facts_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES oh.analyses(id) ON DELETE CASCADE;


--
-- Name: activity_facts activity_facts_language_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.activity_facts
    ADD CONSTRAINT activity_facts_language_id_fkey FOREIGN KEY (language_id) REFERENCES oh.languages(id);


--
-- Name: aliases aliases_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.aliases
    ADD CONSTRAINT aliases_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: analyses analyses_main_language_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.analyses
    ADD CONSTRAINT analyses_main_language_id_fkey FOREIGN KEY (main_language_id) REFERENCES oh.languages(id);


--
-- Name: analyses analyses_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.analyses
    ADD CONSTRAINT analyses_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: analysis_summaries analysis_summaries_analysis_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.analysis_summaries
    ADD CONSTRAINT analysis_summaries_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES oh.analyses(id);


--
-- Name: api_keys api_keys_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.api_keys
    ADD CONSTRAINT api_keys_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: authorizations authorizations_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.authorizations
    ADD CONSTRAINT authorizations_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: authorizations authorizations_api_key_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.authorizations
    ADD CONSTRAINT authorizations_api_key_id_fkey FOREIGN KEY (api_key_id) REFERENCES oh.api_keys(id) ON DELETE CASCADE;


--
-- Name: positions claims_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.positions
    ADD CONSTRAINT claims_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: positions claims_name_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.positions
    ADD CONSTRAINT claims_name_id_fkey FOREIGN KEY (name_id) REFERENCES oh.names(id) ON DELETE CASCADE;


--
-- Name: positions claims_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.positions
    ADD CONSTRAINT claims_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: duplicates duplicates_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.duplicates
    ADD CONSTRAINT duplicates_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: duplicates duplicates_bad_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.duplicates
    ADD CONSTRAINT duplicates_bad_project_id_fkey FOREIGN KEY (bad_project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: duplicates duplicates_good_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.duplicates
    ADD CONSTRAINT duplicates_good_project_id_fkey FOREIGN KEY (good_project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: edits edits_account_id_fkey1; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.edits
    ADD CONSTRAINT edits_account_id_fkey1 FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: edits edits_organization_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.edits
    ADD CONSTRAINT edits_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES oh.organizations(id) ON DELETE CASCADE;


--
-- Name: edits edits_project_id_fkey1; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.edits
    ADD CONSTRAINT edits_project_id_fkey1 FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: edits edits_undone_by_fkey1; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.edits
    ADD CONSTRAINT edits_undone_by_fkey1 FOREIGN KEY (undone_by) REFERENCES oh.accounts(id);


--
-- Name: enlistments enlistments_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.enlistments
    ADD CONSTRAINT enlistments_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: event_subscription event_subscription_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.event_subscription
    ADD CONSTRAINT event_subscription_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: event_subscription event_subscription_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.event_subscription
    ADD CONSTRAINT event_subscription_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: event_subscription event_subscription_subscriber_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.event_subscription
    ADD CONSTRAINT event_subscription_subscriber_id_fkey FOREIGN KEY (subscriber_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: event_subscription event_subscription_topic_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.event_subscription
    ADD CONSTRAINT event_subscription_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES oh.topics(id) ON DELETE CASCADE;


--
-- Name: exhibits exhibits_report_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.exhibits
    ADD CONSTRAINT exhibits_report_id_fkey FOREIGN KEY (report_id) REFERENCES oh.reports(id) ON DELETE CASCADE;


--
-- Name: factoids factoids_analysis_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.factoids
    ADD CONSTRAINT factoids_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES oh.analyses(id) ON DELETE CASCADE;


--
-- Name: factoids factoids_language_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.factoids
    ADD CONSTRAINT factoids_language_id_fkey FOREIGN KEY (language_id) REFERENCES oh.languages(id);


--
-- Name: factoids factoids_license_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.factoids
    ADD CONSTRAINT factoids_license_id_fkey FOREIGN KEY (license_id) REFERENCES oh.licenses(id);


--
-- Name: org_thirty_day_activities fk_organization_ids; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.org_thirty_day_activities
    ADD CONSTRAINT fk_organization_ids FOREIGN KEY (organization_id) REFERENCES oh.organizations(id) ON DELETE CASCADE;


--
-- Name: project_vulnerability_reports fk_project_ids; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_vulnerability_reports
    ADD CONSTRAINT fk_project_ids FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: project_badges fk_rails_4c3c9e5c61; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_badges
    ADD CONSTRAINT fk_rails_4c3c9e5c61 FOREIGN KEY (enlistment_id) REFERENCES oh.enlistments(id);


--
-- Name: reviewed_non_spammers fk_rails_8e42d136f8; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.reviewed_non_spammers
    ADD CONSTRAINT fk_rails_8e42d136f8 FOREIGN KEY (account_id) REFERENCES oh.accounts(id);


--
-- Name: api_keys fk_rails_8faa63554c; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.api_keys
    ADD CONSTRAINT fk_rails_8faa63554c FOREIGN KEY (oauth_application_id) REFERENCES oh.oauth_applications(id);


--
-- Name: broken_links fk_rails_a80ad58988; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.broken_links
    ADD CONSTRAINT fk_rails_a80ad58988 FOREIGN KEY (link_id) REFERENCES oh.links(id);


--
-- Name: projects fk_rails_c67f665226; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.projects
    ADD CONSTRAINT fk_rails_c67f665226 FOREIGN KEY (best_project_security_set_id) REFERENCES oh.project_security_sets(id);


--
-- Name: project_security_sets fk_rails_efaa9c9657; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_security_sets
    ADD CONSTRAINT fk_rails_efaa9c9657 FOREIGN KEY (project_id) REFERENCES oh.projects(id);


--
-- Name: follows follows_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.follows
    ADD CONSTRAINT follows_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: follows follows_owner_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.follows
    ADD CONSTRAINT follows_owner_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: follows follows_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.follows
    ADD CONSTRAINT follows_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: forums forums_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.forums
    ADD CONSTRAINT forums_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id);


--
-- Name: helpfuls helpfuls_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.helpfuls
    ADD CONSTRAINT helpfuls_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: helpfuls helpfuls_review_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.helpfuls
    ADD CONSTRAINT helpfuls_review_id_fkey FOREIGN KEY (review_id) REFERENCES oh.reviews(id) ON DELETE CASCADE;


--
-- Name: invites invites_invitee_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.invites
    ADD CONSTRAINT invites_invitee_id_fkey FOREIGN KEY (invitee_id) REFERENCES oh.accounts(id);


--
-- Name: invites invites_invitor_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.invites
    ADD CONSTRAINT invites_invitor_id_fkey FOREIGN KEY (invitor_id) REFERENCES oh.accounts(id);


--
-- Name: invites invites_name_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.invites
    ADD CONSTRAINT invites_name_id_fkey FOREIGN KEY (name_id) REFERENCES oh.names(id);


--
-- Name: invites invites_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.invites
    ADD CONSTRAINT invites_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id);


--
-- Name: knowledge_base_statuses knowledge_base_statuses_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.knowledge_base_statuses
    ADD CONSTRAINT knowledge_base_statuses_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: kudos kudos_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.kudos
    ADD CONSTRAINT kudos_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: kudos kudos_name_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.kudos
    ADD CONSTRAINT kudos_name_id_fkey FOREIGN KEY (name_id) REFERENCES oh.names(id) ON DELETE CASCADE;


--
-- Name: kudos kudos_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.kudos
    ADD CONSTRAINT kudos_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: kudos kudos_sender_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.kudos
    ADD CONSTRAINT kudos_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: language_experiences language_experiences_language_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.language_experiences
    ADD CONSTRAINT language_experiences_language_id_fkey FOREIGN KEY (language_id) REFERENCES oh.languages(id) ON DELETE CASCADE;


--
-- Name: language_experiences language_experiences_position_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.language_experiences
    ADD CONSTRAINT language_experiences_position_id_fkey FOREIGN KEY (position_id) REFERENCES oh.positions(id) ON DELETE CASCADE;


--
-- Name: language_facts language_facts_language_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.language_facts
    ADD CONSTRAINT language_facts_language_id_fkey FOREIGN KEY (language_id) REFERENCES oh.languages(id) ON DELETE CASCADE;


--
-- Name: license_facts license_facts_analysis_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.license_facts
    ADD CONSTRAINT license_facts_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES oh.analyses(id) ON DELETE CASCADE;


--
-- Name: license_facts license_facts_license_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.license_facts
    ADD CONSTRAINT license_facts_license_id_fkey FOREIGN KEY (license_id) REFERENCES oh.licenses(id);


--
-- Name: links links_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.links
    ADD CONSTRAINT links_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: manages manages_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.manages
    ADD CONSTRAINT manages_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: manages manages_approved_by_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.manages
    ADD CONSTRAINT manages_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES oh.accounts(id);


--
-- Name: manages manages_deleted_by_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.manages
    ADD CONSTRAINT manages_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES oh.accounts(id);


--
-- Name: message_account_tags message_account_tags_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.message_account_tags
    ADD CONSTRAINT message_account_tags_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: message_account_tags message_account_tags_message_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.message_account_tags
    ADD CONSTRAINT message_account_tags_message_id_fkey FOREIGN KEY (message_id) REFERENCES oh.messages(id) ON DELETE CASCADE;


--
-- Name: message_project_tags message_project_tags_message_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.message_project_tags
    ADD CONSTRAINT message_project_tags_message_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: message_project_tags message_project_tags_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.message_project_tags
    ADD CONSTRAINT message_project_tags_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: messages messages_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.messages
    ADD CONSTRAINT messages_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: name_facts name_facts_analysis_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.name_facts
    ADD CONSTRAINT name_facts_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES oh.analyses(id) ON DELETE CASCADE;


--
-- Name: name_facts name_facts_name_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.name_facts
    ADD CONSTRAINT name_facts_name_id_fkey FOREIGN KEY (name_id) REFERENCES oh.names(id);


--
-- Name: name_facts name_facts_primary_language_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.name_facts
    ADD CONSTRAINT name_facts_primary_language_id_fkey FOREIGN KEY (primary_language_id) REFERENCES oh.languages(id);


--
-- Name: name_facts name_facts_vita_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.name_facts
    ADD CONSTRAINT name_facts_vita_id_fkey FOREIGN KEY (vita_id) REFERENCES oh.vitae(id) ON DELETE CASCADE;


--
-- Name: name_language_facts name_language_facts_analysis_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.name_language_facts
    ADD CONSTRAINT name_language_facts_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES oh.analyses(id) ON DELETE CASCADE;


--
-- Name: name_language_facts name_language_facts_language_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.name_language_facts
    ADD CONSTRAINT name_language_facts_language_id_fkey FOREIGN KEY (language_id) REFERENCES oh.languages(id) ON DELETE CASCADE;


--
-- Name: name_language_facts name_language_facts_most_commits_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.name_language_facts
    ADD CONSTRAINT name_language_facts_most_commits_project_id_fkey FOREIGN KEY (most_commits_project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: name_language_facts name_language_facts_name_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.name_language_facts
    ADD CONSTRAINT name_language_facts_name_id_fkey FOREIGN KEY (name_id) REFERENCES oh.names(id) ON DELETE CASCADE;


--
-- Name: name_language_facts name_language_facts_recent_commit_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.name_language_facts
    ADD CONSTRAINT name_language_facts_recent_commit_project_id_fkey FOREIGN KEY (recent_commit_project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: name_language_facts name_language_facts_vita_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.name_language_facts
    ADD CONSTRAINT name_language_facts_vita_id_fkey FOREIGN KEY (vita_id) REFERENCES oh.vitae(id) ON DELETE CASCADE;


--
-- Name: organizations organizations_logo_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.organizations
    ADD CONSTRAINT organizations_logo_id_fkey FOREIGN KEY (logo_id) REFERENCES oh.attachments(id);


--
-- Name: people people_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.people
    ADD CONSTRAINT people_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: people people_name_fact_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.people
    ADD CONSTRAINT people_name_fact_id_fkey FOREIGN KEY (name_fact_id) REFERENCES oh.name_facts(id) ON DELETE CASCADE;


--
-- Name: people people_name_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.people
    ADD CONSTRAINT people_name_id_fkey FOREIGN KEY (name_id) REFERENCES oh.names(id) ON DELETE CASCADE;


--
-- Name: people people_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.people
    ADD CONSTRAINT people_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: positions positions_organization_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.positions
    ADD CONSTRAINT positions_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES oh.organizations(id) ON DELETE CASCADE;


--
-- Name: posts posts_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.posts
    ADD CONSTRAINT posts_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: posts posts_topic_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.posts
    ADD CONSTRAINT posts_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES oh.topics(id) ON DELETE CASCADE;


--
-- Name: project_events project_events_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_events
    ADD CONSTRAINT project_events_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: project_experiences project_experiences_position_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_experiences
    ADD CONSTRAINT project_experiences_position_id_fkey FOREIGN KEY (position_id) REFERENCES oh.positions(id) ON DELETE CASCADE;


--
-- Name: project_experiences project_experiences_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_experiences
    ADD CONSTRAINT project_experiences_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: project_licenses project_licenses_license_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_licenses
    ADD CONSTRAINT project_licenses_license_id_fkey FOREIGN KEY (license_id) REFERENCES oh.licenses(id) ON DELETE CASCADE;


--
-- Name: project_licenses project_licenses_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_licenses
    ADD CONSTRAINT project_licenses_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: project_reports project_reports_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_reports
    ADD CONSTRAINT project_reports_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: project_reports project_reports_report_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.project_reports
    ADD CONSTRAINT project_reports_report_id_fkey FOREIGN KEY (report_id) REFERENCES oh.reports(id) ON DELETE CASCADE;


--
-- Name: projects projects_best_analysis_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.projects
    ADD CONSTRAINT projects_best_analysis_id_fkey FOREIGN KEY (best_analysis_id) REFERENCES oh.analyses(id);


--
-- Name: projects projects_logo_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.projects
    ADD CONSTRAINT projects_logo_id_fkey FOREIGN KEY (logo_id) REFERENCES oh.attachments(id);


--
-- Name: projects projects_organization_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.projects
    ADD CONSTRAINT projects_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES oh.organizations(id);


--
-- Name: ratings ratings_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.ratings
    ADD CONSTRAINT ratings_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: ratings ratings_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.ratings
    ADD CONSTRAINT ratings_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: recommend_entries recommend_entries_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.recommend_entries
    ADD CONSTRAINT recommend_entries_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: recommend_entries recommend_entries_project_id_recommends_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.recommend_entries
    ADD CONSTRAINT recommend_entries_project_id_recommends_fkey FOREIGN KEY (project_id_recommends) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: recommendations recommendations_invitee_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.recommendations
    ADD CONSTRAINT recommendations_invitee_id_fkey FOREIGN KEY (invitee_id) REFERENCES oh.accounts(id);


--
-- Name: recommendations recommendations_invitor_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.recommendations
    ADD CONSTRAINT recommendations_invitor_id_fkey FOREIGN KEY (invitor_id) REFERENCES oh.accounts(id);


--
-- Name: recommendations recommendations_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.recommendations
    ADD CONSTRAINT recommendations_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.reviews
    ADD CONSTRAINT reviews_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.reviews
    ADD CONSTRAINT reviews_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: rss_articles rss_articles_rss_feed_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.rss_articles
    ADD CONSTRAINT rss_articles_rss_feed_id_fkey FOREIGN KEY (rss_feed_id) REFERENCES oh.rss_feeds(id) ON DELETE CASCADE;


--
-- Name: rss_subscriptions rss_subscriptions_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.rss_subscriptions
    ADD CONSTRAINT rss_subscriptions_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: rss_subscriptions rss_subscriptions_rss_feed_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.rss_subscriptions
    ADD CONSTRAINT rss_subscriptions_rss_feed_id_fkey FOREIGN KEY (rss_feed_id) REFERENCES oh.rss_feeds(id) ON DELETE CASCADE;


--
-- Name: sfprojects sfprojects_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.sfprojects
    ADD CONSTRAINT sfprojects_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id);


--
-- Name: stack_entries stack_entries_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.stack_entries
    ADD CONSTRAINT stack_entries_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: stack_entries stack_entries_stack_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.stack_entries
    ADD CONSTRAINT stack_entries_stack_id_fkey FOREIGN KEY (stack_id) REFERENCES oh.stacks(id) ON DELETE CASCADE;


--
-- Name: stack_ignores stack_ignores_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.stack_ignores
    ADD CONSTRAINT stack_ignores_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: stack_ignores stack_ignores_stack_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.stack_ignores
    ADD CONSTRAINT stack_ignores_stack_id_fkey FOREIGN KEY (stack_id) REFERENCES oh.stacks(id) ON DELETE CASCADE;


--
-- Name: stacks stacks_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.stacks
    ADD CONSTRAINT stacks_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: stacks stacks_project_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.stacks
    ADD CONSTRAINT stacks_project_id_fkey FOREIGN KEY (project_id) REFERENCES oh.projects(id) ON DELETE CASCADE;


--
-- Name: thirty_day_summaries thirty_day_summaries_analysis_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.thirty_day_summaries
    ADD CONSTRAINT thirty_day_summaries_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES oh.analyses(id) ON DELETE CASCADE;


--
-- Name: topics topics_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.topics
    ADD CONSTRAINT topics_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: topics topics_forum_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.topics
    ADD CONSTRAINT topics_forum_id_fkey FOREIGN KEY (forum_id) REFERENCES oh.forums(id) ON DELETE CASCADE;


--
-- Name: topics topics_replied_by_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.topics
    ADD CONSTRAINT topics_replied_by_fkey FOREIGN KEY (replied_by) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- Name: vita_analyses vita_analyses_analysis_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.vita_analyses
    ADD CONSTRAINT vita_analyses_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES oh.analyses(id) ON DELETE CASCADE;


--
-- Name: vita_analyses vita_analyses_vita_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.vita_analyses
    ADD CONSTRAINT vita_analyses_vita_id_fkey FOREIGN KEY (vita_id) REFERENCES oh.vitae(id) ON DELETE CASCADE;


--
-- Name: vitae vitae_account_id_fkey; Type: FK CONSTRAINT; Schema: oh; Owner: -
--

ALTER TABLE ONLY oh.vitae
    ADD CONSTRAINT vitae_account_id_fkey FOREIGN KEY (account_id) REFERENCES oh.accounts(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO oh,oa,fis,public;

INSERT INTO oh.schema_migrations (version) VALUES ('1');

INSERT INTO oh.schema_migrations (version) VALUES ('10');

INSERT INTO oh.schema_migrations (version) VALUES ('100');

INSERT INTO oh.schema_migrations (version) VALUES ('101');

INSERT INTO oh.schema_migrations (version) VALUES ('102');

INSERT INTO oh.schema_migrations (version) VALUES ('11');

INSERT INTO oh.schema_migrations (version) VALUES ('12');

INSERT INTO oh.schema_migrations (version) VALUES ('13');

INSERT INTO oh.schema_migrations (version) VALUES ('14');

INSERT INTO oh.schema_migrations (version) VALUES ('15');

INSERT INTO oh.schema_migrations (version) VALUES ('16');

INSERT INTO oh.schema_migrations (version) VALUES ('17');

INSERT INTO oh.schema_migrations (version) VALUES ('18');

INSERT INTO oh.schema_migrations (version) VALUES ('19');

INSERT INTO oh.schema_migrations (version) VALUES ('2');

INSERT INTO oh.schema_migrations (version) VALUES ('20');

INSERT INTO oh.schema_migrations (version) VALUES ('20120917115347');

INSERT INTO oh.schema_migrations (version) VALUES ('20121010151415');

INSERT INTO oh.schema_migrations (version) VALUES ('20121010154611');

INSERT INTO oh.schema_migrations (version) VALUES ('20121019120254');

INSERT INTO oh.schema_migrations (version) VALUES ('20121115192205');

INSERT INTO oh.schema_migrations (version) VALUES ('20121203072938');

INSERT INTO oh.schema_migrations (version) VALUES ('20121221075843');

INSERT INTO oh.schema_migrations (version) VALUES ('20130103212213');

INSERT INTO oh.schema_migrations (version) VALUES ('20130204030958');

INSERT INTO oh.schema_migrations (version) VALUES ('20130327120650');

INSERT INTO oh.schema_migrations (version) VALUES ('20130328044901');

INSERT INTO oh.schema_migrations (version) VALUES ('20130420101845');

INSERT INTO oh.schema_migrations (version) VALUES ('20130523194226');

INSERT INTO oh.schema_migrations (version) VALUES ('20130605004148');

INSERT INTO oh.schema_migrations (version) VALUES ('20130606080722');

INSERT INTO oh.schema_migrations (version) VALUES ('20130619111100');

INSERT INTO oh.schema_migrations (version) VALUES ('20130620090419');

INSERT INTO oh.schema_migrations (version) VALUES ('20130701124737');

INSERT INTO oh.schema_migrations (version) VALUES ('20130702025530');

INSERT INTO oh.schema_migrations (version) VALUES ('20130703092324');

INSERT INTO oh.schema_migrations (version) VALUES ('20130724115118');

INSERT INTO oh.schema_migrations (version) VALUES ('20130902064947');

INSERT INTO oh.schema_migrations (version) VALUES ('20130930174253');

INSERT INTO oh.schema_migrations (version) VALUES ('20131025003543');

INSERT INTO oh.schema_migrations (version) VALUES ('20131104041543');

INSERT INTO oh.schema_migrations (version) VALUES ('20131113192205');

INSERT INTO oh.schema_migrations (version) VALUES ('20140205202717');

INSERT INTO oh.schema_migrations (version) VALUES ('20140206140232');

INSERT INTO oh.schema_migrations (version) VALUES ('20140413074943');

INSERT INTO oh.schema_migrations (version) VALUES ('20140507104529');

INSERT INTO oh.schema_migrations (version) VALUES ('20140507172200');

INSERT INTO oh.schema_migrations (version) VALUES ('20140707112715');

INSERT INTO oh.schema_migrations (version) VALUES ('20140707151308');

INSERT INTO oh.schema_migrations (version) VALUES ('20140707202707');

INSERT INTO oh.schema_migrations (version) VALUES ('20140819100329');

INSERT INTO oh.schema_migrations (version) VALUES ('20140902095714');

INSERT INTO oh.schema_migrations (version) VALUES ('20140905072436');

INSERT INTO oh.schema_migrations (version) VALUES ('20141016164532');

INSERT INTO oh.schema_migrations (version) VALUES ('20141024100301');

INSERT INTO oh.schema_migrations (version) VALUES ('20141111214901');

INSERT INTO oh.schema_migrations (version) VALUES ('20141124061121');

INSERT INTO oh.schema_migrations (version) VALUES ('20141209070219');

INSERT INTO oh.schema_migrations (version) VALUES ('20141209070642');

INSERT INTO oh.schema_migrations (version) VALUES ('20150213162109');

INSERT INTO oh.schema_migrations (version) VALUES ('20150423054225');

INSERT INTO oh.schema_migrations (version) VALUES ('20150423061349');

INSERT INTO oh.schema_migrations (version) VALUES ('20150429084504');

INSERT INTO oh.schema_migrations (version) VALUES ('20150504072306');

INSERT INTO oh.schema_migrations (version) VALUES ('20150615040531');

INSERT INTO oh.schema_migrations (version) VALUES ('20150615041336');

INSERT INTO oh.schema_migrations (version) VALUES ('20150701173333');

INSERT INTO oh.schema_migrations (version) VALUES ('20150911083411');

INSERT INTO oh.schema_migrations (version) VALUES ('20150911094444');

INSERT INTO oh.schema_migrations (version) VALUES ('20150916092930');

INSERT INTO oh.schema_migrations (version) VALUES ('20150918080726');

INSERT INTO oh.schema_migrations (version) VALUES ('20150925101230');

INSERT INTO oh.schema_migrations (version) VALUES ('20150925101715');

INSERT INTO oh.schema_migrations (version) VALUES ('20151116113941');

INSERT INTO oh.schema_migrations (version) VALUES ('20151124143945');

INSERT INTO oh.schema_migrations (version) VALUES ('20160121110527');

INSERT INTO oh.schema_migrations (version) VALUES ('20160209204755');

INSERT INTO oh.schema_migrations (version) VALUES ('20160216095409');

INSERT INTO oh.schema_migrations (version) VALUES ('20160317061932');

INSERT INTO oh.schema_migrations (version) VALUES ('20160318131123');

INSERT INTO oh.schema_migrations (version) VALUES ('20160321061931');

INSERT INTO oh.schema_migrations (version) VALUES ('20160504111046');

INSERT INTO oh.schema_migrations (version) VALUES ('20160512144023');

INSERT INTO oh.schema_migrations (version) VALUES ('20160608090419');

INSERT INTO oh.schema_migrations (version) VALUES ('20160608194402');

INSERT INTO oh.schema_migrations (version) VALUES ('20160610142302');

INSERT INTO oh.schema_migrations (version) VALUES ('20160710125644');

INSERT INTO oh.schema_migrations (version) VALUES ('20160713124305');

INSERT INTO oh.schema_migrations (version) VALUES ('20160725154001');

INSERT INTO oh.schema_migrations (version) VALUES ('20160803102211');

INSERT INTO oh.schema_migrations (version) VALUES ('20160804081950');

INSERT INTO oh.schema_migrations (version) VALUES ('20160808163201');

INSERT INTO oh.schema_migrations (version) VALUES ('20160818102530');

INSERT INTO oh.schema_migrations (version) VALUES ('20160907122530');

INSERT INTO oh.schema_migrations (version) VALUES ('20160916124401');

INSERT INTO oh.schema_migrations (version) VALUES ('20160920113102');

INSERT INTO oh.schema_migrations (version) VALUES ('20160926144901');

INSERT INTO oh.schema_migrations (version) VALUES ('20161006072823');

INSERT INTO oh.schema_migrations (version) VALUES ('20161007083447');

INSERT INTO oh.schema_migrations (version) VALUES ('20161024095609');

INSERT INTO oh.schema_migrations (version) VALUES ('20161027065200');

INSERT INTO oh.schema_migrations (version) VALUES ('20161101134545');

INSERT INTO oh.schema_migrations (version) VALUES ('20161103153643');

INSERT INTO oh.schema_migrations (version) VALUES ('20161114063801');

INSERT INTO oh.schema_migrations (version) VALUES ('20161128183115');

INSERT INTO oh.schema_migrations (version) VALUES ('20161227165430');

INSERT INTO oh.schema_migrations (version) VALUES ('20170112183242');

INSERT INTO oh.schema_migrations (version) VALUES ('20170117164106');

INSERT INTO oh.schema_migrations (version) VALUES ('20170206161036');

INSERT INTO oh.schema_migrations (version) VALUES ('20170301092424');

INSERT INTO oh.schema_migrations (version) VALUES ('20170320110140');

INSERT INTO oh.schema_migrations (version) VALUES ('20170323130035');

INSERT INTO oh.schema_migrations (version) VALUES ('20170411054438');

INSERT INTO oh.schema_migrations (version) VALUES ('20170609195100');

INSERT INTO oh.schema_migrations (version) VALUES ('20170616152705');

INSERT INTO oh.schema_migrations (version) VALUES ('20170806122538');

INSERT INTO oh.schema_migrations (version) VALUES ('20170806141217');

INSERT INTO oh.schema_migrations (version) VALUES ('20170904072947');

INSERT INTO oh.schema_migrations (version) VALUES ('20170911071916');

INSERT INTO oh.schema_migrations (version) VALUES ('20171017162841');

INSERT INTO oh.schema_migrations (version) VALUES ('20171107131744');

INSERT INTO oh.schema_migrations (version) VALUES ('20171127153012');

INSERT INTO oh.schema_migrations (version) VALUES ('20171204073648');

INSERT INTO oh.schema_migrations (version) VALUES ('20171220032437');

INSERT INTO oh.schema_migrations (version) VALUES ('20180109182901');

INSERT INTO oh.schema_migrations (version) VALUES ('20180925181605');

INSERT INTO oh.schema_migrations (version) VALUES ('20181126091803');

INSERT INTO oh.schema_migrations (version) VALUES ('20181220010101');

INSERT INTO oh.schema_migrations (version) VALUES ('20190108060802');

INSERT INTO oh.schema_migrations (version) VALUES ('20190130190953');

INSERT INTO oh.schema_migrations (version) VALUES ('20190221123532');

INSERT INTO oh.schema_migrations (version) VALUES ('20190312150645');

INSERT INTO oh.schema_migrations (version) VALUES ('20200719174850');

INSERT INTO oh.schema_migrations (version) VALUES ('20201130144849');

INSERT INTO oh.schema_migrations (version) VALUES ('20210621143713');

INSERT INTO oh.schema_migrations (version) VALUES ('20220302133936');

INSERT INTO oh.schema_migrations (version) VALUES ('20220718210823');

INSERT INTO oh.schema_migrations (version) VALUES ('20220822144901');

INSERT INTO oh.schema_migrations (version) VALUES ('20220822144949');

INSERT INTO oh.schema_migrations (version) VALUES ('20220913135438');

INSERT INTO oh.schema_migrations (version) VALUES ('20230215030920');

INSERT INTO oh.schema_migrations (version) VALUES ('20230320140846');

INSERT INTO oh.schema_migrations (version) VALUES ('20230801115125');

INSERT INTO oh.schema_migrations (version) VALUES ('21');

INSERT INTO oh.schema_migrations (version) VALUES ('22');

INSERT INTO oh.schema_migrations (version) VALUES ('23');

INSERT INTO oh.schema_migrations (version) VALUES ('24');

INSERT INTO oh.schema_migrations (version) VALUES ('25');

INSERT INTO oh.schema_migrations (version) VALUES ('26');

INSERT INTO oh.schema_migrations (version) VALUES ('27');

INSERT INTO oh.schema_migrations (version) VALUES ('28');

INSERT INTO oh.schema_migrations (version) VALUES ('29');

INSERT INTO oh.schema_migrations (version) VALUES ('3');

INSERT INTO oh.schema_migrations (version) VALUES ('30');

INSERT INTO oh.schema_migrations (version) VALUES ('31');

INSERT INTO oh.schema_migrations (version) VALUES ('32');

INSERT INTO oh.schema_migrations (version) VALUES ('33');

INSERT INTO oh.schema_migrations (version) VALUES ('34');

INSERT INTO oh.schema_migrations (version) VALUES ('35');

INSERT INTO oh.schema_migrations (version) VALUES ('36');

INSERT INTO oh.schema_migrations (version) VALUES ('37');

INSERT INTO oh.schema_migrations (version) VALUES ('38');

INSERT INTO oh.schema_migrations (version) VALUES ('39');

INSERT INTO oh.schema_migrations (version) VALUES ('4');

INSERT INTO oh.schema_migrations (version) VALUES ('40');

INSERT INTO oh.schema_migrations (version) VALUES ('41');

INSERT INTO oh.schema_migrations (version) VALUES ('42');

INSERT INTO oh.schema_migrations (version) VALUES ('43');

INSERT INTO oh.schema_migrations (version) VALUES ('44');

INSERT INTO oh.schema_migrations (version) VALUES ('45');

INSERT INTO oh.schema_migrations (version) VALUES ('46');

INSERT INTO oh.schema_migrations (version) VALUES ('47');

INSERT INTO oh.schema_migrations (version) VALUES ('48');

INSERT INTO oh.schema_migrations (version) VALUES ('49');

INSERT INTO oh.schema_migrations (version) VALUES ('5');

INSERT INTO oh.schema_migrations (version) VALUES ('50');

INSERT INTO oh.schema_migrations (version) VALUES ('51');

INSERT INTO oh.schema_migrations (version) VALUES ('52');

INSERT INTO oh.schema_migrations (version) VALUES ('53');

INSERT INTO oh.schema_migrations (version) VALUES ('54');

INSERT INTO oh.schema_migrations (version) VALUES ('55');

INSERT INTO oh.schema_migrations (version) VALUES ('56');

INSERT INTO oh.schema_migrations (version) VALUES ('57');

INSERT INTO oh.schema_migrations (version) VALUES ('58');

INSERT INTO oh.schema_migrations (version) VALUES ('59');

INSERT INTO oh.schema_migrations (version) VALUES ('6');

INSERT INTO oh.schema_migrations (version) VALUES ('60');

INSERT INTO oh.schema_migrations (version) VALUES ('61');

INSERT INTO oh.schema_migrations (version) VALUES ('62');

INSERT INTO oh.schema_migrations (version) VALUES ('63');

INSERT INTO oh.schema_migrations (version) VALUES ('64');

INSERT INTO oh.schema_migrations (version) VALUES ('65');

INSERT INTO oh.schema_migrations (version) VALUES ('66');

INSERT INTO oh.schema_migrations (version) VALUES ('67');

INSERT INTO oh.schema_migrations (version) VALUES ('68');

INSERT INTO oh.schema_migrations (version) VALUES ('69');

INSERT INTO oh.schema_migrations (version) VALUES ('7');

INSERT INTO oh.schema_migrations (version) VALUES ('70');

INSERT INTO oh.schema_migrations (version) VALUES ('71');

INSERT INTO oh.schema_migrations (version) VALUES ('72');

INSERT INTO oh.schema_migrations (version) VALUES ('73');

INSERT INTO oh.schema_migrations (version) VALUES ('74');

INSERT INTO oh.schema_migrations (version) VALUES ('75');

INSERT INTO oh.schema_migrations (version) VALUES ('76');

INSERT INTO oh.schema_migrations (version) VALUES ('77');

INSERT INTO oh.schema_migrations (version) VALUES ('78');

INSERT INTO oh.schema_migrations (version) VALUES ('79');

INSERT INTO oh.schema_migrations (version) VALUES ('8');

INSERT INTO oh.schema_migrations (version) VALUES ('80');

INSERT INTO oh.schema_migrations (version) VALUES ('81');

INSERT INTO oh.schema_migrations (version) VALUES ('82');

INSERT INTO oh.schema_migrations (version) VALUES ('83');

INSERT INTO oh.schema_migrations (version) VALUES ('84');

INSERT INTO oh.schema_migrations (version) VALUES ('85');

INSERT INTO oh.schema_migrations (version) VALUES ('86');

INSERT INTO oh.schema_migrations (version) VALUES ('87');

INSERT INTO oh.schema_migrations (version) VALUES ('88');

INSERT INTO oh.schema_migrations (version) VALUES ('89');

INSERT INTO oh.schema_migrations (version) VALUES ('9');

INSERT INTO oh.schema_migrations (version) VALUES ('90');

INSERT INTO oh.schema_migrations (version) VALUES ('91');

INSERT INTO oh.schema_migrations (version) VALUES ('92');

INSERT INTO oh.schema_migrations (version) VALUES ('93');

INSERT INTO oh.schema_migrations (version) VALUES ('94');

INSERT INTO oh.schema_migrations (version) VALUES ('95');

INSERT INTO oh.schema_migrations (version) VALUES ('96');

INSERT INTO oh.schema_migrations (version) VALUES ('97');

INSERT INTO oh.schema_migrations (version) VALUES ('98');

INSERT INTO oh.schema_migrations (version) VALUES ('99');

