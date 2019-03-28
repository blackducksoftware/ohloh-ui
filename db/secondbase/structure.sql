--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.8
-- Dumped by pg_dump version 9.6.8

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: account_reports_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.account_reports_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from account_reports_id_seq_view$$;


--
-- Name: accounts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.accounts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from accounts_id_seq_view$$;


--
-- Name: actions_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.actions_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from actions_id_seq_view$$;


--
-- Name: admin_insert_cl_added_stats(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_insert_cl_added_stats() RETURNS jsonb
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
-- Name: admin_insert_cl_added_stats_v2(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_insert_cl_added_stats_v2() RETURNS jsonb
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
-- Name: admin_insert_cl_py_ages_stats(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_insert_cl_py_ages_stats() RETURNS jsonb
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
-- Name: admin_insert_cl_py_ages_stats_v2(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_insert_cl_py_ages_stats_v2() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$

DECLARE
  result jsonb;
BEGIN
WITH codesets AS (SELECT logged_at
FROM code_sets
INNER JOIN code_locations ON code_locations.best_code_set_id = code_sets.id
LEFT OUTER JOIN (SELECT DISTINCT subscriptions.code_location_id FROM subscriptions) sub
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
-- Name: admin_insert_cl_py_by_month_stats(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_insert_cl_py_by_month_stats() RETURNS jsonb
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
-- Name: admin_insert_cl_py_by_month_stats_v2(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_insert_cl_py_by_month_stats_v2() RETURNS jsonb
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
-- Name: admin_insert_cl_total_stats(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_insert_cl_total_stats() RETURNS jsonb
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
-- Name: admin_insert_cl_total_stats_v2(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_insert_cl_total_stats_v2() RETURNS jsonb
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
-- Name: admin_insert_cl_visited_stats(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_insert_cl_visited_stats() RETURNS jsonb
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
-- Name: admin_insert_cl_visited_stats_v2(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_insert_cl_visited_stats_v2() RETURNS jsonb
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
-- Name: admin_select_cl_visited_stats(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_select_cl_visited_stats(interval_span character varying DEFAULT NULL::character varying) RETURNS jsonb
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
-- Name: admin_select_cl_visited_stats_v2(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_select_cl_visited_stats_v2(interval_span character varying DEFAULT NULL::character varying, registration_key character varying DEFAULT NULL::character varying) RETURNS jsonb
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
-- Name: admin_select_kb_cl_visited_stats(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_select_kb_cl_visited_stats(interval_span character varying DEFAULT NULL::character varying) RETURNS jsonb
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
-- Name: aliases_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.aliases_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from aliases_id_seq_view$$;


--
-- Name: analyses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.analyses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from analyses_id_seq_view$$;


--
-- Name: analysis_aliases_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.analysis_aliases_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from analysis_aliases_id_seq_view$$;


--
-- Name: analysis_sloc_sets_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.analysis_sloc_sets_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from analysis_sloc_sets_id_seq_view$$;


--
-- Name: analysis_summaries_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.analysis_summaries_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from analysis_summaries_id_seq_view$$;


--
-- Name: api_keys_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.api_keys_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from api_keys_id_seq_view$$;


--
-- Name: attachments_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.attachments_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from attachments_id_seq_view$$;


--
-- Name: authorizations_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.authorizations_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from authorizations_id_seq_view$$;


--
-- Name: clumps_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.clumps_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from clumps_id_seq_view$$;


--
-- Name: code_location_tarballs_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.code_location_tarballs_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from code_location_tarballs_id_seq_view$$;


--
-- Name: code_sets_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.code_sets_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from code_sets_id_seq_view$$;


--
-- Name: commit_flags_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.commit_flags_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from commit_flags_id_seq_view$$;


--
-- Name: delete_old_code_sets(smallint, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_old_code_sets(smallint, boolean) RETURNS jsonb
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
         IF num_limit < 1 OR num_limit > 1000 THEN
         num_limit = 1000 ;
         END IF ;

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
                 < COALESCE(cs_best.logged_at, cs_best.updated_on) Limit num_limit ;

         GET DIAGNOSTICS num_selected = row_count;
         RAISE NOTICE 'Selected %s code_sets', num_selected ;
         INSERT INTO temp_messages VALUES
           (FORMAT('Selected %s code_sets', num_selected))  ;

         DELETE FROM temp_code_sets
         WHERE id IN
           (SELECT tcs.id
              FROM temp_code_sets tcs
              INNER JOIN jobs j ON tcs.id = j.code_set_id
             WHERE j.status <> 5) ;

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
-- Name: deleted_accounts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.deleted_accounts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from deleted_accounts_id_seq_view$$;


--
-- Name: diff_licenses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.diff_licenses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from diff_licenses_id_seq_view$$;


--
-- Name: duplicates_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.duplicates_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from duplicates_id_seq_view$$;


--
-- Name: edits_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.edits_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from edits_id_seq_view$$;


--
-- Name: email_addresses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.email_addresses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from email_addresses_id_seq_view$$;


--
-- Name: enlistments_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enlistments_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from enlistments_id_seq_view$$;


--
-- Name: event_subscription_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.event_subscription_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from event_subscription_id_seq_view$$;


--
-- Name: exhibits_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.exhibits_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from exhibits_id_seq_view$$;


--
-- Name: factoids_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.factoids_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from factoids_id_seq_view$$;


--
-- Name: feedbacks_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.feedbacks_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from feedbacks_id_seq_view$$;


--
-- Name: fisbot_events_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fisbot_events_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from fisbot_events_id_seq_view$$;


--
-- Name: follows_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.follows_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from follows_id_seq_view$$;


--
-- Name: forums_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.forums_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from forums_id_seq_view$$;


--
-- Name: helpfuls_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.helpfuls_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from helpfuls_id_seq_view$$;


--
-- Name: invites_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.invites_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from invites_id_seq_view$$;


--
-- Name: knowledge_base_statuses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.knowledge_base_statuses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from knowledge_base_statuses_id_seq_view$$;


--
-- Name: kudo_scores_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.kudo_scores_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from kudo_scores_id_seq_view$$;


--
-- Name: kudos_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.kudos_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from kudos_id_seq_view$$;


--
-- Name: language_experiences_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.language_experiences_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from language_experiences_id_seq_view$$;


--
-- Name: language_facts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.language_facts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from language_facts_id_seq_view$$;


--
-- Name: languages_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.languages_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from languages_id_seq_view$$;


--
-- Name: license_facts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.license_facts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from license_facts_id_seq_view$$;


--
-- Name: licenses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.licenses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from licenses_id_seq_view$$;


--
-- Name: link_categories_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.link_categories_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from link_categories_id_seq_view$$;


--
-- Name: links_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.links_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from links_id_seq_view$$;


--
-- Name: load_averages_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.load_averages_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from load_averages_id_seq_view$$;


--
-- Name: manages_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.manages_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from manages_id_seq_view$$;


--
-- Name: markups_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.markups_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from markups_id_seq_view$$;


--
-- Name: message_account_tags_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.message_account_tags_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from message_account_tags_id_seq_view$$;


--
-- Name: message_project_tags_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.message_project_tags_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from message_project_tags_id_seq_view$$;


--
-- Name: messages_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.messages_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from messages_id_seq_view$$;


--
-- Name: moderatorships_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.moderatorships_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from moderatorships_id_seq_view$$;


--
-- Name: monitorships_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.monitorships_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from monitorships_id_seq_view$$;


--
-- Name: monthly_commit_histories_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.monthly_commit_histories_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from monthly_commit_histories_id_seq_view$$;


--
-- Name: name_facts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.name_facts_id_seq_view() RETURNS bigint
    LANGUAGE sql
    AS $$select id from name_facts_id_seq_view$$;


--
-- Name: name_language_facts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.name_language_facts_id_seq_view() RETURNS bigint
    LANGUAGE sql
    AS $$select id from name_language_facts_id_seq_view$$;


--
-- Name: names_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.names_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from names_id_seq_view$$;


--
-- Name: oauth_access_grants_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.oauth_access_grants_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from oauth_access_grants_id_seq_view$$;


--
-- Name: oauth_access_tokens_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.oauth_access_tokens_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from oauth_access_tokens_id_seq_view$$;


--
-- Name: oauth_applications_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.oauth_applications_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from oauth_applications_id_seq_view$$;


--
-- Name: oauth_nonces_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.oauth_nonces_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from oauth_nonces_id_seq_view$$;


--
-- Name: old_edits_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.old_edits_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from old_edits_id_seq_view$$;


--
-- Name: org_stats_by_sectors_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.org_stats_by_sectors_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from org_stats_by_sectors_id_seq_view$$;


--
-- Name: org_thirty_day_activities_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.org_thirty_day_activities_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from org_thirty_day_activities_id_seq_view$$;


--
-- Name: organizations_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.organizations_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from organizations_id_seq_view$$;


--
-- Name: pages_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pages_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from pages_id_seq_view$$;


--
-- Name: permissions_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.permissions_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from permissions_id_seq_view$$;


--
-- Name: positions_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.positions_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from positions_id_seq_view$$;


--
-- Name: posts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.posts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from posts_id_seq_view$$;


--
-- Name: profiles_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.profiles_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from profiles_id_seq_view$$;


--
-- Name: project_badges_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.project_badges_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from project_badges_id_seq_view$$;


--
-- Name: project_events_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.project_events_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from project_events_id_seq_view$$;


--
-- Name: project_experiences_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.project_experiences_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from project_experiences_id_seq_view$$;


--
-- Name: project_licenses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.project_licenses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from project_licenses_id_seq_view$$;


--
-- Name: project_reports_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.project_reports_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from project_reports_id_seq_view$$;


--
-- Name: project_security_sets_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.project_security_sets_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from project_security_sets_id_seq_view$$;


--
-- Name: project_vulnerability_reports_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.project_vulnerability_reports_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from project_vulnerability_reports_id_seq_view$$;


--
-- Name: projects_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.projects_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from projects_id_seq_view$$;


--
-- Name: ratings_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ratings_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from ratings_id_seq_view$$;


--
-- Name: recently_active_accounts_cache_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recently_active_accounts_cache_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from recently_active_accounts_cache_id_seq_view$$;


--
-- Name: recommend_entries_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recommend_entries_id_seq_view() RETURNS bigint
    LANGUAGE sql
    AS $$select id from recommend_entries_id_seq_view$$;


--
-- Name: recommendations_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recommendations_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from recommendations_id_seq_view$$;


--
-- Name: releases_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.releases_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from releases_id_seq_view$$;


--
-- Name: reports_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reports_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from reports_id_seq_view$$;


--
-- Name: reverification_trackers_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reverification_trackers_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from reverification_trackers_id_seq_view$$;


--
-- Name: reviews_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reviews_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from reviews_id_seq_view$$;


--
-- Name: rss_articles_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rss_articles_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from rss_articles_id_seq_view$$;


--
-- Name: rss_feeds_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rss_feeds_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from rss_feeds_id_seq_view$$;


--
-- Name: rss_subscriptions_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rss_subscriptions_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from rss_subscriptions_id_seq_view$$;


--
-- Name: sessions_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sessions_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from sessions_id_seq_view$$;


--
-- Name: settings_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.settings_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from settings_id_seq_view$$;


--
-- Name: size_facts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.size_facts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from size_facts_id_seq_view$$;


--
-- Name: slave_logs_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.slave_logs_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from slave_logs_id_seq_view$$;


--
-- Name: slave_permissions_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.slave_permissions_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from slave_permissions_id_seq_view$$;


--
-- Name: sloc_sets_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sloc_sets_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from sloc_sets_id_seq_view$$;


--
-- Name: stack_entries_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.stack_entries_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from stack_entries_id_seq_view$$;


--
-- Name: stack_ignores_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.stack_ignores_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from stack_ignores_id_seq_view$$;


--
-- Name: stacks_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.stacks_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from stacks_id_seq_view$$;


--
-- Name: successful_accounts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.successful_accounts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from successful_accounts_id_seq_view$$;


--
-- Name: taggings_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.taggings_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from taggings_id_seq_view$$;


--
-- Name: tags_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tags_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from tags_id_seq_view$$;


--
-- Name: thirty_day_summaries_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.thirty_day_summaries_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from thirty_day_summaries_id_seq_view$$;


--
-- Name: tools_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tools_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from tools_id_seq_view$$;


--
-- Name: topics_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.topics_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from topics_id_seq_view$$;


--
-- Name: verifications_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.verifications_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from verifications_id_seq_view$$;


--
-- Name: vita_analyses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vita_analyses_id_seq_view() RETURNS bigint
    LANGUAGE sql
    AS $$select id from vita_analyses_id_seq_view$$;


--
-- Name: vitae_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vitae_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from vitae_id_seq_view$$;


--
-- Name: vulnerabilities_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vulnerabilities_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from vulnerabilities_id_seq_view$$;


--
-- Name: default; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION public."default" (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR asciiword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR word WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR hword_part WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR hword_asciipart WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR asciihword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR hword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public."default"
    ADD MAPPING FOR uint WITH simple;


--
-- Name: pg; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION public.pg (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR asciiword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR word WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR hword_part WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR hword_asciipart WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR asciihword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR hword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pg
    ADD MAPPING FOR uint WITH simple;


--
-- Name: ohloh; Type: SERVER; Schema: -; Owner: -
--

CREATE SERVER ohloh FOREIGN DATA WRAPPER postgres_fdw OPTIONS (
    dbname 'openhub_test',
    host 'localhost',
    port '5432'
);


--
-- Name: USER MAPPING fis_user SERVER ohloh; Type: USER MAPPING; Schema: -; Owner: -
--

CREATE USER MAPPING FOR fis_user SERVER ohloh OPTIONS (
    password 'openhub_password',
    "user" 'openhub_user'
);


SET default_tablespace = '';

--
-- Name: account_reports; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.account_reports (
    id integer DEFAULT public.account_reports_id_seq_view() NOT NULL,
    account_id integer NOT NULL,
    report_id integer NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'account_reports'
);
ALTER FOREIGN TABLE public.account_reports ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.account_reports ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.account_reports ALTER COLUMN report_id OPTIONS (
    column_name 'report_id'
);


--
-- Name: account_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_reports_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.account_reports_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'account_reports_id_seq_view'
);
ALTER FOREIGN TABLE public.account_reports_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: accounts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.accounts (
    id integer DEFAULT public.accounts_id_seq_view() NOT NULL,
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
    organization_name text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'accounts'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN login OPTIONS (
    column_name 'login'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN email OPTIONS (
    column_name 'email'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN encrypted_password OPTIONS (
    column_name 'encrypted_password'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN salt OPTIONS (
    column_name 'salt'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN activation_code OPTIONS (
    column_name 'activation_code'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN activated_at OPTIONS (
    column_name 'activated_at'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN remember_token OPTIONS (
    column_name 'remember_token'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN remember_token_expires_at OPTIONS (
    column_name 'remember_token_expires_at'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN level OPTIONS (
    column_name 'level'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN posts_count OPTIONS (
    column_name 'posts_count'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN last_seen_at OPTIONS (
    column_name 'last_seen_at'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN country_code OPTIONS (
    column_name 'country_code'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN location OPTIONS (
    column_name 'location'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN latitude OPTIONS (
    column_name 'latitude'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN longitude OPTIONS (
    column_name 'longitude'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN best_vita_id OPTIONS (
    column_name 'best_vita_id'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN url OPTIONS (
    column_name 'url'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN about_markup_id OPTIONS (
    column_name 'about_markup_id'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN hide_experience OPTIONS (
    column_name 'hide_experience'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN email_master OPTIONS (
    column_name 'email_master'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN email_posts OPTIONS (
    column_name 'email_posts'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN email_kudos OPTIONS (
    column_name 'email_kudos'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN email_md5 OPTIONS (
    column_name 'email_md5'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN email_opportunities_visited OPTIONS (
    column_name 'email_opportunities_visited'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN activation_resent_at OPTIONS (
    column_name 'activation_resent_at'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN akas OPTIONS (
    column_name 'akas'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN email_new_followers OPTIONS (
    column_name 'email_new_followers'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN last_seen_ip OPTIONS (
    column_name 'last_seen_ip'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN twitter_account OPTIONS (
    column_name 'twitter_account'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN confirmation_token OPTIONS (
    column_name 'confirmation_token'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN affiliation_type OPTIONS (
    column_name 'affiliation_type'
);
ALTER FOREIGN TABLE public.accounts ALTER COLUMN organization_name OPTIONS (
    column_name 'organization_name'
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.accounts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'accounts_id_seq_view'
);
ALTER FOREIGN TABLE public.accounts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: actions; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.actions (
    id integer DEFAULT public.actions_id_seq_view() NOT NULL,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    status text,
    stack_project_id integer,
    claim_person_id bigint
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'actions'
);
ALTER FOREIGN TABLE public.actions ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.actions ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.actions ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.actions ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.actions ALTER COLUMN status OPTIONS (
    column_name 'status'
);
ALTER FOREIGN TABLE public.actions ALTER COLUMN stack_project_id OPTIONS (
    column_name 'stack_project_id'
);
ALTER FOREIGN TABLE public.actions ALTER COLUMN claim_person_id OPTIONS (
    column_name 'claim_person_id'
);


--
-- Name: actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actions_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.actions_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'actions_id_seq_view'
);
ALTER FOREIGN TABLE public.actions_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: activity_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_facts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.activity_facts (
    month date,
    language_id integer,
    code_added integer DEFAULT 0,
    code_removed integer DEFAULT 0,
    comments_added integer DEFAULT 0,
    comments_removed integer DEFAULT 0,
    blanks_added integer DEFAULT 0,
    blanks_removed integer DEFAULT 0,
    name_id integer NOT NULL,
    id bigint DEFAULT nextval('public.activity_facts_id_seq'::regclass) NOT NULL,
    analysis_id integer NOT NULL,
    commits integer DEFAULT 0,
    on_trunk boolean DEFAULT true
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'activity_facts'
);
ALTER FOREIGN TABLE public.activity_facts ALTER COLUMN month OPTIONS (
    column_name 'month'
);
ALTER FOREIGN TABLE public.activity_facts ALTER COLUMN language_id OPTIONS (
    column_name 'language_id'
);
ALTER FOREIGN TABLE public.activity_facts ALTER COLUMN code_added OPTIONS (
    column_name 'code_added'
);
ALTER FOREIGN TABLE public.activity_facts ALTER COLUMN code_removed OPTIONS (
    column_name 'code_removed'
);
ALTER FOREIGN TABLE public.activity_facts ALTER COLUMN comments_added OPTIONS (
    column_name 'comments_added'
);
ALTER FOREIGN TABLE public.activity_facts ALTER COLUMN comments_removed OPTIONS (
    column_name 'comments_removed'
);
ALTER FOREIGN TABLE public.activity_facts ALTER COLUMN blanks_added OPTIONS (
    column_name 'blanks_added'
);
ALTER FOREIGN TABLE public.activity_facts ALTER COLUMN blanks_removed OPTIONS (
    column_name 'blanks_removed'
);
ALTER FOREIGN TABLE public.activity_facts ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE public.activity_facts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.activity_facts ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE public.activity_facts ALTER COLUMN commits OPTIONS (
    column_name 'commits'
);
ALTER FOREIGN TABLE public.activity_facts ALTER COLUMN on_trunk OPTIONS (
    column_name 'on_trunk'
);


--
-- Name: activity_facts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.activity_facts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'activity_facts_id_seq_view'
);
ALTER FOREIGN TABLE public.activity_facts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


SET default_with_oids = false;

--
-- Name: admin_dashboard_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_dashboard_stats (
    id integer NOT NULL,
    stat_type character varying,
    data jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_dashboard_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_dashboard_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_dashboard_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_dashboard_stats_id_seq OWNED BY public.admin_dashboard_stats.id;


--
-- Name: aliases; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.aliases (
    id integer DEFAULT public.aliases_id_seq_view() NOT NULL,
    project_id integer NOT NULL,
    commit_name_id integer NOT NULL,
    preferred_name_id integer NOT NULL,
    deleted boolean DEFAULT false NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'aliases'
);
ALTER FOREIGN TABLE public.aliases ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.aliases ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.aliases ALTER COLUMN commit_name_id OPTIONS (
    column_name 'commit_name_id'
);
ALTER FOREIGN TABLE public.aliases ALTER COLUMN preferred_name_id OPTIONS (
    column_name 'preferred_name_id'
);
ALTER FOREIGN TABLE public.aliases ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
);


--
-- Name: aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aliases_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.aliases_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'aliases_id_seq_view'
);
ALTER FOREIGN TABLE public.aliases_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: all_months; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.all_months (
    month timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'all_months'
);
ALTER FOREIGN TABLE public.all_months ALTER COLUMN month OPTIONS (
    column_name 'month'
);


--
-- Name: analyses; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.analyses (
    id integer DEFAULT public.analyses_id_seq_view() NOT NULL,
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
    activity_score integer,
    hotness_score double precision
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'analyses'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN as_of OPTIONS (
    column_name 'as_of'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN updated_on OPTIONS (
    column_name 'updated_on'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN main_language_id OPTIONS (
    column_name 'main_language_id'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN relative_comments OPTIONS (
    column_name 'relative_comments'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN logic_total OPTIONS (
    column_name 'logic_total'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN markup_total OPTIONS (
    column_name 'markup_total'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN headcount OPTIONS (
    column_name 'headcount'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN min_month OPTIONS (
    column_name 'min_month'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN max_month OPTIONS (
    column_name 'max_month'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN oldest_code_set_time OPTIONS (
    column_name 'oldest_code_set_time'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN committers_all_time OPTIONS (
    column_name 'committers_all_time'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN first_commit_time OPTIONS (
    column_name 'first_commit_time'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN last_commit_time OPTIONS (
    column_name 'last_commit_time'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN commit_count OPTIONS (
    column_name 'commit_count'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN build_total OPTIONS (
    column_name 'build_total'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN activity_score OPTIONS (
    column_name 'activity_score'
);
ALTER FOREIGN TABLE public.analyses ALTER COLUMN hotness_score OPTIONS (
    column_name 'hotness_score'
);


--
-- Name: analyses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.analyses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analyses_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.analyses_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'analyses_id_seq_view'
);
ALTER FOREIGN TABLE public.analyses_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: analysis_aliases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.analysis_aliases (
    id bigint NOT NULL,
    analysis_id integer NOT NULL,
    commit_name_id integer NOT NULL,
    preferred_name_id integer NOT NULL
);


--
-- Name: analysis_aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.analysis_aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analysis_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.analysis_aliases_id_seq OWNED BY public.analysis_aliases.id;


--
-- Name: analysis_aliases_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.analysis_aliases_id_seq_view AS
 SELECT nextval('public.analysis_aliases_id_seq'::regclass) AS id;


--
-- Name: analysis_sloc_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.analysis_sloc_sets (
    id integer NOT NULL,
    analysis_id integer NOT NULL,
    sloc_set_id integer NOT NULL,
    as_of integer,
    code_set_time timestamp without time zone,
    ignore text,
    ignored_fyle_count integer
);


--
-- Name: analysis_sloc_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.analysis_sloc_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analysis_sloc_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.analysis_sloc_sets_id_seq OWNED BY public.analysis_sloc_sets.id;


--
-- Name: analysis_sloc_sets_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.analysis_sloc_sets_id_seq_view AS
 SELECT (nextval('public.analysis_sloc_sets_id_seq'::regclass))::integer AS id;


--
-- Name: analysis_summaries; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.analysis_summaries (
    id integer DEFAULT public.analysis_summaries_id_seq_view() NOT NULL,
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'analysis_summaries'
);
ALTER FOREIGN TABLE public.analysis_summaries ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.analysis_summaries ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE public.analysis_summaries ALTER COLUMN files_modified OPTIONS (
    column_name 'files_modified'
);
ALTER FOREIGN TABLE public.analysis_summaries ALTER COLUMN lines_added OPTIONS (
    column_name 'lines_added'
);
ALTER FOREIGN TABLE public.analysis_summaries ALTER COLUMN lines_removed OPTIONS (
    column_name 'lines_removed'
);
ALTER FOREIGN TABLE public.analysis_summaries ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE public.analysis_summaries ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.analysis_summaries ALTER COLUMN recent_contributors OPTIONS (
    column_name 'recent_contributors'
);
ALTER FOREIGN TABLE public.analysis_summaries ALTER COLUMN new_contributors_count OPTIONS (
    column_name 'new_contributors_count'
);
ALTER FOREIGN TABLE public.analysis_summaries ALTER COLUMN affiliated_committers_count OPTIONS (
    column_name 'affiliated_committers_count'
);
ALTER FOREIGN TABLE public.analysis_summaries ALTER COLUMN affiliated_commits_count OPTIONS (
    column_name 'affiliated_commits_count'
);
ALTER FOREIGN TABLE public.analysis_summaries ALTER COLUMN outside_committers_count OPTIONS (
    column_name 'outside_committers_count'
);
ALTER FOREIGN TABLE public.analysis_summaries ALTER COLUMN outside_commits_count OPTIONS (
    column_name 'outside_commits_count'
);


--
-- Name: analysis_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.analysis_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analysis_summaries_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.analysis_summaries_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'analysis_summaries_id_seq_view'
);
ALTER FOREIGN TABLE public.analysis_summaries_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: api_keys; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.api_keys (
    id integer DEFAULT public.api_keys_id_seq_view() NOT NULL,
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'api_keys'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN key OPTIONS (
    column_name 'key'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN daily_count OPTIONS (
    column_name 'daily_count'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN daily_limit OPTIONS (
    column_name 'daily_limit'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN day_began_at OPTIONS (
    column_name 'day_began_at'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN last_access_at OPTIONS (
    column_name 'last_access_at'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN total_count OPTIONS (
    column_name 'total_count'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN status OPTIONS (
    column_name 'status'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN url OPTIONS (
    column_name 'url'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN support_url OPTIONS (
    column_name 'support_url'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN callback_url OPTIONS (
    column_name 'callback_url'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN secret OPTIONS (
    column_name 'secret'
);
ALTER FOREIGN TABLE public.api_keys ALTER COLUMN oauth_application_id OPTIONS (
    column_name 'oauth_application_id'
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.api_keys_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'api_keys_id_seq_view'
);
ALTER FOREIGN TABLE public.api_keys_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: attachments; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.attachments (
    id integer DEFAULT public.attachments_id_seq_view() NOT NULL,
    parent_id integer,
    type text NOT NULL,
    thumbnail text,
    filename text NOT NULL,
    content_type text,
    size integer,
    width integer,
    height integer,
    is_default boolean DEFAULT false NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'attachments'
);
ALTER FOREIGN TABLE public.attachments ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.attachments ALTER COLUMN parent_id OPTIONS (
    column_name 'parent_id'
);
ALTER FOREIGN TABLE public.attachments ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE public.attachments ALTER COLUMN thumbnail OPTIONS (
    column_name 'thumbnail'
);
ALTER FOREIGN TABLE public.attachments ALTER COLUMN filename OPTIONS (
    column_name 'filename'
);
ALTER FOREIGN TABLE public.attachments ALTER COLUMN content_type OPTIONS (
    column_name 'content_type'
);
ALTER FOREIGN TABLE public.attachments ALTER COLUMN size OPTIONS (
    column_name 'size'
);
ALTER FOREIGN TABLE public.attachments ALTER COLUMN width OPTIONS (
    column_name 'width'
);
ALTER FOREIGN TABLE public.attachments ALTER COLUMN height OPTIONS (
    column_name 'height'
);
ALTER FOREIGN TABLE public.attachments ALTER COLUMN is_default OPTIONS (
    column_name 'is_default'
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.attachments_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'attachments_id_seq_view'
);
ALTER FOREIGN TABLE public.attachments_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: authorizations; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.authorizations (
    id integer DEFAULT public.authorizations_id_seq_view() NOT NULL,
    account_id integer,
    type text,
    api_key_id integer NOT NULL,
    token text NOT NULL,
    secret text,
    authorized_at timestamp without time zone,
    invalidated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'authorizations'
);
ALTER FOREIGN TABLE public.authorizations ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.authorizations ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.authorizations ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE public.authorizations ALTER COLUMN api_key_id OPTIONS (
    column_name 'api_key_id'
);
ALTER FOREIGN TABLE public.authorizations ALTER COLUMN token OPTIONS (
    column_name 'token'
);
ALTER FOREIGN TABLE public.authorizations ALTER COLUMN secret OPTIONS (
    column_name 'secret'
);
ALTER FOREIGN TABLE public.authorizations ALTER COLUMN authorized_at OPTIONS (
    column_name 'authorized_at'
);
ALTER FOREIGN TABLE public.authorizations ALTER COLUMN invalidated_at OPTIONS (
    column_name 'invalidated_at'
);
ALTER FOREIGN TABLE public.authorizations ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.authorizations ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: authorizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authorizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authorizations_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.authorizations_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'authorizations_id_seq_view'
);
ALTER FOREIGN TABLE public.authorizations_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: claims_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.claims_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'claims_id_seq_view'
);
ALTER FOREIGN TABLE public.claims_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: clumps; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.clumps (
    id integer DEFAULT public.clumps_id_seq_view() NOT NULL,
    slave_id integer,
    code_set_id integer,
    updated_at timestamp without time zone,
    type text NOT NULL,
    fetched_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'clumps'
);
ALTER FOREIGN TABLE public.clumps ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.clumps ALTER COLUMN slave_id OPTIONS (
    column_name 'slave_id'
);
ALTER FOREIGN TABLE public.clumps ALTER COLUMN code_set_id OPTIONS (
    column_name 'code_set_id'
);
ALTER FOREIGN TABLE public.clumps ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.clumps ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE public.clumps ALTER COLUMN fetched_at OPTIONS (
    column_name 'fetched_at'
);


--
-- Name: clumps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clumps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clumps_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.clumps_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'clumps_id_seq_view'
);
ALTER FOREIGN TABLE public.clumps_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: code_location_job_feeders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.code_location_job_feeders (
    id integer NOT NULL,
    code_location_id integer,
    url text,
    status integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: code_location_job_feeders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.code_location_job_feeders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_location_job_feeders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.code_location_job_feeders_id_seq OWNED BY public.code_location_job_feeders.id;


--
-- Name: code_location_tarballs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.code_location_tarballs (
    id integer NOT NULL,
    code_location_id integer,
    reference text,
    filepath text,
    status integer DEFAULT 0,
    created_at timestamp without time zone,
    type text
);


--
-- Name: code_location_tarballs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.code_location_tarballs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_location_tarballs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.code_location_tarballs_id_seq OWNED BY public.code_location_tarballs.id;


--
-- Name: code_location_tarballs_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.code_location_tarballs_id_seq_view AS
 SELECT (nextval('public.code_location_tarballs_id_seq'::regclass))::integer AS id;


--
-- Name: code_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.code_locations (
    id integer NOT NULL,
    repository_id integer,
    module_branch_name text,
    best_code_set_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    update_interval integer DEFAULT 3600,
    best_repository_directory_id integer,
    do_not_fetch boolean DEFAULT false,
    last_job_id integer
);


--
-- Name: code_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.code_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.code_locations_id_seq OWNED BY public.code_locations.id;


--
-- Name: code_locations_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.code_locations_id_seq_view AS
 SELECT (nextval('public.code_locations_id_seq'::regclass))::integer AS id;


--
-- Name: code_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.code_sets (
    id integer NOT NULL,
    updated_on timestamp without time zone,
    best_sloc_set_id integer,
    as_of integer,
    logged_at timestamp without time zone,
    clump_count integer DEFAULT 0,
    fetched_at timestamp without time zone,
    code_location_id integer
);


--
-- Name: code_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.code_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.code_sets_id_seq OWNED BY public.code_sets.id;


--
-- Name: code_sets_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.code_sets_id_seq_view AS
 SELECT (nextval('public.code_sets_id_seq'::regclass))::integer AS id;


--
-- Name: positions; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.positions (
    id integer DEFAULT public.positions_id_seq_view() NOT NULL,
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'positions'
);
ALTER FOREIGN TABLE public.positions ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.positions ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.positions ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE public.positions ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.positions ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.positions ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE public.positions ALTER COLUMN organization_name OPTIONS (
    column_name 'organization_name'
);
ALTER FOREIGN TABLE public.positions ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE public.positions ALTER COLUMN start_date OPTIONS (
    column_name 'start_date'
);
ALTER FOREIGN TABLE public.positions ALTER COLUMN stop_date OPTIONS (
    column_name 'stop_date'
);
ALTER FOREIGN TABLE public.positions ALTER COLUMN ongoing OPTIONS (
    column_name 'ongoing'
);
ALTER FOREIGN TABLE public.positions ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);
ALTER FOREIGN TABLE public.positions ALTER COLUMN affiliation_type OPTIONS (
    column_name 'affiliation_type'
);


--
-- Name: projects; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.projects (
    id integer DEFAULT public.projects_id_seq_view() NOT NULL,
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
    best_project_security_set_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'projects'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN comments OPTIONS (
    column_name 'comments'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN best_analysis_id OPTIONS (
    column_name 'best_analysis_id'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN old_name OPTIONS (
    column_name 'old_name'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN missing_source OPTIONS (
    column_name 'missing_source'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN logo_id OPTIONS (
    column_name 'logo_id'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN vanity_url OPTIONS (
    column_name 'vanity_url'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN downloadable OPTIONS (
    column_name 'downloadable'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN scraped OPTIONS (
    column_name 'scraped'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN vector OPTIONS (
    column_name 'vector'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN popularity_factor OPTIONS (
    column_name 'popularity_factor'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN user_count OPTIONS (
    column_name 'user_count'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN rating_average OPTIONS (
    column_name 'rating_average'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN forge_id OPTIONS (
    column_name 'forge_id'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN name_at_forge OPTIONS (
    column_name 'name_at_forge'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN owner_at_forge OPTIONS (
    column_name 'owner_at_forge'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN active_committers OPTIONS (
    column_name 'active_committers'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN kb_id OPTIONS (
    column_name 'kb_id'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN activity_level_index OPTIONS (
    column_name 'activity_level_index'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN uuid OPTIONS (
    column_name 'uuid'
);
ALTER FOREIGN TABLE public.projects ALTER COLUMN best_project_security_set_id OPTIONS (
    column_name 'best_project_security_set_id'
);


--
-- Name: sloc_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sloc_sets (
    id integer NOT NULL,
    code_set_id integer NOT NULL,
    updated_on timestamp without time zone,
    as_of integer,
    code_set_time timestamp without time zone
);


--
-- Name: commit_contributors; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.commit_contributors AS
 SELECT analysis_aliases.commit_name_id AS id,
    sloc_sets.code_set_id,
    analysis_aliases.commit_name_id AS name_id,
    analysis_sloc_sets.analysis_id,
    projects.id AS project_id,
    positions.id AS position_id,
    positions.account_id,
        CASE
            WHEN (positions.account_id IS NULL) THEN ((((projects.id)::bigint << 32) + (analysis_aliases.preferred_name_id)::bigint) + (B'10000000000000000000000000000000'::"bit")::bigint)
            ELSE (((projects.id)::bigint << 32) + (positions.account_id)::bigint)
        END AS contribution_id,
        CASE
            WHEN (positions.account_id IS NULL) THEN ((((projects.id)::bigint << 32) + (analysis_aliases.preferred_name_id)::bigint) + (B'10000000000000000000000000000000'::"bit")::bigint)
            ELSE (positions.account_id)::bigint
        END AS person_id
   FROM ((((public.analysis_sloc_sets
     JOIN public.sloc_sets ON ((analysis_sloc_sets.sloc_set_id = sloc_sets.id)))
     JOIN public.projects ON ((analysis_sloc_sets.analysis_id = projects.best_analysis_id)))
     JOIN public.analysis_aliases ON ((analysis_aliases.analysis_id = analysis_sloc_sets.analysis_id)))
     LEFT JOIN public.positions ON (((positions.project_id = projects.id) AND (positions.name_id = analysis_aliases.preferred_name_id))));


--
-- Name: commit_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commit_flags (
    id integer NOT NULL,
    sloc_set_id integer NOT NULL,
    commit_id integer NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type text NOT NULL,
    data text
);


--
-- Name: commit_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.commit_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commit_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.commit_flags_id_seq OWNED BY public.commit_flags.id;


--
-- Name: commit_flags_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.commit_flags_id_seq_view AS
 SELECT (nextval('public.commit_flags_id_seq'::regclass))::integer AS id;


--
-- Name: commit_spark_analysis_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.commit_spark_analysis_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commits (
    id bigint NOT NULL,
    sha1 text,
    "time" timestamp without time zone NOT NULL,
    comment text,
    code_set_id integer NOT NULL,
    name_id integer NOT NULL,
    "position" integer,
    on_trunk boolean DEFAULT true,
    email_address_id integer
);


--
-- Name: commits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.commits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.commits_id_seq OWNED BY public.commits.id;


--
-- Name: commits_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.commits_id_seq_view AS
 SELECT nextval('public.commits_id_seq'::regclass) AS id;


--
-- Name: contributions; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.contributions (
    id bigint,
    person_id bigint,
    project_id integer,
    name_fact_id integer,
    position_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'contributions'
);
ALTER FOREIGN TABLE public.contributions ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.contributions ALTER COLUMN person_id OPTIONS (
    column_name 'person_id'
);
ALTER FOREIGN TABLE public.contributions ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.contributions ALTER COLUMN name_fact_id OPTIONS (
    column_name 'name_fact_id'
);
ALTER FOREIGN TABLE public.contributions ALTER COLUMN position_id OPTIONS (
    column_name 'position_id'
);


--
-- Name: contributions2; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.contributions2 (
    id bigint,
    name_fact_id integer,
    position_id integer,
    person_id bigint,
    project_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'contributions2'
);
ALTER FOREIGN TABLE public.contributions2 ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.contributions2 ALTER COLUMN name_fact_id OPTIONS (
    column_name 'name_fact_id'
);
ALTER FOREIGN TABLE public.contributions2 ALTER COLUMN position_id OPTIONS (
    column_name 'position_id'
);
ALTER FOREIGN TABLE public.contributions2 ALTER COLUMN person_id OPTIONS (
    column_name 'person_id'
);
ALTER FOREIGN TABLE public.contributions2 ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);


--
-- Name: countries; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.countries (
    country_code text,
    continent_code text,
    name text,
    region text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'countries'
);
ALTER FOREIGN TABLE public.countries ALTER COLUMN country_code OPTIONS (
    column_name 'country_code'
);
ALTER FOREIGN TABLE public.countries ALTER COLUMN continent_code OPTIONS (
    column_name 'continent_code'
);
ALTER FOREIGN TABLE public.countries ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE public.countries ALTER COLUMN region OPTIONS (
    column_name 'region'
);


--
-- Name: deleted_accounts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.deleted_accounts (
    id integer DEFAULT public.deleted_accounts_id_seq_view() NOT NULL,
    login text NOT NULL,
    email text NOT NULL,
    organization_id integer,
    claimed_project_ids integer[] DEFAULT '{}'::integer[],
    reasons integer[] DEFAULT '{}'::integer[],
    reason_other text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'deleted_accounts'
);
ALTER FOREIGN TABLE public.deleted_accounts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.deleted_accounts ALTER COLUMN login OPTIONS (
    column_name 'login'
);
ALTER FOREIGN TABLE public.deleted_accounts ALTER COLUMN email OPTIONS (
    column_name 'email'
);
ALTER FOREIGN TABLE public.deleted_accounts ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);
ALTER FOREIGN TABLE public.deleted_accounts ALTER COLUMN claimed_project_ids OPTIONS (
    column_name 'claimed_project_ids'
);
ALTER FOREIGN TABLE public.deleted_accounts ALTER COLUMN reasons OPTIONS (
    column_name 'reasons'
);
ALTER FOREIGN TABLE public.deleted_accounts ALTER COLUMN reason_other OPTIONS (
    column_name 'reason_other'
);
ALTER FOREIGN TABLE public.deleted_accounts ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.deleted_accounts ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: deleted_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deleted_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deleted_accounts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.deleted_accounts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'deleted_accounts_id_seq_view'
);
ALTER FOREIGN TABLE public.deleted_accounts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: diff_licenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.diff_licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: diff_licenses_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.diff_licenses_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'diff_licenses_id_seq_view'
);
ALTER FOREIGN TABLE public.diff_licenses_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: diffs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.diffs (
    id bigint NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id integer,
    fyle_id integer,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: diffs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.diffs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: diffs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.diffs_id_seq OWNED BY public.diffs.id;


--
-- Name: diffs_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.diffs_id_seq_view AS
 SELECT (nextval('public.diffs_id_seq'::regclass))::integer AS id;


--
-- Name: duplicates; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.duplicates (
    id integer DEFAULT public.duplicates_id_seq_view() NOT NULL,
    good_project_id integer NOT NULL,
    bad_project_id integer NOT NULL,
    account_id integer,
    comment text,
    created_at timestamp without time zone,
    resolved boolean DEFAULT false
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'duplicates'
);
ALTER FOREIGN TABLE public.duplicates ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.duplicates ALTER COLUMN good_project_id OPTIONS (
    column_name 'good_project_id'
);
ALTER FOREIGN TABLE public.duplicates ALTER COLUMN bad_project_id OPTIONS (
    column_name 'bad_project_id'
);
ALTER FOREIGN TABLE public.duplicates ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.duplicates ALTER COLUMN comment OPTIONS (
    column_name 'comment'
);
ALTER FOREIGN TABLE public.duplicates ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.duplicates ALTER COLUMN resolved OPTIONS (
    column_name 'resolved'
);


--
-- Name: duplicates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.duplicates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: duplicates_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.duplicates_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'duplicates_id_seq_view'
);
ALTER FOREIGN TABLE public.duplicates_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: edits; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.edits (
    id integer DEFAULT public.edits_id_seq_view() NOT NULL,
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'edits'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN target_id OPTIONS (
    column_name 'target_id'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN target_type OPTIONS (
    column_name 'target_type'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN key OPTIONS (
    column_name 'key'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN value OPTIONS (
    column_name 'value'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN ip OPTIONS (
    column_name 'ip'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN undone OPTIONS (
    column_name 'undone'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN undone_at OPTIONS (
    column_name 'undone_at'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN undone_by OPTIONS (
    column_name 'undone_by'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.edits ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);


--
-- Name: edits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.edits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: edits_id_seq1_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.edits_id_seq1_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'edits_id_seq1_view'
);
ALTER FOREIGN TABLE public.edits_id_seq1_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: edits_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.edits_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'edits_id_seq_view'
);
ALTER FOREIGN TABLE public.edits_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: email_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_addresses (
    id integer NOT NULL,
    address text NOT NULL
);


--
-- Name: email_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_addresses_id_seq OWNED BY public.email_addresses.id;


--
-- Name: email_addresses_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.email_addresses_id_seq_view AS
 SELECT (nextval('public.email_addresses_id_seq'::regclass))::integer AS id;


--
-- Name: enlistments; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.enlistments (
    id integer DEFAULT public.enlistments_id_seq_view() NOT NULL,
    project_id integer NOT NULL,
    repository_id integer,
    deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    updated_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    ignore text,
    code_location_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'enlistments'
);
ALTER FOREIGN TABLE public.enlistments ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.enlistments ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.enlistments ALTER COLUMN repository_id OPTIONS (
    column_name 'repository_id'
);
ALTER FOREIGN TABLE public.enlistments ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
);
ALTER FOREIGN TABLE public.enlistments ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.enlistments ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.enlistments ALTER COLUMN ignore OPTIONS (
    column_name 'ignore'
);
ALTER FOREIGN TABLE public.enlistments ALTER COLUMN code_location_id OPTIONS (
    column_name 'code_location_id'
);


--
-- Name: enlistments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enlistments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enlistments_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.enlistments_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'enlistments_id_seq_view'
);
ALTER FOREIGN TABLE public.enlistments_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: event_subscription; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.event_subscription (
    id integer DEFAULT public.event_subscription_id_seq_view() NOT NULL,
    subscriber_id integer,
    klass text NOT NULL,
    project_id integer,
    topic_id integer,
    account_id integer,
    created_at timestamp without time zone NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'event_subscription'
);
ALTER FOREIGN TABLE public.event_subscription ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.event_subscription ALTER COLUMN subscriber_id OPTIONS (
    column_name 'subscriber_id'
);
ALTER FOREIGN TABLE public.event_subscription ALTER COLUMN klass OPTIONS (
    column_name 'klass'
);
ALTER FOREIGN TABLE public.event_subscription ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.event_subscription ALTER COLUMN topic_id OPTIONS (
    column_name 'topic_id'
);
ALTER FOREIGN TABLE public.event_subscription ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.event_subscription ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);


--
-- Name: event_subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_subscription_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.event_subscription_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'event_subscription_id_seq_view'
);
ALTER FOREIGN TABLE public.event_subscription_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: exhibits; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.exhibits (
    id integer DEFAULT public.exhibits_id_seq_view() NOT NULL,
    report_id integer NOT NULL,
    type text NOT NULL,
    title text,
    params text,
    result text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'exhibits'
);
ALTER FOREIGN TABLE public.exhibits ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.exhibits ALTER COLUMN report_id OPTIONS (
    column_name 'report_id'
);
ALTER FOREIGN TABLE public.exhibits ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE public.exhibits ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE public.exhibits ALTER COLUMN params OPTIONS (
    column_name 'params'
);
ALTER FOREIGN TABLE public.exhibits ALTER COLUMN result OPTIONS (
    column_name 'result'
);
ALTER FOREIGN TABLE public.exhibits ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.exhibits ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: exhibits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exhibits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exhibits_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.exhibits_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'exhibits_id_seq_view'
);
ALTER FOREIGN TABLE public.exhibits_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: factoids; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.factoids (
    id integer DEFAULT public.factoids_id_seq_view() NOT NULL,
    severity integer DEFAULT 0,
    analysis_id integer NOT NULL,
    type text,
    license_id integer,
    language_id integer,
    previous_count integer DEFAULT 0,
    current_count integer DEFAULT 0,
    max_count integer DEFAULT 0
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'factoids'
);
ALTER FOREIGN TABLE public.factoids ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.factoids ALTER COLUMN severity OPTIONS (
    column_name 'severity'
);
ALTER FOREIGN TABLE public.factoids ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE public.factoids ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE public.factoids ALTER COLUMN license_id OPTIONS (
    column_name 'license_id'
);
ALTER FOREIGN TABLE public.factoids ALTER COLUMN language_id OPTIONS (
    column_name 'language_id'
);
ALTER FOREIGN TABLE public.factoids ALTER COLUMN previous_count OPTIONS (
    column_name 'previous_count'
);
ALTER FOREIGN TABLE public.factoids ALTER COLUMN current_count OPTIONS (
    column_name 'current_count'
);
ALTER FOREIGN TABLE public.factoids ALTER COLUMN max_count OPTIONS (
    column_name 'max_count'
);


--
-- Name: factoids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.factoids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: factoids_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.factoids_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'factoids_id_seq_view'
);
ALTER FOREIGN TABLE public.factoids_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: failure_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failure_groups (
    id integer NOT NULL,
    name text NOT NULL,
    pattern text NOT NULL,
    priority integer DEFAULT 0,
    auto_reschedule boolean DEFAULT false
);


--
-- Name: failure_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.failure_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failure_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.failure_groups_id_seq OWNED BY public.failure_groups.id;


--
-- Name: failure_groups_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.failure_groups_id_seq_view AS
 SELECT (nextval('public.failure_groups_id_seq'::regclass))::integer AS id;


--
-- Name: feedbacks; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.feedbacks (
    id integer DEFAULT public.feedbacks_id_seq_view() NOT NULL,
    rating integer,
    more_info integer,
    uuid character varying,
    ip_address inet,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'feedbacks'
);
ALTER FOREIGN TABLE public.feedbacks ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.feedbacks ALTER COLUMN rating OPTIONS (
    column_name 'rating'
);
ALTER FOREIGN TABLE public.feedbacks ALTER COLUMN more_info OPTIONS (
    column_name 'more_info'
);
ALTER FOREIGN TABLE public.feedbacks ALTER COLUMN uuid OPTIONS (
    column_name 'uuid'
);
ALTER FOREIGN TABLE public.feedbacks ALTER COLUMN ip_address OPTIONS (
    column_name 'ip_address'
);
ALTER FOREIGN TABLE public.feedbacks ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.feedbacks ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.feedbacks ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: feedbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.feedbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feedbacks_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.feedbacks_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'feedbacks_id_seq_view'
);
ALTER FOREIGN TABLE public.feedbacks_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: fisbot_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fisbot_events (
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
-- Name: fisbot_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fisbot_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fisbot_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fisbot_events_id_seq OWNED BY public.fisbot_events.id;


--
-- Name: fisbot_events_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.fisbot_events_id_seq_view AS
 SELECT (nextval('public.fisbot_events_id_seq'::regclass))::integer AS id;


--
-- Name: followed_messages; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.followed_messages (
    owner_id integer,
    id integer,
    account_id integer,
    created_at timestamp without time zone,
    deleted_at timestamp without time zone,
    body text,
    title text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'followed_messages'
);
ALTER FOREIGN TABLE public.followed_messages ALTER COLUMN owner_id OPTIONS (
    column_name 'owner_id'
);
ALTER FOREIGN TABLE public.followed_messages ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.followed_messages ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.followed_messages ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.followed_messages ALTER COLUMN deleted_at OPTIONS (
    column_name 'deleted_at'
);
ALTER FOREIGN TABLE public.followed_messages ALTER COLUMN body OPTIONS (
    column_name 'body'
);
ALTER FOREIGN TABLE public.followed_messages ALTER COLUMN title OPTIONS (
    column_name 'title'
);


--
-- Name: follows; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.follows (
    id integer DEFAULT public.follows_id_seq_view() NOT NULL,
    owner_id integer NOT NULL,
    project_id integer,
    account_id integer,
    created_at timestamp without time zone NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'follows'
);
ALTER FOREIGN TABLE public.follows ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.follows ALTER COLUMN owner_id OPTIONS (
    column_name 'owner_id'
);
ALTER FOREIGN TABLE public.follows ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.follows ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.follows ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);


--
-- Name: follows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.follows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: follows_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.follows_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'follows_id_seq_view'
);
ALTER FOREIGN TABLE public.follows_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: forges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forges (
    id integer NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    type text
);


--
-- Name: forges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forges_id_seq OWNED BY public.forges.id;


--
-- Name: forges_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.forges_id_seq_view AS
 SELECT (nextval('public.forges_id_seq'::regclass))::integer AS id;


--
-- Name: forums; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.forums (
    id integer DEFAULT public.forums_id_seq_view() NOT NULL,
    project_id integer,
    name text NOT NULL,
    topics_count integer DEFAULT 0,
    posts_count integer DEFAULT 0,
    "position" integer,
    description text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'forums'
);
ALTER FOREIGN TABLE public.forums ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.forums ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.forums ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE public.forums ALTER COLUMN topics_count OPTIONS (
    column_name 'topics_count'
);
ALTER FOREIGN TABLE public.forums ALTER COLUMN posts_count OPTIONS (
    column_name 'posts_count'
);
ALTER FOREIGN TABLE public.forums ALTER COLUMN "position" OPTIONS (
    column_name 'position'
);
ALTER FOREIGN TABLE public.forums ALTER COLUMN description OPTIONS (
    column_name 'description'
);


--
-- Name: forums_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forums_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forums_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.forums_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'forums_id_seq_view'
);
ALTER FOREIGN TABLE public.forums_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: fyles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fyles (
    id bigint NOT NULL,
    name text NOT NULL,
    code_set_id integer NOT NULL
);


--
-- Name: fyles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fyles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fyles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fyles_id_seq OWNED BY public.fyles.id;


--
-- Name: fyles_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.fyles_id_seq_view AS
 SELECT nextval('public.fyles_id_seq'::regclass) AS id;


--
-- Name: github_project; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.github_project (
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'github_project'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN owner OPTIONS (
    column_name 'owner'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN state_code OPTIONS (
    column_name 'state_code'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN homepage OPTIONS (
    column_name 'homepage'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN has_downloads OPTIONS (
    column_name 'has_downloads'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN is_fork OPTIONS (
    column_name 'is_fork'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN created OPTIONS (
    column_name 'created'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN updated OPTIONS (
    column_name 'updated'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN last_spidered OPTIONS (
    column_name 'last_spidered'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN parent OPTIONS (
    column_name 'parent'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN source OPTIONS (
    column_name 'source'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN watchers OPTIONS (
    column_name 'watchers'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN forks OPTIONS (
    column_name 'forks'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN project_created OPTIONS (
    column_name 'project_created'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN note OPTIONS (
    column_name 'note'
);
ALTER FOREIGN TABLE public.github_project ALTER COLUMN organization OPTIONS (
    column_name 'organization'
);


--
-- Name: guaranteed_spam_accounts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.guaranteed_spam_accounts (
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'guaranteed_spam_accounts'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN login OPTIONS (
    column_name 'login'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN email OPTIONS (
    column_name 'email'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN crypted_password OPTIONS (
    column_name 'crypted_password'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN salt OPTIONS (
    column_name 'salt'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN activation_code OPTIONS (
    column_name 'activation_code'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN activated_at OPTIONS (
    column_name 'activated_at'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN remember_token OPTIONS (
    column_name 'remember_token'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN remember_token_expires_at OPTIONS (
    column_name 'remember_token_expires_at'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN level OPTIONS (
    column_name 'level'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN posts_count OPTIONS (
    column_name 'posts_count'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN last_seen_at OPTIONS (
    column_name 'last_seen_at'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN country_code OPTIONS (
    column_name 'country_code'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN location OPTIONS (
    column_name 'location'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN latitude OPTIONS (
    column_name 'latitude'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN longitude OPTIONS (
    column_name 'longitude'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN best_vita_id OPTIONS (
    column_name 'best_vita_id'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN url OPTIONS (
    column_name 'url'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN about_markup_id OPTIONS (
    column_name 'about_markup_id'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN hide_experience OPTIONS (
    column_name 'hide_experience'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN email_master OPTIONS (
    column_name 'email_master'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN email_posts OPTIONS (
    column_name 'email_posts'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN email_kudos OPTIONS (
    column_name 'email_kudos'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN email_md5 OPTIONS (
    column_name 'email_md5'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN email_opportunities_visited OPTIONS (
    column_name 'email_opportunities_visited'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN activation_resent_at OPTIONS (
    column_name 'activation_resent_at'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN akas OPTIONS (
    column_name 'akas'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN email_new_followers OPTIONS (
    column_name 'email_new_followers'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN last_seen_ip OPTIONS (
    column_name 'last_seen_ip'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN twitter_account OPTIONS (
    column_name 'twitter_account'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN reset_password_tokens OPTIONS (
    column_name 'reset_password_tokens'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN affiliation_type OPTIONS (
    column_name 'affiliation_type'
);
ALTER FOREIGN TABLE public.guaranteed_spam_accounts ALTER COLUMN organization_name OPTIONS (
    column_name 'organization_name'
);


--
-- Name: helpfuls; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.helpfuls (
    id integer DEFAULT public.helpfuls_id_seq_view() NOT NULL,
    review_id integer,
    account_id integer NOT NULL,
    yes boolean DEFAULT true
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'helpfuls'
);
ALTER FOREIGN TABLE public.helpfuls ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.helpfuls ALTER COLUMN review_id OPTIONS (
    column_name 'review_id'
);
ALTER FOREIGN TABLE public.helpfuls ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.helpfuls ALTER COLUMN yes OPTIONS (
    column_name 'yes'
);


--
-- Name: helpfuls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.helpfuls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: helpfuls_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.helpfuls_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'helpfuls_id_seq_view'
);
ALTER FOREIGN TABLE public.helpfuls_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: invites; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.invites (
    id integer DEFAULT public.invites_id_seq_view() NOT NULL,
    invitor_id integer NOT NULL,
    invitee_id integer,
    invitee_email text NOT NULL,
    project_id integer NOT NULL,
    activation_code text,
    created_at timestamp without time zone,
    activated_at timestamp without time zone,
    name_id integer,
    contribution_id bigint
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'invites'
);
ALTER FOREIGN TABLE public.invites ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.invites ALTER COLUMN invitor_id OPTIONS (
    column_name 'invitor_id'
);
ALTER FOREIGN TABLE public.invites ALTER COLUMN invitee_id OPTIONS (
    column_name 'invitee_id'
);
ALTER FOREIGN TABLE public.invites ALTER COLUMN invitee_email OPTIONS (
    column_name 'invitee_email'
);
ALTER FOREIGN TABLE public.invites ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.invites ALTER COLUMN activation_code OPTIONS (
    column_name 'activation_code'
);
ALTER FOREIGN TABLE public.invites ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.invites ALTER COLUMN activated_at OPTIONS (
    column_name 'activated_at'
);
ALTER FOREIGN TABLE public.invites ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE public.invites ALTER COLUMN contribution_id OPTIONS (
    column_name 'contribution_id'
);


--
-- Name: invites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invites_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.invites_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'invites_id_seq_view'
);
ALTER FOREIGN TABLE public.invites_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: job_statuses; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.job_statuses (
    id integer NOT NULL,
    name text NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'job_statuses'
);
ALTER FOREIGN TABLE public.job_statuses ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.job_statuses ALTER COLUMN name OPTIONS (
    column_name 'name'
);


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
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
    code_location_tarball_id integer
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: jobs_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.jobs_id_seq_view AS
 SELECT nextval('public.jobs_id_seq'::regclass) AS id;


--
-- Name: knowledge_base_statuses; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.knowledge_base_statuses (
    id integer DEFAULT public.knowledge_base_statuses_id_seq_view() NOT NULL,
    project_id integer NOT NULL,
    in_sync boolean DEFAULT false,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'knowledge_base_statuses'
);
ALTER FOREIGN TABLE public.knowledge_base_statuses ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.knowledge_base_statuses ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.knowledge_base_statuses ALTER COLUMN in_sync OPTIONS (
    column_name 'in_sync'
);
ALTER FOREIGN TABLE public.knowledge_base_statuses ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: knowledge_base_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_base_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_base_statuses_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.knowledge_base_statuses_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'knowledge_base_statuses_id_seq_view'
);
ALTER FOREIGN TABLE public.knowledge_base_statuses_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: kudo_scores; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.kudo_scores (
    id integer DEFAULT public.kudo_scores_id_seq_view() NOT NULL,
    array_index integer,
    account_id integer,
    project_id integer,
    name_id integer,
    damping numeric DEFAULT 1.0,
    fraction numeric,
    score numeric,
    "position" integer,
    rank integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'kudo_scores'
);
ALTER FOREIGN TABLE public.kudo_scores ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.kudo_scores ALTER COLUMN array_index OPTIONS (
    column_name 'array_index'
);
ALTER FOREIGN TABLE public.kudo_scores ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.kudo_scores ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.kudo_scores ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE public.kudo_scores ALTER COLUMN damping OPTIONS (
    column_name 'damping'
);
ALTER FOREIGN TABLE public.kudo_scores ALTER COLUMN fraction OPTIONS (
    column_name 'fraction'
);
ALTER FOREIGN TABLE public.kudo_scores ALTER COLUMN score OPTIONS (
    column_name 'score'
);
ALTER FOREIGN TABLE public.kudo_scores ALTER COLUMN "position" OPTIONS (
    column_name 'position'
);
ALTER FOREIGN TABLE public.kudo_scores ALTER COLUMN rank OPTIONS (
    column_name 'rank'
);


--
-- Name: kudo_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kudo_scores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kudo_scores_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.kudo_scores_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'kudo_scores_id_seq_view'
);
ALTER FOREIGN TABLE public.kudo_scores_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: kudos; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.kudos (
    id integer DEFAULT public.kudos_id_seq_view() NOT NULL,
    sender_id integer NOT NULL,
    account_id integer,
    project_id integer,
    name_id integer,
    created_at timestamp without time zone,
    message character varying(80)
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'kudos'
);
ALTER FOREIGN TABLE public.kudos ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.kudos ALTER COLUMN sender_id OPTIONS (
    column_name 'sender_id'
);
ALTER FOREIGN TABLE public.kudos ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.kudos ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.kudos ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE public.kudos ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.kudos ALTER COLUMN message OPTIONS (
    column_name 'message'
);


--
-- Name: kudos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kudos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kudos_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.kudos_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'kudos_id_seq_view'
);
ALTER FOREIGN TABLE public.kudos_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: language_experiences; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.language_experiences (
    id integer DEFAULT public.language_experiences_id_seq_view() NOT NULL,
    position_id integer NOT NULL,
    language_id integer NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'language_experiences'
);
ALTER FOREIGN TABLE public.language_experiences ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.language_experiences ALTER COLUMN position_id OPTIONS (
    column_name 'position_id'
);
ALTER FOREIGN TABLE public.language_experiences ALTER COLUMN language_id OPTIONS (
    column_name 'language_id'
);


--
-- Name: language_experiences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.language_experiences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: language_experiences_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.language_experiences_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'language_experiences_id_seq_view'
);
ALTER FOREIGN TABLE public.language_experiences_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: language_facts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.language_facts (
    id integer DEFAULT public.language_facts_id_seq_view() NOT NULL,
    month date,
    language_id integer,
    commits bigint,
    loc_changed bigint,
    loc_total bigint,
    projects bigint,
    contributors bigint
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'language_facts'
);
ALTER FOREIGN TABLE public.language_facts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.language_facts ALTER COLUMN month OPTIONS (
    column_name 'month'
);
ALTER FOREIGN TABLE public.language_facts ALTER COLUMN language_id OPTIONS (
    column_name 'language_id'
);
ALTER FOREIGN TABLE public.language_facts ALTER COLUMN commits OPTIONS (
    column_name 'commits'
);
ALTER FOREIGN TABLE public.language_facts ALTER COLUMN loc_changed OPTIONS (
    column_name 'loc_changed'
);
ALTER FOREIGN TABLE public.language_facts ALTER COLUMN loc_total OPTIONS (
    column_name 'loc_total'
);
ALTER FOREIGN TABLE public.language_facts ALTER COLUMN projects OPTIONS (
    column_name 'projects'
);
ALTER FOREIGN TABLE public.language_facts ALTER COLUMN contributors OPTIONS (
    column_name 'contributors'
);


--
-- Name: language_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.language_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: language_facts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.language_facts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'language_facts_id_seq_view'
);
ALTER FOREIGN TABLE public.language_facts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: languages; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.languages (
    id integer DEFAULT public.languages_id_seq_view() NOT NULL,
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'languages'
);
ALTER FOREIGN TABLE public.languages ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.languages ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE public.languages ALTER COLUMN nice_name OPTIONS (
    column_name 'nice_name'
);
ALTER FOREIGN TABLE public.languages ALTER COLUMN category OPTIONS (
    column_name 'category'
);
ALTER FOREIGN TABLE public.languages ALTER COLUMN avg_percent_comments OPTIONS (
    column_name 'avg_percent_comments'
);
ALTER FOREIGN TABLE public.languages ALTER COLUMN code OPTIONS (
    column_name 'code'
);
ALTER FOREIGN TABLE public.languages ALTER COLUMN comments OPTIONS (
    column_name 'comments'
);
ALTER FOREIGN TABLE public.languages ALTER COLUMN blanks OPTIONS (
    column_name 'blanks'
);
ALTER FOREIGN TABLE public.languages ALTER COLUMN commits OPTIONS (
    column_name 'commits'
);
ALTER FOREIGN TABLE public.languages ALTER COLUMN projects OPTIONS (
    column_name 'projects'
);
ALTER FOREIGN TABLE public.languages ALTER COLUMN contributors OPTIONS (
    column_name 'contributors'
);
ALTER FOREIGN TABLE public.languages ALTER COLUMN active_contributors OPTIONS (
    column_name 'active_contributors'
);
ALTER FOREIGN TABLE public.languages ALTER COLUMN experienced_contributors OPTIONS (
    column_name 'experienced_contributors'
);


--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: languages_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.languages_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'languages_id_seq_view'
);
ALTER FOREIGN TABLE public.languages_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: license_facts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.license_facts (
    license_id integer NOT NULL,
    file_count integer DEFAULT 0 NOT NULL,
    scope integer DEFAULT 0 NOT NULL,
    id integer DEFAULT public.license_facts_id_seq_view() NOT NULL,
    analysis_id integer NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'license_facts'
);
ALTER FOREIGN TABLE public.license_facts ALTER COLUMN license_id OPTIONS (
    column_name 'license_id'
);
ALTER FOREIGN TABLE public.license_facts ALTER COLUMN file_count OPTIONS (
    column_name 'file_count'
);
ALTER FOREIGN TABLE public.license_facts ALTER COLUMN scope OPTIONS (
    column_name 'scope'
);
ALTER FOREIGN TABLE public.license_facts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.license_facts ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);


--
-- Name: license_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.license_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: license_facts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.license_facts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'license_facts_id_seq_view'
);
ALTER FOREIGN TABLE public.license_facts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: licenses; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.licenses (
    id integer DEFAULT public.licenses_id_seq_view() NOT NULL,
    vanity_url text,
    name text,
    abbreviation text,
    url text,
    description text,
    deleted boolean DEFAULT false,
    locked boolean DEFAULT false
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'licenses'
);
ALTER FOREIGN TABLE public.licenses ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.licenses ALTER COLUMN vanity_url OPTIONS (
    column_name 'vanity_url'
);
ALTER FOREIGN TABLE public.licenses ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE public.licenses ALTER COLUMN abbreviation OPTIONS (
    column_name 'abbreviation'
);
ALTER FOREIGN TABLE public.licenses ALTER COLUMN url OPTIONS (
    column_name 'url'
);
ALTER FOREIGN TABLE public.licenses ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE public.licenses ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
);
ALTER FOREIGN TABLE public.licenses ALTER COLUMN locked OPTIONS (
    column_name 'locked'
);


--
-- Name: licenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: licenses_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.licenses_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'licenses_id_seq_view'
);
ALTER FOREIGN TABLE public.licenses_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: link_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.link_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: link_categories_deleted; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.link_categories_deleted (
    id integer DEFAULT nextval('public.link_categories_id_seq'::regclass) NOT NULL,
    name text NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'link_categories_deleted'
);
ALTER FOREIGN TABLE public.link_categories_deleted ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.link_categories_deleted ALTER COLUMN name OPTIONS (
    column_name 'name'
);


--
-- Name: link_categories_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.link_categories_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'link_categories_id_seq_view'
);
ALTER FOREIGN TABLE public.link_categories_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: links; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.links (
    id integer DEFAULT public.links_id_seq_view() NOT NULL,
    title text NOT NULL,
    url text NOT NULL,
    project_id integer NOT NULL,
    link_category_id integer NOT NULL,
    deleted boolean DEFAULT false,
    created_at timestamp without time zone,
    helpful_score integer DEFAULT 0 NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'links'
);
ALTER FOREIGN TABLE public.links ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.links ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE public.links ALTER COLUMN url OPTIONS (
    column_name 'url'
);
ALTER FOREIGN TABLE public.links ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.links ALTER COLUMN link_category_id OPTIONS (
    column_name 'link_category_id'
);
ALTER FOREIGN TABLE public.links ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
);
ALTER FOREIGN TABLE public.links ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.links ALTER COLUMN helpful_score OPTIONS (
    column_name 'helpful_score'
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.links_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'links_id_seq_view'
);
ALTER FOREIGN TABLE public.links_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: load_averages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.load_averages (
    current numeric DEFAULT 0.0,
    id integer NOT NULL,
    max numeric DEFAULT 3.0
);


--
-- Name: load_averages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.load_averages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: load_averages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.load_averages_id_seq OWNED BY public.load_averages.id;


--
-- Name: load_averages_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.load_averages_id_seq_view AS
 SELECT (nextval('public.load_averages_id_seq'::regclass))::integer AS id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations (
    created_at timestamp without time zone
);


--
-- Name: manages; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.manages (
    id integer DEFAULT public.manages_id_seq_view() NOT NULL,
    account_id integer NOT NULL,
    target_id integer NOT NULL,
    message text,
    updated_at timestamp without time zone,
    created_at timestamp without time zone,
    approved_by integer,
    deleted_by integer,
    deleted_at timestamp without time zone,
    target_type text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'manages'
);
ALTER FOREIGN TABLE public.manages ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.manages ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.manages ALTER COLUMN target_id OPTIONS (
    column_name 'target_id'
);
ALTER FOREIGN TABLE public.manages ALTER COLUMN message OPTIONS (
    column_name 'message'
);
ALTER FOREIGN TABLE public.manages ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.manages ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.manages ALTER COLUMN approved_by OPTIONS (
    column_name 'approved_by'
);
ALTER FOREIGN TABLE public.manages ALTER COLUMN deleted_by OPTIONS (
    column_name 'deleted_by'
);
ALTER FOREIGN TABLE public.manages ALTER COLUMN deleted_at OPTIONS (
    column_name 'deleted_at'
);
ALTER FOREIGN TABLE public.manages ALTER COLUMN target_type OPTIONS (
    column_name 'target_type'
);


--
-- Name: manages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.manages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: manages_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.manages_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'manages_id_seq_view'
);
ALTER FOREIGN TABLE public.manages_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: markups; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.markups (
    id integer DEFAULT public.markups_id_seq_view() NOT NULL,
    raw text,
    formatted text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'markups'
);
ALTER FOREIGN TABLE public.markups ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.markups ALTER COLUMN raw OPTIONS (
    column_name 'raw'
);
ALTER FOREIGN TABLE public.markups ALTER COLUMN formatted OPTIONS (
    column_name 'formatted'
);


--
-- Name: markups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.markups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: markups_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.markups_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'markups_id_seq_view'
);
ALTER FOREIGN TABLE public.markups_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: message_account_tags; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.message_account_tags (
    id integer DEFAULT public.message_account_tags_id_seq_view() NOT NULL,
    message_id integer,
    account_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'message_account_tags'
);
ALTER FOREIGN TABLE public.message_account_tags ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.message_account_tags ALTER COLUMN message_id OPTIONS (
    column_name 'message_id'
);
ALTER FOREIGN TABLE public.message_account_tags ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);


--
-- Name: message_account_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.message_account_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_account_tags_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.message_account_tags_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'message_account_tags_id_seq_view'
);
ALTER FOREIGN TABLE public.message_account_tags_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: message_project_tags; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.message_project_tags (
    id integer DEFAULT public.message_project_tags_id_seq_view() NOT NULL,
    message_id integer,
    project_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'message_project_tags'
);
ALTER FOREIGN TABLE public.message_project_tags ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.message_project_tags ALTER COLUMN message_id OPTIONS (
    column_name 'message_id'
);
ALTER FOREIGN TABLE public.message_project_tags ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);


--
-- Name: message_project_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.message_project_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_project_tags_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.message_project_tags_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'message_project_tags_id_seq_view'
);
ALTER FOREIGN TABLE public.message_project_tags_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: messages; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.messages (
    id integer DEFAULT public.messages_id_seq_view() NOT NULL,
    account_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    body text,
    title text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'messages'
);
ALTER FOREIGN TABLE public.messages ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.messages ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.messages ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.messages ALTER COLUMN deleted_at OPTIONS (
    column_name 'deleted_at'
);
ALTER FOREIGN TABLE public.messages ALTER COLUMN body OPTIONS (
    column_name 'body'
);
ALTER FOREIGN TABLE public.messages ALTER COLUMN title OPTIONS (
    column_name 'title'
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.messages_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'messages_id_seq_view'
);
ALTER FOREIGN TABLE public.messages_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: mistaken_jobs; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.mistaken_jobs (
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'mistaken_jobs'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN repository_id OPTIONS (
    column_name 'repository_id'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN status OPTIONS (
    column_name 'status'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN priority OPTIONS (
    column_name 'priority'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN current_step OPTIONS (
    column_name 'current_step'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN current_step_at OPTIONS (
    column_name 'current_step_at'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN max_steps OPTIONS (
    column_name 'max_steps'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN exception OPTIONS (
    column_name 'exception'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN backtrace OPTIONS (
    column_name 'backtrace'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN code_set_id OPTIONS (
    column_name 'code_set_id'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN sloc_set_id OPTIONS (
    column_name 'sloc_set_id'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN notes OPTIONS (
    column_name 'notes'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN wait_until OPTIONS (
    column_name 'wait_until'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN logged_at OPTIONS (
    column_name 'logged_at'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN slave_id OPTIONS (
    column_name 'slave_id'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN started_at OPTIONS (
    column_name 'started_at'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN retry_count OPTIONS (
    column_name 'retry_count'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN do_not_retry OPTIONS (
    column_name 'do_not_retry'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN failure_group_id OPTIONS (
    column_name 'failure_group_id'
);
ALTER FOREIGN TABLE public.mistaken_jobs ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);


--
-- Name: moderatorships_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.moderatorships_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'moderatorships_id_seq_view'
);
ALTER FOREIGN TABLE public.moderatorships_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: monitorships_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.monitorships_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'monitorships_id_seq_view'
);
ALTER FOREIGN TABLE public.monitorships_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: monthly_commit_histories; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.monthly_commit_histories (
    id integer DEFAULT public.monthly_commit_histories_id_seq_view() NOT NULL,
    analysis_id integer,
    json text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'monthly_commit_histories'
);
ALTER FOREIGN TABLE public.monthly_commit_histories ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.monthly_commit_histories ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE public.monthly_commit_histories ALTER COLUMN json OPTIONS (
    column_name 'json'
);


--
-- Name: monthly_commit_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.monthly_commit_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monthly_commit_histories_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.monthly_commit_histories_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'monthly_commit_histories_id_seq_view'
);
ALTER FOREIGN TABLE public.monthly_commit_histories_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: name_facts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.name_facts (
    id bigint DEFAULT public.name_facts_id_seq_view() NOT NULL,
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'name_facts'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN primary_language_id OPTIONS (
    column_name 'primary_language_id'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN total_code_added OPTIONS (
    column_name 'total_code_added'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN last_checkin OPTIONS (
    column_name 'last_checkin'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN comment_ratio OPTIONS (
    column_name 'comment_ratio'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN man_months OPTIONS (
    column_name 'man_months'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN commits OPTIONS (
    column_name 'commits'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN median_commits OPTIONS (
    column_name 'median_commits'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN median_activity_lines OPTIONS (
    column_name 'median_activity_lines'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN first_checkin OPTIONS (
    column_name 'first_checkin'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN vita_id OPTIONS (
    column_name 'vita_id'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN thirty_day_commits OPTIONS (
    column_name 'thirty_day_commits'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN twelve_month_commits OPTIONS (
    column_name 'twelve_month_commits'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN commits_by_project OPTIONS (
    column_name 'commits_by_project'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN commits_by_language OPTIONS (
    column_name 'commits_by_language'
);
ALTER FOREIGN TABLE public.name_facts ALTER COLUMN email_address_ids OPTIONS (
    column_name 'email_address_ids'
);


--
-- Name: name_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.name_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: name_facts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.name_facts_id_seq_view (
    id bigint
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'name_facts_id_seq_view'
);
ALTER FOREIGN TABLE public.name_facts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: name_language_facts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.name_language_facts (
    id bigint DEFAULT public.name_language_facts_id_seq_view() NOT NULL,
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'name_language_facts'
);
ALTER FOREIGN TABLE public.name_language_facts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.name_language_facts ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE public.name_language_facts ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE public.name_language_facts ALTER COLUMN language_id OPTIONS (
    column_name 'language_id'
);
ALTER FOREIGN TABLE public.name_language_facts ALTER COLUMN total_months OPTIONS (
    column_name 'total_months'
);
ALTER FOREIGN TABLE public.name_language_facts ALTER COLUMN total_commits OPTIONS (
    column_name 'total_commits'
);
ALTER FOREIGN TABLE public.name_language_facts ALTER COLUMN total_activity_lines OPTIONS (
    column_name 'total_activity_lines'
);
ALTER FOREIGN TABLE public.name_language_facts ALTER COLUMN vita_id OPTIONS (
    column_name 'vita_id'
);
ALTER FOREIGN TABLE public.name_language_facts ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE public.name_language_facts ALTER COLUMN comment_ratio OPTIONS (
    column_name 'comment_ratio'
);
ALTER FOREIGN TABLE public.name_language_facts ALTER COLUMN most_commits_project_id OPTIONS (
    column_name 'most_commits_project_id'
);
ALTER FOREIGN TABLE public.name_language_facts ALTER COLUMN most_commits OPTIONS (
    column_name 'most_commits'
);
ALTER FOREIGN TABLE public.name_language_facts ALTER COLUMN recent_commit_project_id OPTIONS (
    column_name 'recent_commit_project_id'
);
ALTER FOREIGN TABLE public.name_language_facts ALTER COLUMN recent_commit_month OPTIONS (
    column_name 'recent_commit_month'
);


--
-- Name: name_language_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.name_language_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: name_language_facts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.name_language_facts_id_seq_view (
    id bigint
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'name_language_facts_id_seq_view'
);
ALTER FOREIGN TABLE public.name_language_facts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: names; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.names (
    id integer DEFAULT public.names_id_seq_view() NOT NULL,
    name text NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'names'
);
ALTER FOREIGN TABLE public.names ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.names ALTER COLUMN name OPTIONS (
    column_name 'name'
);


--
-- Name: names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: names_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.names_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'names_id_seq_view'
);
ALTER FOREIGN TABLE public.names_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: oauth_access_grants; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.oauth_access_grants (
    id integer DEFAULT public.oauth_access_grants_id_seq_view() NOT NULL,
    resource_owner_id integer NOT NULL,
    application_id integer NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'oauth_access_grants'
);
ALTER FOREIGN TABLE public.oauth_access_grants ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.oauth_access_grants ALTER COLUMN resource_owner_id OPTIONS (
    column_name 'resource_owner_id'
);
ALTER FOREIGN TABLE public.oauth_access_grants ALTER COLUMN application_id OPTIONS (
    column_name 'application_id'
);
ALTER FOREIGN TABLE public.oauth_access_grants ALTER COLUMN token OPTIONS (
    column_name 'token'
);
ALTER FOREIGN TABLE public.oauth_access_grants ALTER COLUMN expires_in OPTIONS (
    column_name 'expires_in'
);
ALTER FOREIGN TABLE public.oauth_access_grants ALTER COLUMN redirect_uri OPTIONS (
    column_name 'redirect_uri'
);
ALTER FOREIGN TABLE public.oauth_access_grants ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.oauth_access_grants ALTER COLUMN revoked_at OPTIONS (
    column_name 'revoked_at'
);
ALTER FOREIGN TABLE public.oauth_access_grants ALTER COLUMN scopes OPTIONS (
    column_name 'scopes'
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.oauth_access_grants_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'oauth_access_grants_id_seq_view'
);
ALTER FOREIGN TABLE public.oauth_access_grants_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: oauth_access_tokens; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.oauth_access_tokens (
    id integer DEFAULT public.oauth_access_tokens_id_seq_view() NOT NULL,
    resource_owner_id integer,
    application_id integer,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'oauth_access_tokens'
);
ALTER FOREIGN TABLE public.oauth_access_tokens ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.oauth_access_tokens ALTER COLUMN resource_owner_id OPTIONS (
    column_name 'resource_owner_id'
);
ALTER FOREIGN TABLE public.oauth_access_tokens ALTER COLUMN application_id OPTIONS (
    column_name 'application_id'
);
ALTER FOREIGN TABLE public.oauth_access_tokens ALTER COLUMN token OPTIONS (
    column_name 'token'
);
ALTER FOREIGN TABLE public.oauth_access_tokens ALTER COLUMN refresh_token OPTIONS (
    column_name 'refresh_token'
);
ALTER FOREIGN TABLE public.oauth_access_tokens ALTER COLUMN expires_in OPTIONS (
    column_name 'expires_in'
);
ALTER FOREIGN TABLE public.oauth_access_tokens ALTER COLUMN revoked_at OPTIONS (
    column_name 'revoked_at'
);
ALTER FOREIGN TABLE public.oauth_access_tokens ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.oauth_access_tokens ALTER COLUMN scopes OPTIONS (
    column_name 'scopes'
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.oauth_access_tokens_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'oauth_access_tokens_id_seq_view'
);
ALTER FOREIGN TABLE public.oauth_access_tokens_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: oauth_applications; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.oauth_applications (
    id integer DEFAULT public.oauth_applications_id_seq_view() NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'oauth_applications'
);
ALTER FOREIGN TABLE public.oauth_applications ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.oauth_applications ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE public.oauth_applications ALTER COLUMN uid OPTIONS (
    column_name 'uid'
);
ALTER FOREIGN TABLE public.oauth_applications ALTER COLUMN secret OPTIONS (
    column_name 'secret'
);
ALTER FOREIGN TABLE public.oauth_applications ALTER COLUMN redirect_uri OPTIONS (
    column_name 'redirect_uri'
);
ALTER FOREIGN TABLE public.oauth_applications ALTER COLUMN scopes OPTIONS (
    column_name 'scopes'
);
ALTER FOREIGN TABLE public.oauth_applications ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.oauth_applications ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.oauth_applications_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'oauth_applications_id_seq_view'
);
ALTER FOREIGN TABLE public.oauth_applications_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: oauth_nonces; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.oauth_nonces (
    id integer DEFAULT public.oauth_nonces_id_seq_view() NOT NULL,
    nonce text NOT NULL,
    "timestamp" integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'oauth_nonces'
);
ALTER FOREIGN TABLE public.oauth_nonces ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.oauth_nonces ALTER COLUMN nonce OPTIONS (
    column_name 'nonce'
);
ALTER FOREIGN TABLE public.oauth_nonces ALTER COLUMN "timestamp" OPTIONS (
    column_name 'timestamp'
);
ALTER FOREIGN TABLE public.oauth_nonces ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.oauth_nonces ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: oauth_nonces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_nonces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_nonces_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.oauth_nonces_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'oauth_nonces_id_seq_view'
);
ALTER FOREIGN TABLE public.oauth_nonces_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: old_code_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.old_code_sets (
    id integer NOT NULL,
    code_set_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: old_code_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.old_code_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: old_code_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.old_code_sets_id_seq OWNED BY public.old_code_sets.id;


--
-- Name: old_edits_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.old_edits_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'old_edits_id_seq_view'
);
ALTER FOREIGN TABLE public.old_edits_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: org_stats_by_sectors; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.org_stats_by_sectors (
    id integer DEFAULT public.org_stats_by_sectors_id_seq_view() NOT NULL,
    org_type integer,
    organization_count integer,
    commits_count integer,
    affiliate_count integer,
    average_commits integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'org_stats_by_sectors'
);
ALTER FOREIGN TABLE public.org_stats_by_sectors ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.org_stats_by_sectors ALTER COLUMN org_type OPTIONS (
    column_name 'org_type'
);
ALTER FOREIGN TABLE public.org_stats_by_sectors ALTER COLUMN organization_count OPTIONS (
    column_name 'organization_count'
);
ALTER FOREIGN TABLE public.org_stats_by_sectors ALTER COLUMN commits_count OPTIONS (
    column_name 'commits_count'
);
ALTER FOREIGN TABLE public.org_stats_by_sectors ALTER COLUMN affiliate_count OPTIONS (
    column_name 'affiliate_count'
);
ALTER FOREIGN TABLE public.org_stats_by_sectors ALTER COLUMN average_commits OPTIONS (
    column_name 'average_commits'
);
ALTER FOREIGN TABLE public.org_stats_by_sectors ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.org_stats_by_sectors ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: org_stats_by_sectors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.org_stats_by_sectors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_stats_by_sectors_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.org_stats_by_sectors_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'org_stats_by_sectors_id_seq_view'
);
ALTER FOREIGN TABLE public.org_stats_by_sectors_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: org_thirty_day_activities; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.org_thirty_day_activities (
    id integer DEFAULT public.org_thirty_day_activities_id_seq_view() NOT NULL,
    name character varying(255),
    organization_id integer,
    vanity_url character varying(255),
    org_type integer,
    project_count integer,
    affiliate_count integer,
    thirty_day_commit_count integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'org_thirty_day_activities'
);
ALTER FOREIGN TABLE public.org_thirty_day_activities ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.org_thirty_day_activities ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE public.org_thirty_day_activities ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);
ALTER FOREIGN TABLE public.org_thirty_day_activities ALTER COLUMN vanity_url OPTIONS (
    column_name 'vanity_url'
);
ALTER FOREIGN TABLE public.org_thirty_day_activities ALTER COLUMN org_type OPTIONS (
    column_name 'org_type'
);
ALTER FOREIGN TABLE public.org_thirty_day_activities ALTER COLUMN project_count OPTIONS (
    column_name 'project_count'
);
ALTER FOREIGN TABLE public.org_thirty_day_activities ALTER COLUMN affiliate_count OPTIONS (
    column_name 'affiliate_count'
);
ALTER FOREIGN TABLE public.org_thirty_day_activities ALTER COLUMN thirty_day_commit_count OPTIONS (
    column_name 'thirty_day_commit_count'
);
ALTER FOREIGN TABLE public.org_thirty_day_activities ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.org_thirty_day_activities ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: org_thirty_day_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.org_thirty_day_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_thirty_day_activities_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.org_thirty_day_activities_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'org_thirty_day_activities_id_seq_view'
);
ALTER FOREIGN TABLE public.org_thirty_day_activities_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: organizations; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.organizations (
    id integer DEFAULT public.organizations_id_seq_view() NOT NULL,
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'organizations'
);
ALTER FOREIGN TABLE public.organizations ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.organizations ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE public.organizations ALTER COLUMN vanity_url OPTIONS (
    column_name 'vanity_url'
);
ALTER FOREIGN TABLE public.organizations ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE public.organizations ALTER COLUMN org_type OPTIONS (
    column_name 'org_type'
);
ALTER FOREIGN TABLE public.organizations ALTER COLUMN homepage_url OPTIONS (
    column_name 'homepage_url'
);
ALTER FOREIGN TABLE public.organizations ALTER COLUMN logo_id OPTIONS (
    column_name 'logo_id'
);
ALTER FOREIGN TABLE public.organizations ALTER COLUMN vector OPTIONS (
    column_name 'vector'
);
ALTER FOREIGN TABLE public.organizations ALTER COLUMN popularity_factor OPTIONS (
    column_name 'popularity_factor'
);
ALTER FOREIGN TABLE public.organizations ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
);
ALTER FOREIGN TABLE public.organizations ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.organizations ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.organizations ALTER COLUMN projects_count OPTIONS (
    column_name 'projects_count'
);
ALTER FOREIGN TABLE public.organizations ALTER COLUMN thirty_day_activity_id OPTIONS (
    column_name 'thirty_day_activity_id'
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.organizations_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'organizations_id_seq_view'
);
ALTER FOREIGN TABLE public.organizations_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: pages_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.pages_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'pages_id_seq_view'
);
ALTER FOREIGN TABLE public.pages_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: people; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.people (
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
    popularity_factor numeric
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'people'
);
ALTER FOREIGN TABLE public.people ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.people ALTER COLUMN effective_name OPTIONS (
    column_name 'effective_name'
);
ALTER FOREIGN TABLE public.people ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.people ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.people ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE public.people ALTER COLUMN name_fact_id OPTIONS (
    column_name 'name_fact_id'
);
ALTER FOREIGN TABLE public.people ALTER COLUMN kudo_position OPTIONS (
    column_name 'kudo_position'
);
ALTER FOREIGN TABLE public.people ALTER COLUMN kudo_score OPTIONS (
    column_name 'kudo_score'
);
ALTER FOREIGN TABLE public.people ALTER COLUMN kudo_rank OPTIONS (
    column_name 'kudo_rank'
);
ALTER FOREIGN TABLE public.people ALTER COLUMN vector OPTIONS (
    column_name 'vector'
);
ALTER FOREIGN TABLE public.people ALTER COLUMN popularity_factor OPTIONS (
    column_name 'popularity_factor'
);


--
-- Name: people_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.people_view (
    id bigint,
    effective_name text,
    account_id integer,
    project_id integer,
    name_id integer,
    name_fact_id integer,
    kudo_position integer,
    kudo_score numeric,
    kudo_rank integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'people_view'
);
ALTER FOREIGN TABLE public.people_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.people_view ALTER COLUMN effective_name OPTIONS (
    column_name 'effective_name'
);
ALTER FOREIGN TABLE public.people_view ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.people_view ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.people_view ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE public.people_view ALTER COLUMN name_fact_id OPTIONS (
    column_name 'name_fact_id'
);
ALTER FOREIGN TABLE public.people_view ALTER COLUMN kudo_position OPTIONS (
    column_name 'kudo_position'
);
ALTER FOREIGN TABLE public.people_view ALTER COLUMN kudo_score OPTIONS (
    column_name 'kudo_score'
);
ALTER FOREIGN TABLE public.people_view ALTER COLUMN kudo_rank OPTIONS (
    column_name 'kudo_rank'
);


--
-- Name: permissions; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.permissions (
    id integer DEFAULT public.permissions_id_seq_view() NOT NULL,
    target_id integer NOT NULL,
    updated_at timestamp without time zone,
    created_at timestamp without time zone,
    remainder boolean DEFAULT false,
    downloads boolean DEFAULT false,
    target_type text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'permissions'
);
ALTER FOREIGN TABLE public.permissions ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.permissions ALTER COLUMN target_id OPTIONS (
    column_name 'target_id'
);
ALTER FOREIGN TABLE public.permissions ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.permissions ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.permissions ALTER COLUMN remainder OPTIONS (
    column_name 'remainder'
);
ALTER FOREIGN TABLE public.permissions ALTER COLUMN downloads OPTIONS (
    column_name 'downloads'
);
ALTER FOREIGN TABLE public.permissions ALTER COLUMN target_type OPTIONS (
    column_name 'target_type'
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.permissions_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'permissions_id_seq_view'
);
ALTER FOREIGN TABLE public.permissions_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: pg_ts_cfg; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.pg_ts_cfg (
    ts_name text NOT NULL,
    prs_name text NOT NULL,
    locale text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'pg_ts_cfg'
);
ALTER FOREIGN TABLE public.pg_ts_cfg ALTER COLUMN ts_name OPTIONS (
    column_name 'ts_name'
);
ALTER FOREIGN TABLE public.pg_ts_cfg ALTER COLUMN prs_name OPTIONS (
    column_name 'prs_name'
);
ALTER FOREIGN TABLE public.pg_ts_cfg ALTER COLUMN locale OPTIONS (
    column_name 'locale'
);


--
-- Name: pg_ts_cfgmap; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.pg_ts_cfgmap (
    ts_name text NOT NULL,
    tok_alias text NOT NULL,
    dict_name text[]
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'pg_ts_cfgmap'
);
ALTER FOREIGN TABLE public.pg_ts_cfgmap ALTER COLUMN ts_name OPTIONS (
    column_name 'ts_name'
);
ALTER FOREIGN TABLE public.pg_ts_cfgmap ALTER COLUMN tok_alias OPTIONS (
    column_name 'tok_alias'
);
ALTER FOREIGN TABLE public.pg_ts_cfgmap ALTER COLUMN dict_name OPTIONS (
    column_name 'dict_name'
);


--
-- Name: positions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.positions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: positions_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.positions_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'positions_id_seq_view'
);
ALTER FOREIGN TABLE public.positions_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: posts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.posts (
    id integer DEFAULT public.posts_id_seq_view() NOT NULL,
    account_id integer NOT NULL,
    topic_id integer NOT NULL,
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    notified_at timestamp without time zone,
    vector tsvector,
    popularity_factor numeric
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'posts'
);
ALTER FOREIGN TABLE public.posts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.posts ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.posts ALTER COLUMN topic_id OPTIONS (
    column_name 'topic_id'
);
ALTER FOREIGN TABLE public.posts ALTER COLUMN body OPTIONS (
    column_name 'body'
);
ALTER FOREIGN TABLE public.posts ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.posts ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.posts ALTER COLUMN notified_at OPTIONS (
    column_name 'notified_at'
);
ALTER FOREIGN TABLE public.posts ALTER COLUMN vector OPTIONS (
    column_name 'vector'
);
ALTER FOREIGN TABLE public.posts ALTER COLUMN popularity_factor OPTIONS (
    column_name 'popularity_factor'
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.posts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'posts_id_seq_view'
);
ALTER FOREIGN TABLE public.posts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: profiles; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.profiles (
    id integer DEFAULT public.profiles_id_seq_view() NOT NULL,
    job_id integer,
    name text NOT NULL,
    count integer NOT NULL,
    "time" numeric NOT NULL,
    created_at timestamp without time zone NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'profiles'
);
ALTER FOREIGN TABLE public.profiles ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.profiles ALTER COLUMN job_id OPTIONS (
    column_name 'job_id'
);
ALTER FOREIGN TABLE public.profiles ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE public.profiles ALTER COLUMN count OPTIONS (
    column_name 'count'
);
ALTER FOREIGN TABLE public.profiles ALTER COLUMN "time" OPTIONS (
    column_name 'time'
);
ALTER FOREIGN TABLE public.profiles ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);


--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.profiles_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'profiles_id_seq_view'
);
ALTER FOREIGN TABLE public.profiles_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: project_badges; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_badges (
    id integer DEFAULT public.project_badges_id_seq_view() NOT NULL,
    identifier character varying,
    type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 1,
    enlistment_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_badges'
);
ALTER FOREIGN TABLE public.project_badges ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.project_badges ALTER COLUMN identifier OPTIONS (
    column_name 'identifier'
);
ALTER FOREIGN TABLE public.project_badges ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE public.project_badges ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.project_badges ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.project_badges ALTER COLUMN status OPTIONS (
    column_name 'status'
);
ALTER FOREIGN TABLE public.project_badges ALTER COLUMN enlistment_id OPTIONS (
    column_name 'enlistment_id'
);


--
-- Name: project_badges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_badges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_badges_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_badges_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_badges_id_seq_view'
);
ALTER FOREIGN TABLE public.project_badges_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: project_counts_by_quarter_and_language; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_counts_by_quarter_and_language (
    language_id integer,
    quarter timestamp without time zone,
    project_count bigint
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_counts_by_quarter_and_language'
);
ALTER FOREIGN TABLE public.project_counts_by_quarter_and_language ALTER COLUMN language_id OPTIONS (
    column_name 'language_id'
);
ALTER FOREIGN TABLE public.project_counts_by_quarter_and_language ALTER COLUMN quarter OPTIONS (
    column_name 'quarter'
);
ALTER FOREIGN TABLE public.project_counts_by_quarter_and_language ALTER COLUMN project_count OPTIONS (
    column_name 'project_count'
);


--
-- Name: project_events; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_events (
    id integer DEFAULT public.project_events_id_seq_view() NOT NULL,
    project_id integer,
    type text NOT NULL,
    key text NOT NULL,
    data text,
    "time" timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_events'
);
ALTER FOREIGN TABLE public.project_events ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.project_events ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.project_events ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE public.project_events ALTER COLUMN key OPTIONS (
    column_name 'key'
);
ALTER FOREIGN TABLE public.project_events ALTER COLUMN data OPTIONS (
    column_name 'data'
);
ALTER FOREIGN TABLE public.project_events ALTER COLUMN "time" OPTIONS (
    column_name 'time'
);
ALTER FOREIGN TABLE public.project_events ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);


--
-- Name: project_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_events_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_events_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_events_id_seq_view'
);
ALTER FOREIGN TABLE public.project_events_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: project_experiences; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_experiences (
    id integer DEFAULT public.project_experiences_id_seq_view() NOT NULL,
    position_id integer NOT NULL,
    project_id integer NOT NULL,
    promote boolean DEFAULT false NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_experiences'
);
ALTER FOREIGN TABLE public.project_experiences ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.project_experiences ALTER COLUMN position_id OPTIONS (
    column_name 'position_id'
);
ALTER FOREIGN TABLE public.project_experiences ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.project_experiences ALTER COLUMN promote OPTIONS (
    column_name 'promote'
);


--
-- Name: project_experiences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_experiences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_experiences_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_experiences_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_experiences_id_seq_view'
);
ALTER FOREIGN TABLE public.project_experiences_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: project_gestalts_tmp; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_gestalts_tmp (
    id integer,
    date timestamp without time zone,
    project_id integer,
    gestalt_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_gestalts_tmp'
);
ALTER FOREIGN TABLE public.project_gestalts_tmp ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.project_gestalts_tmp ALTER COLUMN date OPTIONS (
    column_name 'date'
);
ALTER FOREIGN TABLE public.project_gestalts_tmp ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.project_gestalts_tmp ALTER COLUMN gestalt_id OPTIONS (
    column_name 'gestalt_id'
);


--
-- Name: project_licenses; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_licenses (
    id integer DEFAULT public.project_licenses_id_seq_view() NOT NULL,
    project_id integer,
    license_id integer,
    deleted boolean DEFAULT false
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_licenses'
);
ALTER FOREIGN TABLE public.project_licenses ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.project_licenses ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.project_licenses ALTER COLUMN license_id OPTIONS (
    column_name 'license_id'
);
ALTER FOREIGN TABLE public.project_licenses ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
);


--
-- Name: project_licenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_licenses_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_licenses_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_licenses_id_seq_view'
);
ALTER FOREIGN TABLE public.project_licenses_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: project_reports; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_reports (
    id integer DEFAULT public.project_reports_id_seq_view() NOT NULL,
    project_id integer NOT NULL,
    report_id integer NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_reports'
);
ALTER FOREIGN TABLE public.project_reports ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.project_reports ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.project_reports ALTER COLUMN report_id OPTIONS (
    column_name 'report_id'
);


--
-- Name: project_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_reports_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_reports_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_reports_id_seq_view'
);
ALTER FOREIGN TABLE public.project_reports_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: project_security_sets; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_security_sets (
    id integer DEFAULT public.project_security_sets_id_seq_view() NOT NULL,
    project_id integer,
    uuid character varying NOT NULL,
    etag character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_security_sets'
);
ALTER FOREIGN TABLE public.project_security_sets ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.project_security_sets ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.project_security_sets ALTER COLUMN uuid OPTIONS (
    column_name 'uuid'
);
ALTER FOREIGN TABLE public.project_security_sets ALTER COLUMN etag OPTIONS (
    column_name 'etag'
);
ALTER FOREIGN TABLE public.project_security_sets ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.project_security_sets ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: project_security_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_security_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_security_sets_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_security_sets_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_security_sets_id_seq_view'
);
ALTER FOREIGN TABLE public.project_security_sets_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: project_vulnerability_reports; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_vulnerability_reports (
    id integer DEFAULT public.project_vulnerability_reports_id_seq_view() NOT NULL,
    project_id integer,
    etag character varying(255),
    vulnerability_score numeric,
    security_score numeric,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_vulnerability_reports'
);
ALTER FOREIGN TABLE public.project_vulnerability_reports ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.project_vulnerability_reports ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.project_vulnerability_reports ALTER COLUMN etag OPTIONS (
    column_name 'etag'
);
ALTER FOREIGN TABLE public.project_vulnerability_reports ALTER COLUMN vulnerability_score OPTIONS (
    column_name 'vulnerability_score'
);
ALTER FOREIGN TABLE public.project_vulnerability_reports ALTER COLUMN security_score OPTIONS (
    column_name 'security_score'
);
ALTER FOREIGN TABLE public.project_vulnerability_reports ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.project_vulnerability_reports ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: project_vulnerability_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.project_vulnerability_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_vulnerability_reports_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.project_vulnerability_reports_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_vulnerability_reports_id_seq_view'
);
ALTER FOREIGN TABLE public.project_vulnerability_reports_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: projects_by_month; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.projects_by_month (
    month timestamp without time zone,
    project_count bigint
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'projects_by_month'
);
ALTER FOREIGN TABLE public.projects_by_month ALTER COLUMN month OPTIONS (
    column_name 'month'
);
ALTER FOREIGN TABLE public.projects_by_month ALTER COLUMN project_count OPTIONS (
    column_name 'project_count'
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.projects_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'projects_id_seq_view'
);
ALTER FOREIGN TABLE public.projects_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: ratings; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.ratings (
    id integer DEFAULT public.ratings_id_seq_view() NOT NULL,
    account_id integer NOT NULL,
    project_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('UTC'::text, now()),
    updated_at timestamp without time zone DEFAULT timezone('UTC'::text, now())
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'ratings'
);
ALTER FOREIGN TABLE public.ratings ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.ratings ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.ratings ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.ratings ALTER COLUMN score OPTIONS (
    column_name 'score'
);
ALTER FOREIGN TABLE public.ratings ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.ratings ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: ratings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ratings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ratings_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.ratings_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'ratings_id_seq_view'
);
ALTER FOREIGN TABLE public.ratings_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: recently_active_accounts_cache; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.recently_active_accounts_cache (
    id integer DEFAULT public.recently_active_accounts_cache_id_seq_view() NOT NULL,
    accounts text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'recently_active_accounts_cache'
);
ALTER FOREIGN TABLE public.recently_active_accounts_cache ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.recently_active_accounts_cache ALTER COLUMN accounts OPTIONS (
    column_name 'accounts'
);
ALTER FOREIGN TABLE public.recently_active_accounts_cache ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.recently_active_accounts_cache ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: recently_active_accounts_cache_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recently_active_accounts_cache_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recently_active_accounts_cache_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.recently_active_accounts_cache_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'recently_active_accounts_cache_id_seq_view'
);
ALTER FOREIGN TABLE public.recently_active_accounts_cache_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: recommend_entries; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.recommend_entries (
    id bigint DEFAULT public.recommend_entries_id_seq_view() NOT NULL,
    project_id integer,
    project_id_recommends integer,
    weight double precision
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'recommend_entries'
);
ALTER FOREIGN TABLE public.recommend_entries ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.recommend_entries ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.recommend_entries ALTER COLUMN project_id_recommends OPTIONS (
    column_name 'project_id_recommends'
);
ALTER FOREIGN TABLE public.recommend_entries ALTER COLUMN weight OPTIONS (
    column_name 'weight'
);


--
-- Name: recommend_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recommend_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommend_entries_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.recommend_entries_id_seq_view (
    id bigint
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'recommend_entries_id_seq_view'
);
ALTER FOREIGN TABLE public.recommend_entries_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: recommendations; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.recommendations (
    id integer DEFAULT public.recommendations_id_seq_view() NOT NULL,
    invitor_id integer NOT NULL,
    invitee_id integer,
    invitee_email text NOT NULL,
    updated_at timestamp without time zone,
    created_at timestamp without time zone,
    project_id integer,
    activation_code text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'recommendations'
);
ALTER FOREIGN TABLE public.recommendations ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.recommendations ALTER COLUMN invitor_id OPTIONS (
    column_name 'invitor_id'
);
ALTER FOREIGN TABLE public.recommendations ALTER COLUMN invitee_id OPTIONS (
    column_name 'invitee_id'
);
ALTER FOREIGN TABLE public.recommendations ALTER COLUMN invitee_email OPTIONS (
    column_name 'invitee_email'
);
ALTER FOREIGN TABLE public.recommendations ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.recommendations ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.recommendations ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.recommendations ALTER COLUMN activation_code OPTIONS (
    column_name 'activation_code'
);


--
-- Name: recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendations_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.recommendations_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'recommendations_id_seq_view'
);
ALTER FOREIGN TABLE public.recommendations_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: registration_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registration_keys (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    client_name text NOT NULL,
    description text
);


--
-- Name: releases; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.releases (
    id integer DEFAULT public.releases_id_seq_view() NOT NULL,
    kb_release_id character varying NOT NULL,
    released_on timestamp without time zone,
    version character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    project_security_set_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'releases'
);
ALTER FOREIGN TABLE public.releases ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.releases ALTER COLUMN kb_release_id OPTIONS (
    column_name 'kb_release_id'
);
ALTER FOREIGN TABLE public.releases ALTER COLUMN released_on OPTIONS (
    column_name 'released_on'
);
ALTER FOREIGN TABLE public.releases ALTER COLUMN version OPTIONS (
    column_name 'version'
);
ALTER FOREIGN TABLE public.releases ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.releases ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.releases ALTER COLUMN project_security_set_id OPTIONS (
    column_name 'project_security_set_id'
);


--
-- Name: releases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.releases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releases_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.releases_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'releases_id_seq_view'
);
ALTER FOREIGN TABLE public.releases_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: releases_vulnerabilities; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.releases_vulnerabilities (
    release_id integer NOT NULL,
    vulnerability_id integer NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'releases_vulnerabilities'
);
ALTER FOREIGN TABLE public.releases_vulnerabilities ALTER COLUMN release_id OPTIONS (
    column_name 'release_id'
);
ALTER FOREIGN TABLE public.releases_vulnerabilities ALTER COLUMN vulnerability_id OPTIONS (
    column_name 'vulnerability_id'
);


--
-- Name: reports; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.reports (
    id integer DEFAULT public.reports_id_seq_view() NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'reports'
);
ALTER FOREIGN TABLE public.reports ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.reports ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.reports ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.reports ALTER COLUMN title OPTIONS (
    column_name 'title'
);


--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.reports_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'reports_id_seq_view'
);
ALTER FOREIGN TABLE public.reports_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repositories (
    id integer NOT NULL,
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
-- Name: repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repositories_id_seq OWNED BY public.repositories.id;


--
-- Name: repositories_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.repositories_id_seq_view AS
 SELECT (nextval('public.repositories_id_seq'::regclass))::integer AS id;


--
-- Name: repository_directories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repository_directories (
    id integer NOT NULL,
    code_location_id integer,
    repository_id integer,
    fetched_at timestamp without time zone
);


--
-- Name: repository_directories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repository_directories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repository_directories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repository_directories_id_seq OWNED BY public.repository_directories.id;


--
-- Name: repository_directories_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.repository_directories_id_seq_view AS
 SELECT (nextval('public.repository_directories_id_seq'::regclass))::integer AS id;


--
-- Name: repository_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repository_tags (
    id integer NOT NULL,
    repository_id integer,
    name text,
    commit_sha1 text,
    message text,
    "timestamp" timestamp without time zone
);


--
-- Name: repository_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repository_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repository_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repository_tags_id_seq OWNED BY public.repository_tags.id;


--
-- Name: repository_tags_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.repository_tags_id_seq_view AS
 SELECT (nextval('public.repository_tags_id_seq'::regclass))::integer AS id;


--
-- Name: reverification_trackers; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.reverification_trackers (
    id integer DEFAULT public.reverification_trackers_id_seq_view() NOT NULL,
    account_id integer NOT NULL,
    message_id character varying NOT NULL,
    phase integer DEFAULT 0,
    status integer DEFAULT 0,
    feedback character varying,
    attempts integer DEFAULT 1,
    sent_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'reverification_trackers'
);
ALTER FOREIGN TABLE public.reverification_trackers ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.reverification_trackers ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.reverification_trackers ALTER COLUMN message_id OPTIONS (
    column_name 'message_id'
);
ALTER FOREIGN TABLE public.reverification_trackers ALTER COLUMN phase OPTIONS (
    column_name 'phase'
);
ALTER FOREIGN TABLE public.reverification_trackers ALTER COLUMN status OPTIONS (
    column_name 'status'
);
ALTER FOREIGN TABLE public.reverification_trackers ALTER COLUMN feedback OPTIONS (
    column_name 'feedback'
);
ALTER FOREIGN TABLE public.reverification_trackers ALTER COLUMN attempts OPTIONS (
    column_name 'attempts'
);
ALTER FOREIGN TABLE public.reverification_trackers ALTER COLUMN sent_at OPTIONS (
    column_name 'sent_at'
);
ALTER FOREIGN TABLE public.reverification_trackers ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.reverification_trackers ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: reverification_trackers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reverification_trackers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reverification_trackers_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.reverification_trackers_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'reverification_trackers_id_seq_view'
);
ALTER FOREIGN TABLE public.reverification_trackers_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: reviews; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.reviews (
    id integer DEFAULT public.reviews_id_seq_view() NOT NULL,
    account_id integer NOT NULL,
    project_id integer NOT NULL,
    title text,
    comment text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    helpful_score integer DEFAULT 0 NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'reviews'
);
ALTER FOREIGN TABLE public.reviews ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.reviews ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.reviews ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.reviews ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE public.reviews ALTER COLUMN comment OPTIONS (
    column_name 'comment'
);
ALTER FOREIGN TABLE public.reviews ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.reviews ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.reviews ALTER COLUMN helpful_score OPTIONS (
    column_name 'helpful_score'
);


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.reviews_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'reviews_id_seq_view'
);
ALTER FOREIGN TABLE public.reviews_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: robins_contributions_test; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.robins_contributions_test (
    id bigint,
    person_id bigint,
    project_id integer,
    name_fact_id integer,
    position_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'robins_contributions_test'
);
ALTER FOREIGN TABLE public.robins_contributions_test ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.robins_contributions_test ALTER COLUMN person_id OPTIONS (
    column_name 'person_id'
);
ALTER FOREIGN TABLE public.robins_contributions_test ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.robins_contributions_test ALTER COLUMN name_fact_id OPTIONS (
    column_name 'name_fact_id'
);
ALTER FOREIGN TABLE public.robins_contributions_test ALTER COLUMN position_id OPTIONS (
    column_name 'position_id'
);


--
-- Name: rss_articles; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.rss_articles (
    id integer DEFAULT public.rss_articles_id_seq_view() NOT NULL,
    rss_feed_id integer,
    guid text NOT NULL,
    "time" timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    title text NOT NULL,
    description text,
    author text,
    link text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'rss_articles'
);
ALTER FOREIGN TABLE public.rss_articles ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.rss_articles ALTER COLUMN rss_feed_id OPTIONS (
    column_name 'rss_feed_id'
);
ALTER FOREIGN TABLE public.rss_articles ALTER COLUMN guid OPTIONS (
    column_name 'guid'
);
ALTER FOREIGN TABLE public.rss_articles ALTER COLUMN "time" OPTIONS (
    column_name 'time'
);
ALTER FOREIGN TABLE public.rss_articles ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE public.rss_articles ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE public.rss_articles ALTER COLUMN author OPTIONS (
    column_name 'author'
);
ALTER FOREIGN TABLE public.rss_articles ALTER COLUMN link OPTIONS (
    column_name 'link'
);


--
-- Name: rss_articles_2; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.rss_articles_2 (
    id integer,
    rss_feed_id integer,
    guid text,
    "time" timestamp without time zone,
    title text,
    description text,
    author text,
    link text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'rss_articles_2'
);
ALTER FOREIGN TABLE public.rss_articles_2 ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.rss_articles_2 ALTER COLUMN rss_feed_id OPTIONS (
    column_name 'rss_feed_id'
);
ALTER FOREIGN TABLE public.rss_articles_2 ALTER COLUMN guid OPTIONS (
    column_name 'guid'
);
ALTER FOREIGN TABLE public.rss_articles_2 ALTER COLUMN "time" OPTIONS (
    column_name 'time'
);
ALTER FOREIGN TABLE public.rss_articles_2 ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE public.rss_articles_2 ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE public.rss_articles_2 ALTER COLUMN author OPTIONS (
    column_name 'author'
);
ALTER FOREIGN TABLE public.rss_articles_2 ALTER COLUMN link OPTIONS (
    column_name 'link'
);


--
-- Name: rss_articles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rss_articles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rss_articles_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.rss_articles_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'rss_articles_id_seq_view'
);
ALTER FOREIGN TABLE public.rss_articles_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: rss_feeds; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.rss_feeds (
    id integer DEFAULT public.rss_feeds_id_seq_view() NOT NULL,
    url text NOT NULL,
    last_fetch timestamp without time zone,
    next_fetch timestamp without time zone,
    error text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'rss_feeds'
);
ALTER FOREIGN TABLE public.rss_feeds ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.rss_feeds ALTER COLUMN url OPTIONS (
    column_name 'url'
);
ALTER FOREIGN TABLE public.rss_feeds ALTER COLUMN last_fetch OPTIONS (
    column_name 'last_fetch'
);
ALTER FOREIGN TABLE public.rss_feeds ALTER COLUMN next_fetch OPTIONS (
    column_name 'next_fetch'
);
ALTER FOREIGN TABLE public.rss_feeds ALTER COLUMN error OPTIONS (
    column_name 'error'
);


--
-- Name: rss_feeds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rss_feeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rss_feeds_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.rss_feeds_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'rss_feeds_id_seq_view'
);
ALTER FOREIGN TABLE public.rss_feeds_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: rss_subscriptions; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.rss_subscriptions (
    id integer DEFAULT public.rss_subscriptions_id_seq_view() NOT NULL,
    project_id integer,
    rss_feed_id integer,
    deleted boolean DEFAULT false
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'rss_subscriptions'
);
ALTER FOREIGN TABLE public.rss_subscriptions ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.rss_subscriptions ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.rss_subscriptions ALTER COLUMN rss_feed_id OPTIONS (
    column_name 'rss_feed_id'
);
ALTER FOREIGN TABLE public.rss_subscriptions ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
);


--
-- Name: rss_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rss_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rss_subscriptions_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.rss_subscriptions_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'rss_subscriptions_id_seq_view'
);
ALTER FOREIGN TABLE public.rss_subscriptions_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sessions; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.sessions (
    id integer DEFAULT public.sessions_id_seq_view() NOT NULL,
    session_id character varying(255),
    data text,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'sessions'
);
ALTER FOREIGN TABLE public.sessions ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.sessions ALTER COLUMN session_id OPTIONS (
    column_name 'session_id'
);
ALTER FOREIGN TABLE public.sessions ALTER COLUMN data OPTIONS (
    column_name 'data'
);
ALTER FOREIGN TABLE public.sessions ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.sessions_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'sessions_id_seq_view'
);
ALTER FOREIGN TABLE public.sessions_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: settings; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.settings (
    id integer DEFAULT public.settings_id_seq_view() NOT NULL,
    key character varying,
    value character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'settings'
);
ALTER FOREIGN TABLE public.settings ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.settings ALTER COLUMN key OPTIONS (
    column_name 'key'
);
ALTER FOREIGN TABLE public.settings ALTER COLUMN value OPTIONS (
    column_name 'value'
);
ALTER FOREIGN TABLE public.settings ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.settings ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.settings_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'settings_id_seq_view'
);
ALTER FOREIGN TABLE public.settings_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: sf_vhosted; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.sf_vhosted (
    domain text NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'sf_vhosted'
);
ALTER FOREIGN TABLE public.sf_vhosted ALTER COLUMN domain OPTIONS (
    column_name 'domain'
);


--
-- Name: sfprojects; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.sfprojects (
    project_id integer NOT NULL,
    hosted boolean DEFAULT false,
    vhosted boolean DEFAULT false,
    code boolean DEFAULT false,
    downloads boolean DEFAULT false,
    downloads_vhosted boolean DEFAULT false
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'sfprojects'
);
ALTER FOREIGN TABLE public.sfprojects ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.sfprojects ALTER COLUMN hosted OPTIONS (
    column_name 'hosted'
);
ALTER FOREIGN TABLE public.sfprojects ALTER COLUMN vhosted OPTIONS (
    column_name 'vhosted'
);
ALTER FOREIGN TABLE public.sfprojects ALTER COLUMN code OPTIONS (
    column_name 'code'
);
ALTER FOREIGN TABLE public.sfprojects ALTER COLUMN downloads OPTIONS (
    column_name 'downloads'
);
ALTER FOREIGN TABLE public.sfprojects ALTER COLUMN downloads_vhosted OPTIONS (
    column_name 'downloads_vhosted'
);


--
-- Name: size_facts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.size_facts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'size_facts_id_seq_view'
);
ALTER FOREIGN TABLE public.size_facts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: slave_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slave_logs (
    id bigint NOT NULL,
    message text,
    created_on timestamp without time zone,
    slave_id integer,
    job_id integer,
    code_set_id integer,
    level integer DEFAULT 0
);


--
-- Name: slave_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.slave_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slave_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.slave_logs_id_seq OWNED BY public.slave_logs.id;


--
-- Name: slave_logs_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.slave_logs_id_seq_view AS
 SELECT nextval('public.slave_logs_id_seq'::regclass) AS id;


--
-- Name: slaves; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slaves (
    id integer NOT NULL,
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
    blocked_types text
);


--
-- Name: slave_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.slave_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slave_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.slave_permissions_id_seq OWNED BY public.slaves.id;


--
-- Name: slave_permissions_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.slave_permissions_id_seq_view AS
 SELECT (nextval('public.slave_permissions_id_seq'::regclass))::integer AS id;


--
-- Name: sloc_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sloc_metrics (
    id bigint NOT NULL,
    diff_id bigint,
    language_id integer,
    code_added integer DEFAULT 0 NOT NULL,
    code_removed integer DEFAULT 0 NOT NULL,
    comments_added integer DEFAULT 0 NOT NULL,
    comments_removed integer DEFAULT 0 NOT NULL,
    blanks_added integer DEFAULT 0 NOT NULL,
    blanks_removed integer DEFAULT 0 NOT NULL,
    sloc_set_id integer NOT NULL
);


--
-- Name: sloc_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sloc_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sloc_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sloc_metrics_id_seq OWNED BY public.sloc_metrics.id;


--
-- Name: sloc_metrics_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sloc_metrics_id_seq_view AS
 SELECT (nextval('public.sloc_metrics_id_seq'::regclass))::integer AS id;


--
-- Name: sloc_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sloc_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sloc_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sloc_sets_id_seq OWNED BY public.sloc_sets.id;


--
-- Name: sloc_sets_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sloc_sets_id_seq_view AS
 SELECT (nextval('public.sloc_sets_id_seq'::regclass))::integer AS id;


--
-- Name: stack_entries; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.stack_entries (
    id integer DEFAULT public.stack_entries_id_seq_view() NOT NULL,
    stack_id integer,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    note text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'stack_entries'
);
ALTER FOREIGN TABLE public.stack_entries ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.stack_entries ALTER COLUMN stack_id OPTIONS (
    column_name 'stack_id'
);
ALTER FOREIGN TABLE public.stack_entries ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.stack_entries ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.stack_entries ALTER COLUMN deleted_at OPTIONS (
    column_name 'deleted_at'
);
ALTER FOREIGN TABLE public.stack_entries ALTER COLUMN note OPTIONS (
    column_name 'note'
);


--
-- Name: stack_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stack_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stack_entries_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.stack_entries_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'stack_entries_id_seq_view'
);
ALTER FOREIGN TABLE public.stack_entries_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: stack_ignores; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.stack_ignores (
    id integer DEFAULT public.stack_ignores_id_seq_view() NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    stack_id integer NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'stack_ignores'
);
ALTER FOREIGN TABLE public.stack_ignores ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.stack_ignores ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.stack_ignores ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.stack_ignores ALTER COLUMN stack_id OPTIONS (
    column_name 'stack_id'
);


--
-- Name: stack_ignores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stack_ignores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stack_ignores_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.stack_ignores_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'stack_ignores_id_seq_view'
);
ALTER FOREIGN TABLE public.stack_ignores_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: stacks; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.stacks (
    id integer DEFAULT public.stacks_id_seq_view() NOT NULL,
    account_id integer,
    session_id character varying(255),
    project_count integer DEFAULT 0,
    updated_at timestamp without time zone,
    title text,
    description text,
    project_id integer,
    deleted_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'stacks'
);
ALTER FOREIGN TABLE public.stacks ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.stacks ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.stacks ALTER COLUMN session_id OPTIONS (
    column_name 'session_id'
);
ALTER FOREIGN TABLE public.stacks ALTER COLUMN project_count OPTIONS (
    column_name 'project_count'
);
ALTER FOREIGN TABLE public.stacks ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.stacks ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE public.stacks ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE public.stacks ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.stacks ALTER COLUMN deleted_at OPTIONS (
    column_name 'deleted_at'
);


--
-- Name: stacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stacks_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.stacks_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'stacks_id_seq_view'
);
ALTER FOREIGN TABLE public.stacks_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id integer NOT NULL,
    code_location_id integer NOT NULL,
    registration_key_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    client_relation_id integer
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: successful_accounts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.successful_accounts (
    id integer DEFAULT public.successful_accounts_id_seq_view() NOT NULL,
    account_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'successful_accounts'
);
ALTER FOREIGN TABLE public.successful_accounts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.successful_accounts ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);


--
-- Name: successful_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.successful_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: successful_accounts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.successful_accounts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'successful_accounts_id_seq_view'
);
ALTER FOREIGN TABLE public.successful_accounts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: taggings; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.taggings (
    id integer DEFAULT public.taggings_id_seq_view() NOT NULL,
    tag_id integer,
    taggable_id integer,
    taggable_type character varying(255)
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'taggings'
);
ALTER FOREIGN TABLE public.taggings ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.taggings ALTER COLUMN tag_id OPTIONS (
    column_name 'tag_id'
);
ALTER FOREIGN TABLE public.taggings ALTER COLUMN taggable_id OPTIONS (
    column_name 'taggable_id'
);
ALTER FOREIGN TABLE public.taggings ALTER COLUMN taggable_type OPTIONS (
    column_name 'taggable_type'
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.taggings_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'taggings_id_seq_view'
);
ALTER FOREIGN TABLE public.taggings_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: tags; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.tags (
    id integer DEFAULT public.tags_id_seq_view() NOT NULL,
    name text NOT NULL,
    taggings_count integer DEFAULT 0 NOT NULL,
    weight double precision DEFAULT 1.0 NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'tags'
);
ALTER FOREIGN TABLE public.tags ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.tags ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE public.tags ALTER COLUMN taggings_count OPTIONS (
    column_name 'taggings_count'
);
ALTER FOREIGN TABLE public.tags ALTER COLUMN weight OPTIONS (
    column_name 'weight'
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.tags_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'tags_id_seq_view'
);
ALTER FOREIGN TABLE public.tags_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: thirty_day_summaries; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.thirty_day_summaries (
    id integer DEFAULT public.thirty_day_summaries_id_seq_view() NOT NULL,
    analysis_id integer NOT NULL,
    committer_count integer,
    commit_count integer,
    files_modified integer,
    lines_added integer,
    lines_removed integer,
    created_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'thirty_day_summaries'
);
ALTER FOREIGN TABLE public.thirty_day_summaries ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.thirty_day_summaries ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE public.thirty_day_summaries ALTER COLUMN committer_count OPTIONS (
    column_name 'committer_count'
);
ALTER FOREIGN TABLE public.thirty_day_summaries ALTER COLUMN commit_count OPTIONS (
    column_name 'commit_count'
);
ALTER FOREIGN TABLE public.thirty_day_summaries ALTER COLUMN files_modified OPTIONS (
    column_name 'files_modified'
);
ALTER FOREIGN TABLE public.thirty_day_summaries ALTER COLUMN lines_added OPTIONS (
    column_name 'lines_added'
);
ALTER FOREIGN TABLE public.thirty_day_summaries ALTER COLUMN lines_removed OPTIONS (
    column_name 'lines_removed'
);
ALTER FOREIGN TABLE public.thirty_day_summaries ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);


--
-- Name: thirty_day_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thirty_day_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thirty_day_summaries_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.thirty_day_summaries_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'thirty_day_summaries_id_seq_view'
);
ALTER FOREIGN TABLE public.thirty_day_summaries_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: tools; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.tools (
    id integer DEFAULT public.tools_id_seq_view() NOT NULL,
    name text NOT NULL,
    description text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'tools'
);
ALTER FOREIGN TABLE public.tools ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.tools ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE public.tools ALTER COLUMN description OPTIONS (
    column_name 'description'
);


--
-- Name: tools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tools_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.tools_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'tools_id_seq_view'
);
ALTER FOREIGN TABLE public.tools_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: topics; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.topics (
    id integer DEFAULT public.topics_id_seq_view() NOT NULL,
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'topics'
);
ALTER FOREIGN TABLE public.topics ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.topics ALTER COLUMN forum_id OPTIONS (
    column_name 'forum_id'
);
ALTER FOREIGN TABLE public.topics ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.topics ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE public.topics ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.topics ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.topics ALTER COLUMN hits OPTIONS (
    column_name 'hits'
);
ALTER FOREIGN TABLE public.topics ALTER COLUMN sticky OPTIONS (
    column_name 'sticky'
);
ALTER FOREIGN TABLE public.topics ALTER COLUMN posts_count OPTIONS (
    column_name 'posts_count'
);
ALTER FOREIGN TABLE public.topics ALTER COLUMN replied_at OPTIONS (
    column_name 'replied_at'
);
ALTER FOREIGN TABLE public.topics ALTER COLUMN closed OPTIONS (
    column_name 'closed'
);
ALTER FOREIGN TABLE public.topics ALTER COLUMN replied_by OPTIONS (
    column_name 'replied_by'
);
ALTER FOREIGN TABLE public.topics ALTER COLUMN last_post_id OPTIONS (
    column_name 'last_post_id'
);


--
-- Name: topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topics_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.topics_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'topics_id_seq_view'
);
ALTER FOREIGN TABLE public.topics_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
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
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: verifications; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.verifications (
    id integer DEFAULT public.verifications_id_seq_view() NOT NULL,
    account_id integer,
    type character varying,
    token character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unique_id character varying
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'verifications'
);
ALTER FOREIGN TABLE public.verifications ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.verifications ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.verifications ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE public.verifications ALTER COLUMN token OPTIONS (
    column_name 'token'
);
ALTER FOREIGN TABLE public.verifications ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.verifications ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.verifications ALTER COLUMN unique_id OPTIONS (
    column_name 'unique_id'
);


--
-- Name: verifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.verifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: verifications_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.verifications_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'verifications_id_seq_view'
);
ALTER FOREIGN TABLE public.verifications_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: vita_analyses; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.vita_analyses (
    id bigint DEFAULT public.vita_analyses_id_seq_view() NOT NULL,
    vita_id integer,
    analysis_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'vita_analyses'
);
ALTER FOREIGN TABLE public.vita_analyses ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.vita_analyses ALTER COLUMN vita_id OPTIONS (
    column_name 'vita_id'
);
ALTER FOREIGN TABLE public.vita_analyses ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);


--
-- Name: vita_analyses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vita_analyses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vita_analyses_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.vita_analyses_id_seq_view (
    id bigint
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'vita_analyses_id_seq_view'
);
ALTER FOREIGN TABLE public.vita_analyses_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: vitae; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.vitae (
    id integer DEFAULT public.vitae_id_seq_view() NOT NULL,
    account_id integer NOT NULL,
    created_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'vitae'
);
ALTER FOREIGN TABLE public.vitae ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.vitae ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE public.vitae ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);


--
-- Name: vitae_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vitae_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vitae_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.vitae_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'vitae_id_seq_view'
);
ALTER FOREIGN TABLE public.vitae_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: vulnerabilities; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.vulnerabilities (
    id integer DEFAULT public.vulnerabilities_id_seq_view() NOT NULL,
    cve_id character varying NOT NULL,
    generated_on timestamp without time zone,
    published_on timestamp without time zone,
    severity integer,
    score numeric,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'vulnerabilities'
);
ALTER FOREIGN TABLE public.vulnerabilities ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE public.vulnerabilities ALTER COLUMN cve_id OPTIONS (
    column_name 'cve_id'
);
ALTER FOREIGN TABLE public.vulnerabilities ALTER COLUMN generated_on OPTIONS (
    column_name 'generated_on'
);
ALTER FOREIGN TABLE public.vulnerabilities ALTER COLUMN published_on OPTIONS (
    column_name 'published_on'
);
ALTER FOREIGN TABLE public.vulnerabilities ALTER COLUMN severity OPTIONS (
    column_name 'severity'
);
ALTER FOREIGN TABLE public.vulnerabilities ALTER COLUMN score OPTIONS (
    column_name 'score'
);
ALTER FOREIGN TABLE public.vulnerabilities ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE public.vulnerabilities ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE public.vulnerabilities ALTER COLUMN description OPTIONS (
    column_name 'description'
);


--
-- Name: vulnerabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vulnerabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vulnerabilities_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.vulnerabilities_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'vulnerabilities_id_seq_view'
);
ALTER FOREIGN TABLE public.vulnerabilities_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: vw_projecturlnameedits; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE public.vw_projecturlnameedits (
    project_id integer,
    value text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'vw_projecturlnameedits'
);
ALTER FOREIGN TABLE public.vw_projecturlnameedits ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE public.vw_projecturlnameedits ALTER COLUMN value OPTIONS (
    column_name 'value'
);


--
-- Name: admin_dashboard_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_dashboard_stats ALTER COLUMN id SET DEFAULT nextval('public.admin_dashboard_stats_id_seq'::regclass);


--
-- Name: analysis_aliases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analysis_aliases ALTER COLUMN id SET DEFAULT nextval('public.analysis_aliases_id_seq'::regclass);


--
-- Name: analysis_sloc_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analysis_sloc_sets ALTER COLUMN id SET DEFAULT nextval('public.analysis_sloc_sets_id_seq'::regclass);


--
-- Name: code_location_job_feeders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.code_location_job_feeders ALTER COLUMN id SET DEFAULT nextval('public.code_location_job_feeders_id_seq'::regclass);


--
-- Name: code_location_tarballs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.code_location_tarballs ALTER COLUMN id SET DEFAULT nextval('public.code_location_tarballs_id_seq'::regclass);


--
-- Name: code_locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.code_locations ALTER COLUMN id SET DEFAULT nextval('public.code_locations_id_seq'::regclass);


--
-- Name: code_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.code_sets ALTER COLUMN id SET DEFAULT nextval('public.code_sets_id_seq'::regclass);


--
-- Name: commit_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commit_flags ALTER COLUMN id SET DEFAULT nextval('public.commit_flags_id_seq'::regclass);


--
-- Name: commits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commits ALTER COLUMN id SET DEFAULT nextval('public.commits_id_seq'::regclass);


--
-- Name: diffs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diffs ALTER COLUMN id SET DEFAULT nextval('public.diffs_id_seq'::regclass);


--
-- Name: email_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_addresses ALTER COLUMN id SET DEFAULT nextval('public.email_addresses_id_seq'::regclass);


--
-- Name: failure_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failure_groups ALTER COLUMN id SET DEFAULT nextval('public.failure_groups_id_seq'::regclass);


--
-- Name: fisbot_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fisbot_events ALTER COLUMN id SET DEFAULT nextval('public.fisbot_events_id_seq'::regclass);


--
-- Name: forges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forges ALTER COLUMN id SET DEFAULT nextval('public.forges_id_seq'::regclass);


--
-- Name: fyles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fyles ALTER COLUMN id SET DEFAULT nextval('public.fyles_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: load_averages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.load_averages ALTER COLUMN id SET DEFAULT nextval('public.load_averages_id_seq'::regclass);


--
-- Name: old_code_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.old_code_sets ALTER COLUMN id SET DEFAULT nextval('public.old_code_sets_id_seq'::regclass);


--
-- Name: repositories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories ALTER COLUMN id SET DEFAULT nextval('public.repositories_id_seq'::regclass);


--
-- Name: repository_directories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_directories ALTER COLUMN id SET DEFAULT nextval('public.repository_directories_id_seq'::regclass);


--
-- Name: repository_tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_tags ALTER COLUMN id SET DEFAULT nextval('public.repository_tags_id_seq'::regclass);


--
-- Name: slave_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slave_logs ALTER COLUMN id SET DEFAULT nextval('public.slave_logs_id_seq'::regclass);


--
-- Name: slaves id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slaves ALTER COLUMN id SET DEFAULT nextval('public.slave_permissions_id_seq'::regclass);


--
-- Name: sloc_metrics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sloc_metrics ALTER COLUMN id SET DEFAULT nextval('public.sloc_metrics_id_seq'::regclass);


--
-- Name: sloc_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sloc_sets ALTER COLUMN id SET DEFAULT nextval('public.sloc_sets_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: admin_dashboard_stats admin_dashboard_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_dashboard_stats
    ADD CONSTRAINT admin_dashboard_stats_pkey PRIMARY KEY (id);


--
-- Name: analysis_aliases analysis_aliases_analysis_id_commit_name_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analysis_aliases
    ADD CONSTRAINT analysis_aliases_analysis_id_commit_name_id UNIQUE (analysis_id, commit_name_id);


--
-- Name: analysis_aliases analysis_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analysis_aliases
    ADD CONSTRAINT analysis_aliases_pkey PRIMARY KEY (id);


--
-- Name: analysis_sloc_sets analysis_sloc_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analysis_sloc_sets
    ADD CONSTRAINT analysis_sloc_sets_pkey PRIMARY KEY (id);


--
-- Name: code_location_job_feeders code_location_job_feeders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.code_location_job_feeders
    ADD CONSTRAINT code_location_job_feeders_pkey PRIMARY KEY (id);


--
-- Name: code_location_tarballs code_location_tarballs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.code_location_tarballs
    ADD CONSTRAINT code_location_tarballs_pkey PRIMARY KEY (id);


--
-- Name: code_locations code_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.code_locations
    ADD CONSTRAINT code_locations_pkey PRIMARY KEY (id);


--
-- Name: code_sets code_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.code_sets
    ADD CONSTRAINT code_sets_pkey PRIMARY KEY (id);


--
-- Name: commit_flags commit_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commit_flags
    ADD CONSTRAINT commit_flags_pkey PRIMARY KEY (id);


--
-- Name: commits commits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commits
    ADD CONSTRAINT commits_pkey PRIMARY KEY (id);


--
-- Name: diffs diffs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diffs
    ADD CONSTRAINT diffs_pkey PRIMARY KEY (id);


--
-- Name: email_addresses email_addresses_address_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_addresses
    ADD CONSTRAINT email_addresses_address_key UNIQUE (address);


--
-- Name: email_addresses email_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_addresses
    ADD CONSTRAINT email_addresses_pkey PRIMARY KEY (id);


--
-- Name: failure_groups failure_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failure_groups
    ADD CONSTRAINT failure_groups_pkey PRIMARY KEY (id);


--
-- Name: fisbot_events fisbot_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fisbot_events
    ADD CONSTRAINT fisbot_events_pkey PRIMARY KEY (id);


--
-- Name: forges forges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forges
    ADD CONSTRAINT forges_pkey PRIMARY KEY (id);


--
-- Name: forges forges_type_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forges
    ADD CONSTRAINT forges_type_key UNIQUE (type);


--
-- Name: fyles fyles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fyles
    ADD CONSTRAINT fyles_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: load_averages load_averages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.load_averages
    ADD CONSTRAINT load_averages_pkey PRIMARY KEY (id);


--
-- Name: old_code_sets old_code_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.old_code_sets
    ADD CONSTRAINT old_code_sets_pkey PRIMARY KEY (id);


--
-- Name: registration_keys registration_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration_keys
    ADD CONSTRAINT registration_keys_pkey PRIMARY KEY (id);


--
-- Name: repositories repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: repository_directories repository_directories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_directories
    ADD CONSTRAINT repository_directories_pkey PRIMARY KEY (id);


--
-- Name: repository_tags repository_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_tags
    ADD CONSTRAINT repository_tags_pkey PRIMARY KEY (id);


--
-- Name: slave_logs slave_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slave_logs
    ADD CONSTRAINT slave_logs_pkey PRIMARY KEY (id);


--
-- Name: slaves slave_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slaves
    ADD CONSTRAINT slave_permissions_pkey PRIMARY KEY (id);


--
-- Name: sloc_sets sloc_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sloc_sets
    ADD CONSTRAINT sloc_sets_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: diffs unique_diffs_on_commit_id_fyle_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diffs
    ADD CONSTRAINT unique_diffs_on_commit_id_fyle_id UNIQUE (commit_id, fyle_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: foo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX foo ON public.slaves USING btree (clump_status) WHERE (oldest_clump_timestamp IS NOT NULL);


--
-- Name: index_admin_dashboard_stats_on_data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_dashboard_stats_on_data ON public.admin_dashboard_stats USING gin (data);


--
-- Name: index_admin_dashboard_stats_on_stat_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_dashboard_stats_on_stat_type ON public.admin_dashboard_stats USING btree (stat_type);


--
-- Name: index_analysis_aliases_on_analysis_id_preferred_name_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_analysis_aliases_on_analysis_id_preferred_name_id ON public.analysis_aliases USING btree (analysis_id, preferred_name_id);


--
-- Name: index_analysis_sloc_sets_on_analysis_id_sloc_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_analysis_sloc_sets_on_analysis_id_sloc_set_id ON public.analysis_sloc_sets USING btree (analysis_id, sloc_set_id);


--
-- Name: index_analysis_sloc_sets_on_sloc_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_analysis_sloc_sets_on_sloc_set_id ON public.analysis_sloc_sets USING btree (sloc_set_id);


--
-- Name: index_code_location_tarballs_on_code_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_location_tarballs_on_code_location_id ON public.code_location_tarballs USING btree (code_location_id);


--
-- Name: index_code_location_tarballs_on_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_location_tarballs_on_reference ON public.code_location_tarballs USING btree (reference);


--
-- Name: index_code_locations_last_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_code_locations_last_job_id ON public.code_locations USING btree (last_job_id);


--
-- Name: index_code_locations_on_best_code_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_locations_on_best_code_set_id ON public.code_locations USING btree (best_code_set_id);


--
-- Name: index_code_locations_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_locations_on_repository_id ON public.code_locations USING btree (repository_id);


--
-- Name: index_code_locations_on_repository_id_and_module_branch_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_code_locations_on_repository_id_and_module_branch_name ON public.code_locations USING btree (repository_id, module_branch_name);


--
-- Name: index_code_sets_on_best_sloc_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_sets_on_best_sloc_set_id ON public.code_sets USING btree (best_sloc_set_id);


--
-- Name: index_code_sets_on_code_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_sets_on_code_location_id ON public.code_sets USING btree (code_location_id);


--
-- Name: index_code_sets_on_logged_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_sets_on_logged_at ON public.code_sets USING btree ((COALESCE(logged_at, '1970-01-01 00:00:00'::timestamp without time zone)));


--
-- Name: index_commit_flags_on_commit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commit_flags_on_commit_id ON public.commit_flags USING btree (commit_id);


--
-- Name: index_commit_flags_on_sloc_set_id_commit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commit_flags_on_sloc_set_id_commit_id ON public.commit_flags USING btree (sloc_set_id, commit_id);


--
-- Name: index_commit_flags_on_sloc_set_id_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commit_flags_on_sloc_set_id_time ON public.commit_flags USING btree (sloc_set_id, "time" DESC);


--
-- Name: index_commits_on_code_set_id_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commits_on_code_set_id_time ON public.commits USING btree (code_set_id, "time");


--
-- Name: index_commits_on_name_id_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commits_on_name_id_month ON public.commits USING btree (name_id, date_trunc('month'::text, "time"));


--
-- Name: index_commits_on_sha1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commits_on_sha1 ON public.commits USING btree (sha1);


--
-- Name: index_diffs_on_commit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_diffs_on_commit_id ON public.diffs USING btree (commit_id);


--
-- Name: index_diffs_on_fyle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_diffs_on_fyle_id ON public.diffs USING btree (fyle_id);


--
-- Name: index_failure_groups_on_priority_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_failure_groups_on_priority_name ON public.failure_groups USING btree (priority, name);


--
-- Name: index_fisbot_events_on_code_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fisbot_events_on_code_location_id ON public.fisbot_events USING btree (code_location_id);


--
-- Name: index_fisbot_events_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fisbot_events_on_repository_id ON public.fisbot_events USING btree (repository_id);


--
-- Name: index_fyles_on_code_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fyles_on_code_set_id ON public.fyles USING btree (code_set_id);


--
-- Name: index_fyles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fyles_on_name ON public.fyles USING btree (name);


--
-- Name: index_jobs_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_account_id ON public.jobs USING btree (account_id);


--
-- Name: index_jobs_on_code_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_code_location_id ON public.jobs USING btree (code_location_id);


--
-- Name: index_jobs_on_code_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_code_set_id ON public.jobs USING btree (code_set_id);


--
-- Name: index_jobs_on_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_priority ON public.jobs USING btree (priority);


--
-- Name: index_jobs_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_project_id ON public.jobs USING btree (project_id);


--
-- Name: index_jobs_on_sloc_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_sloc_set_id ON public.jobs USING btree (sloc_set_id);


--
-- Name: index_jobs_on_status_type_wait_until; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_status_type_wait_until ON public.jobs USING btree (status, type, (COALESCE(wait_until, '1980-01-01 00:00:00'::timestamp without time zone)));


--
-- Name: index_on_commits_code_set_id_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_on_commits_code_set_id_position ON public.commits USING btree (code_set_id, "position");


--
-- Name: index_repositories_on_forge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_forge_id ON public.repositories USING btree (forge_id);


--
-- Name: index_repositories_on_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_url ON public.repositories USING btree (url);


--
-- Name: index_repository_directories_on_code_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repository_directories_on_code_location_id ON public.repository_directories USING btree (code_location_id);


--
-- Name: index_repository_directories_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repository_directories_on_repository_id ON public.repository_directories USING btree (repository_id);


--
-- Name: index_repository_tags_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repository_tags_on_repository_id ON public.repository_tags USING btree (repository_id);


--
-- Name: index_slave_logs_on_code_sets_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slave_logs_on_code_sets_id ON public.slave_logs USING btree (code_set_id);


--
-- Name: index_slave_logs_on_created_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slave_logs_on_created_on ON public.slave_logs USING btree (created_on);


--
-- Name: index_slave_logs_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slave_logs_on_job_id ON public.slave_logs USING btree (job_id);


--
-- Name: index_slave_logs_on_slave_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slave_logs_on_slave_id ON public.slave_logs USING btree (slave_id);


--
-- Name: index_sloc_metrics_on_diff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sloc_metrics_on_diff_id ON public.sloc_metrics USING btree (diff_id);


--
-- Name: index_sloc_metrics_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sloc_metrics_on_id ON public.sloc_metrics USING btree (id);


--
-- Name: index_sloc_metrics_on_sloc_set_id_language_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sloc_metrics_on_sloc_set_id_language_id ON public.sloc_metrics USING btree (sloc_set_id, language_id);


--
-- Name: index_sloc_sets_on_code_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sloc_sets_on_code_set_id ON public.sloc_sets USING btree (code_set_id);


--
-- Name: index_subscriptions_client_relation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_client_relation_id ON public.subscriptions USING btree (code_location_id, registration_key_id, client_relation_id) WHERE (client_relation_id IS NOT NULL);


--
-- Name: index_subscriptions_null_client_relation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_null_client_relation_id ON public.subscriptions USING btree (code_location_id, registration_key_id) WHERE (client_relation_id IS NULL);


--
-- Name: index_subscriptions_on_code_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_code_location_id ON public.subscriptions USING btree (code_location_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: analysis_sloc_sets analysis_sloc_sets_sloc_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analysis_sloc_sets
    ADD CONSTRAINT analysis_sloc_sets_sloc_set_id_fkey FOREIGN KEY (sloc_set_id) REFERENCES public.sloc_sets(id);


--
-- Name: commit_flags commit_flags_sloc_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commit_flags
    ADD CONSTRAINT commit_flags_sloc_set_id_fkey FOREIGN KEY (sloc_set_id) REFERENCES public.sloc_sets(id) ON DELETE CASCADE;


--
-- Name: diffs diffs_commit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diffs
    ADD CONSTRAINT diffs_commit_id_fkey FOREIGN KEY (commit_id) REFERENCES public.commits(id) ON DELETE CASCADE;


--
-- Name: diffs diffs_fyle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diffs
    ADD CONSTRAINT diffs_fyle_id_fkey FOREIGN KEY (fyle_id) REFERENCES public.fyles(id);


--
-- Name: code_locations fk_rails_0ff5ad97b1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.code_locations
    ADD CONSTRAINT fk_rails_0ff5ad97b1 FOREIGN KEY (repository_id) REFERENCES public.repositories(id);


--
-- Name: repository_tags fk_rails_275a40dd6e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_tags
    ADD CONSTRAINT fk_rails_275a40dd6e FOREIGN KEY (repository_id) REFERENCES public.repositories(id);


--
-- Name: subscriptions fk_rails_481c653bad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT fk_rails_481c653bad FOREIGN KEY (registration_key_id) REFERENCES public.registration_keys(id);


--
-- Name: repository_directories fk_rails_d33c461543; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_directories
    ADD CONSTRAINT fk_rails_d33c461543 FOREIGN KEY (code_location_id) REFERENCES public.code_locations(id);


--
-- Name: repository_directories fk_rails_d36c79e15c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_directories
    ADD CONSTRAINT fk_rails_d36c79e15c FOREIGN KEY (repository_id) REFERENCES public.repositories(id);


--
-- Name: jobs jobs_failure_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_failure_group_id_fkey FOREIGN KEY (failure_group_id) REFERENCES public.failure_groups(id);


--
-- Name: repositories repositories_forge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT repositories_forge_id_fkey FOREIGN KEY (forge_id) REFERENCES public.forges(id);


--
-- Name: slave_logs slave_logs_slave_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slave_logs
    ADD CONSTRAINT slave_logs_slave_id_fkey FOREIGN KEY (slave_id) REFERENCES public.slaves(id) ON DELETE CASCADE;


--
-- Name: sloc_metrics sloc_metrics_diff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sloc_metrics
    ADD CONSTRAINT sloc_metrics_diff_id_fkey FOREIGN KEY (diff_id) REFERENCES public.diffs(id) ON DELETE CASCADE;


--
-- Name: sloc_sets sloc_sets_code_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sloc_sets
    ADD CONSTRAINT sloc_sets_code_set_id_fkey FOREIGN KEY (code_set_id) REFERENCES public.code_sets(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20170112183242');

INSERT INTO schema_migrations (version) VALUES ('20170615183328');

INSERT INTO schema_migrations (version) VALUES ('20170622141518');

INSERT INTO schema_migrations (version) VALUES ('20170905123152');

INSERT INTO schema_migrations (version) VALUES ('20170911100003');

INSERT INTO schema_migrations (version) VALUES ('20170913160134');

INSERT INTO schema_migrations (version) VALUES ('20170925190632');

INSERT INTO schema_migrations (version) VALUES ('20170925192153');

INSERT INTO schema_migrations (version) VALUES ('20170925192352');

INSERT INTO schema_migrations (version) VALUES ('20170925192829');

INSERT INTO schema_migrations (version) VALUES ('20170925193357');

INSERT INTO schema_migrations (version) VALUES ('20170925195815');

INSERT INTO schema_migrations (version) VALUES ('20171020021211');

INSERT INTO schema_migrations (version) VALUES ('20171025191016');

INSERT INTO schema_migrations (version) VALUES ('20171030153430');

INSERT INTO schema_migrations (version) VALUES ('20171030154453');

INSERT INTO schema_migrations (version) VALUES ('20171127181222');

INSERT INTO schema_migrations (version) VALUES ('20171128174144');

INSERT INTO schema_migrations (version) VALUES ('20171204165745');

INSERT INTO schema_migrations (version) VALUES ('20171206203036');

INSERT INTO schema_migrations (version) VALUES ('20171207154419');

INSERT INTO schema_migrations (version) VALUES ('20171209110545');

INSERT INTO schema_migrations (version) VALUES ('20171212162720');

INSERT INTO schema_migrations (version) VALUES ('20180104114359');

INSERT INTO schema_migrations (version) VALUES ('20180116211819');

INSERT INTO schema_migrations (version) VALUES ('20180211230753');

INSERT INTO schema_migrations (version) VALUES ('20180212162025');

INSERT INTO schema_migrations (version) VALUES ('20180212210716');

INSERT INTO schema_migrations (version) VALUES ('20180213152903');

INSERT INTO schema_migrations (version) VALUES ('20180213161347');

INSERT INTO schema_migrations (version) VALUES ('20180213163053');

INSERT INTO schema_migrations (version) VALUES ('20180907134326');

INSERT INTO schema_migrations (version) VALUES ('20180927143345');

INSERT INTO schema_migrations (version) VALUES ('20181009171118');

INSERT INTO schema_migrations (version) VALUES ('20181010181449');

INSERT INTO schema_migrations (version) VALUES ('20181108152834');

INSERT INTO schema_migrations (version) VALUES ('20181220010101');

INSERT INTO schema_migrations (version) VALUES ('20190107183802');

INSERT INTO schema_migrations (version) VALUES ('20190212105155');

INSERT INTO schema_migrations (version) VALUES ('20190214122613');

