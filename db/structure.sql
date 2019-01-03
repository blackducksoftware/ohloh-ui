--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


SET search_path = public, pg_catalog;

--
-- Name: statinfo; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE statinfo AS (
	word text,
	ndoc integer,
	nentry integer
);


--
-- Name: tokenout; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE tokenout AS (
	tokid integer,
	token text
);


--
-- Name: tokentype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE tokentype AS (
	tokid integer,
	alias text,
	descr text
);


--
-- Name: tsdebug; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE tsdebug AS (
	ts_name text,
	tok_type text,
	description text,
	token text,
	dict_name text[],
	tsvector tsvector
);


--
-- Name: _get_parser_from_curcfg(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION _get_parser_from_curcfg() RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ select prs_name from pg_ts_cfg where oid = show_curcfg() $$;


--
-- Name: analysis_aliases_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION analysis_aliases_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from analysis_aliases_id_seq_view$$;


--
-- Name: analysis_sloc_sets_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION analysis_sloc_sets_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from analysis_sloc_sets_id_seq_view$$;


--
-- Name: check_jobs(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_jobs(integer) RETURNS integer
    LANGUAGE sql
    AS $_$select repository_id as RESULT from jobs where status != 5 AND  repository_id= $1;$_$;


--
-- Name: code_location_tarballs_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION code_location_tarballs_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from code_location_tarballs_id_seq_view$$;


--
-- Name: code_sets_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION code_sets_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from code_sets_id_seq_view$$;


--
-- Name: commit_flags_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION commit_flags_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from commit_flags_id_seq_view$$;


--
-- Name: commits_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION commits_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from commits_id_seq_view$$;


--
-- Name: diffs_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION diffs_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from diffs_id_seq_view$$;


--
-- Name: email_addresses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION email_addresses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from email_addresses_id_seq_view$$;


--
-- Name: fisbot_events_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fisbot_events_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from fisbot_events_id_seq_view$$;


--
-- Name: fyles_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fyles_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from fyles_id_seq_view$$;


--
-- Name: load_averages_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION load_averages_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from load_averages_id_seq_view$$;


--
-- Name: slave_logs_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION slave_logs_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from slave_logs_id_seq_view$$;


--
-- Name: slave_permissions_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION slave_permissions_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from slave_permissions_id_seq_view$$;


--
-- Name: sloc_metrics_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sloc_metrics_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from sloc_metrics_id_seq_view$$;


--
-- Name: sloc_sets_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sloc_sets_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from sloc_sets_id_seq_view$$;


--
-- Name: ts_debug(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ts_debug(text) RETURNS SETOF tsdebug
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
-- Name: <; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR < (
    PROCEDURE = tsvector_lt,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(pg_catalog.>),
    NEGATOR = OPERATOR(pg_catalog.>=),
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: <=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <= (
    PROCEDURE = tsvector_le,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(pg_catalog.>=),
    NEGATOR = OPERATOR(pg_catalog.>),
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: <>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <> (
    PROCEDURE = tsvector_ne,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(pg_catalog.<>),
    NEGATOR = OPERATOR(pg_catalog.=),
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);


--
-- Name: =; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR = (
    PROCEDURE = tsvector_eq,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = OPERATOR(pg_catalog.=),
    NEGATOR = <>,
    MERGES,
    RESTRICT = eqsel,
    JOIN = eqjoinsel
);


--
-- Name: >; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR > (
    PROCEDURE = tsvector_gt,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = <,
    NEGATOR = <=,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: >=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR >= (
    PROCEDURE = tsvector_ge,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = <=,
    NEGATOR = <,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: default; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION "default" (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR asciiword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR word WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR hword_part WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR hword_asciipart WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR asciihword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR hword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR uint WITH simple;


--
-- Name: pg; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION pg (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR asciiword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR word WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR hword_part WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR hword_asciipart WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR asciihword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR hword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION pg
    ADD MAPPING FOR uint WITH simple;


--
-- Name: fis; Type: SERVER; Schema: -; Owner: -
--

CREATE SERVER fis FOREIGN DATA WRAPPER postgres_fdw OPTIONS (
    dbname 'fis_test',
    host 'localhost',
    port '5432'
);


--
-- Name: USER MAPPING openhub_user SERVER fis; Type: USER MAPPING; Schema: -; Owner: -
--

CREATE USER MAPPING FOR openhub_user SERVER fis OPTIONS (
    password 'fis_password',
    "user" 'fis_user'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE account_reports (
    id integer NOT NULL,
    account_id integer NOT NULL,
    report_id integer NOT NULL
);


--
-- Name: account_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_reports_id_seq OWNED BY account_reports.id;


--
-- Name: account_reports_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW account_reports_id_seq_view AS
 SELECT (nextval('account_reports_id_seq'::regclass))::integer AS id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE accounts (
    id integer NOT NULL,
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
    CONSTRAINT accounts_email_check CHECK ((length(email) >= 3)),
    CONSTRAINT accounts_login_check CHECK ((length(login) >= 3))
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: accounts_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW accounts_id_seq_view AS
 SELECT (nextval('accounts_id_seq'::regclass))::integer AS id;


--
-- Name: actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE actions (
    id integer NOT NULL,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    status text,
    stack_project_id integer,
    claim_person_id bigint
);


--
-- Name: actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE actions_id_seq OWNED BY actions.id;


--
-- Name: actions_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW actions_id_seq_view AS
 SELECT (nextval('actions_id_seq'::regclass))::integer AS id;


--
-- Name: activity_facts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE activity_facts (
    month date,
    language_id integer,
    code_added integer DEFAULT 0,
    code_removed integer DEFAULT 0,
    comments_added integer DEFAULT 0,
    comments_removed integer DEFAULT 0,
    blanks_added integer DEFAULT 0,
    blanks_removed integer DEFAULT 0,
    name_id integer NOT NULL,
    id bigint NOT NULL,
    analysis_id integer NOT NULL,
    commits integer DEFAULT 0,
    on_trunk boolean DEFAULT true
);


--
-- Name: activity_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activity_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_facts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activity_facts_id_seq OWNED BY activity_facts.id;


--
-- Name: activity_facts_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW activity_facts_id_seq_view AS
 SELECT (nextval('activity_facts_id_seq'::regclass))::integer AS id;


--
-- Name: aliases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE aliases (
    id integer NOT NULL,
    project_id integer NOT NULL,
    commit_name_id integer NOT NULL,
    preferred_name_id integer NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT alias_noop_check CHECK ((preferred_name_id <> commit_name_id))
);


--
-- Name: aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE aliases_id_seq OWNED BY aliases.id;


--
-- Name: aliases_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW aliases_id_seq_view AS
 SELECT (nextval('aliases_id_seq'::regclass))::integer AS id;


--
-- Name: all_months; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE all_months (
    month timestamp without time zone
);


--
-- Name: analyses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE analyses (
    id integer NOT NULL,
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
);


--
-- Name: analyses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE analyses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analyses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE analyses_id_seq OWNED BY analyses.id;


--
-- Name: analyses_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW analyses_id_seq_view AS
 SELECT (nextval('analyses_id_seq'::regclass))::integer AS id;


--
-- Name: analysis_aliases; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE analysis_aliases (
    id integer DEFAULT analysis_aliases_id_seq_view() NOT NULL,
    analysis_id integer NOT NULL,
    commit_name_id integer NOT NULL,
    preferred_name_id integer NOT NULL
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'analysis_aliases'
);
ALTER FOREIGN TABLE analysis_aliases ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE analysis_aliases ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE analysis_aliases ALTER COLUMN commit_name_id OPTIONS (
    column_name 'commit_name_id'
);
ALTER FOREIGN TABLE analysis_aliases ALTER COLUMN preferred_name_id OPTIONS (
    column_name 'preferred_name_id'
);


--
-- Name: analysis_aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE analysis_aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analysis_aliases_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE analysis_aliases_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'analysis_aliases_id_seq_view'
);
ALTER FOREIGN TABLE analysis_aliases_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: analysis_sloc_sets; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE analysis_sloc_sets (
    id integer DEFAULT analysis_sloc_sets_id_seq_view() NOT NULL,
    analysis_id integer NOT NULL,
    sloc_set_id integer NOT NULL,
    as_of integer,
    code_set_time timestamp without time zone,
    ignore text,
    ignored_fyle_count integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'analysis_sloc_sets'
);
ALTER FOREIGN TABLE analysis_sloc_sets ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE analysis_sloc_sets ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE analysis_sloc_sets ALTER COLUMN sloc_set_id OPTIONS (
    column_name 'sloc_set_id'
);
ALTER FOREIGN TABLE analysis_sloc_sets ALTER COLUMN as_of OPTIONS (
    column_name 'as_of'
);
ALTER FOREIGN TABLE analysis_sloc_sets ALTER COLUMN code_set_time OPTIONS (
    column_name 'code_set_time'
);
ALTER FOREIGN TABLE analysis_sloc_sets ALTER COLUMN ignore OPTIONS (
    column_name 'ignore'
);
ALTER FOREIGN TABLE analysis_sloc_sets ALTER COLUMN ignored_fyle_count OPTIONS (
    column_name 'ignored_fyle_count'
);


--
-- Name: analysis_sloc_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE analysis_sloc_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analysis_sloc_sets_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE analysis_sloc_sets_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'analysis_sloc_sets_id_seq_view'
);
ALTER FOREIGN TABLE analysis_sloc_sets_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: analysis_summaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE analysis_summaries (
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
-- Name: analysis_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE analysis_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analysis_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE analysis_summaries_id_seq OWNED BY analysis_summaries.id;


--
-- Name: analysis_summaries_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW analysis_summaries_id_seq_view AS
 SELECT (nextval('analysis_summaries_id_seq'::regclass))::integer AS id;


--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE api_keys (
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
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE api_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE api_keys_id_seq OWNED BY api_keys.id;


--
-- Name: api_keys_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_keys_id_seq_view AS
 SELECT (nextval('api_keys_id_seq'::regclass))::integer AS id;


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE attachments (
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
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: attachments_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW attachments_id_seq_view AS
 SELECT (nextval('attachments_id_seq'::regclass))::integer AS id;


--
-- Name: authorizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE authorizations (
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
-- Name: authorizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authorizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authorizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authorizations_id_seq OWNED BY authorizations.id;


--
-- Name: authorizations_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW authorizations_id_seq_view AS
 SELECT (nextval('authorizations_id_seq'::regclass))::integer AS id;

--
-- Name: broken_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE broken_links (
    id integer NOT NULL,
    link_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    error text
);

--
-- Name: broken_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE broken_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: broken_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE broken_links_id_seq OWNED BY broken_links.id;

--
-- Name: positions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE positions (
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
-- Name: claims_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE claims_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claims_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE claims_id_seq OWNED BY positions.id;


--
-- Name: claims_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW claims_id_seq_view AS
 SELECT (nextval('claims_id_seq'::regclass))::integer AS id;


--
-- Name: clumps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE clumps (
    id integer NOT NULL,
    slave_id integer,
    code_set_id integer,
    updated_at timestamp without time zone,
    type text NOT NULL,
    fetched_at timestamp without time zone
);


--
-- Name: clumps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clumps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clumps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE clumps_id_seq OWNED BY clumps.id;


--
-- Name: clumps_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW clumps_id_seq_view AS
 SELECT (nextval('clumps_id_seq'::regclass))::integer AS id;


--
-- Name: code_location_tarballs; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE code_location_tarballs (
    id integer DEFAULT code_location_tarballs_id_seq_view() NOT NULL,
    code_location_id integer,
    reference text,
    filepath text,
    status integer DEFAULT 0,
    created_at timestamp without time zone,
    type text
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'code_location_tarballs'
);
ALTER FOREIGN TABLE code_location_tarballs ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE code_location_tarballs ALTER COLUMN code_location_id OPTIONS (
    column_name 'code_location_id'
);
ALTER FOREIGN TABLE code_location_tarballs ALTER COLUMN reference OPTIONS (
    column_name 'reference'
);
ALTER FOREIGN TABLE code_location_tarballs ALTER COLUMN filepath OPTIONS (
    column_name 'filepath'
);
ALTER FOREIGN TABLE code_location_tarballs ALTER COLUMN status OPTIONS (
    column_name 'status'
);
ALTER FOREIGN TABLE code_location_tarballs ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE code_location_tarballs ALTER COLUMN type OPTIONS (
    column_name 'type'
);


--
-- Name: code_location_tarballs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE code_location_tarballs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_location_tarballs_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE code_location_tarballs_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'code_location_tarballs_id_seq_view'
);
ALTER FOREIGN TABLE code_location_tarballs_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: code_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE code_locations (
    id integer NOT NULL,
    repository_id integer,
    module_branch_name text,
    status integer DEFAULT 0,
    best_code_set_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    update_interval integer DEFAULT 3600,
    best_repository_directory_id integer,
    do_not_fetch boolean DEFAULT false
);


--
-- Name: code_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE code_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE code_locations_id_seq OWNED BY code_locations.id;


--
-- Name: code_locations_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW code_locations_id_seq_view AS
 SELECT (nextval('code_locations_id_seq'::regclass))::integer AS id;


--
-- Name: code_sets; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE code_sets (
    id integer DEFAULT code_sets_id_seq_view() NOT NULL,
    updated_on timestamp without time zone,
    best_sloc_set_id integer,
    as_of integer,
    logged_at timestamp without time zone,
    clump_count integer DEFAULT 0,
    fetched_at timestamp without time zone,
    code_location_id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'code_sets'
);
ALTER FOREIGN TABLE code_sets ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE code_sets ALTER COLUMN updated_on OPTIONS (
    column_name 'updated_on'
);
ALTER FOREIGN TABLE code_sets ALTER COLUMN best_sloc_set_id OPTIONS (
    column_name 'best_sloc_set_id'
);
ALTER FOREIGN TABLE code_sets ALTER COLUMN as_of OPTIONS (
    column_name 'as_of'
);
ALTER FOREIGN TABLE code_sets ALTER COLUMN logged_at OPTIONS (
    column_name 'logged_at'
);
ALTER FOREIGN TABLE code_sets ALTER COLUMN clump_count OPTIONS (
    column_name 'clump_count'
);
ALTER FOREIGN TABLE code_sets ALTER COLUMN fetched_at OPTIONS (
    column_name 'fetched_at'
);
ALTER FOREIGN TABLE code_sets ALTER COLUMN code_location_id OPTIONS (
    column_name 'code_location_id'
);


--
-- Name: code_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE code_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_sets_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE code_sets_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'code_sets_id_seq_view'
);
ALTER FOREIGN TABLE code_sets_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: commit_contributors; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE commit_contributors (
    id integer,
    code_set_id integer,
    name_id integer,
    analysis_id integer,
    project_id integer,
    position_id integer,
    account_id integer,
    contribution_id bigint,
    person_id bigint
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'commit_contributors'
);
ALTER FOREIGN TABLE commit_contributors ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE commit_contributors ALTER COLUMN code_set_id OPTIONS (
    column_name 'code_set_id'
);
ALTER FOREIGN TABLE commit_contributors ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE commit_contributors ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE commit_contributors ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE commit_contributors ALTER COLUMN position_id OPTIONS (
    column_name 'position_id'
);
ALTER FOREIGN TABLE commit_contributors ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE commit_contributors ALTER COLUMN contribution_id OPTIONS (
    column_name 'contribution_id'
);
ALTER FOREIGN TABLE commit_contributors ALTER COLUMN person_id OPTIONS (
    column_name 'person_id'
);


--
-- Name: commit_flags; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE commit_flags (
    id integer DEFAULT commit_flags_id_seq_view() NOT NULL,
    sloc_set_id integer NOT NULL,
    commit_id integer NOT NULL,
    "time" timestamp without time zone NOT NULL,
    type text NOT NULL,
    data text
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'commit_flags'
);
ALTER FOREIGN TABLE commit_flags ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE commit_flags ALTER COLUMN sloc_set_id OPTIONS (
    column_name 'sloc_set_id'
);
ALTER FOREIGN TABLE commit_flags ALTER COLUMN commit_id OPTIONS (
    column_name 'commit_id'
);
ALTER FOREIGN TABLE commit_flags ALTER COLUMN "time" OPTIONS (
    column_name 'time'
);
ALTER FOREIGN TABLE commit_flags ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE commit_flags ALTER COLUMN data OPTIONS (
    column_name 'data'
);


--
-- Name: commit_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE commit_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commit_flags_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE commit_flags_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'commit_flags_id_seq_view'
);
ALTER FOREIGN TABLE commit_flags_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: commits; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE commits (
    id integer DEFAULT commits_id_seq_view() NOT NULL,
    sha1 text,
    "time" timestamp without time zone NOT NULL,
    comment text,
    code_set_id integer NOT NULL,
    name_id integer NOT NULL,
    "position" integer,
    on_trunk boolean DEFAULT true,
    email_address_id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'commits'
);
ALTER FOREIGN TABLE commits ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE commits ALTER COLUMN sha1 OPTIONS (
    column_name 'sha1'
);
ALTER FOREIGN TABLE commits ALTER COLUMN "time" OPTIONS (
    column_name 'time'
);
ALTER FOREIGN TABLE commits ALTER COLUMN comment OPTIONS (
    column_name 'comment'
);
ALTER FOREIGN TABLE commits ALTER COLUMN code_set_id OPTIONS (
    column_name 'code_set_id'
);
ALTER FOREIGN TABLE commits ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE commits ALTER COLUMN "position" OPTIONS (
    column_name 'position'
);
ALTER FOREIGN TABLE commits ALTER COLUMN on_trunk OPTIONS (
    column_name 'on_trunk'
);
ALTER FOREIGN TABLE commits ALTER COLUMN email_address_id OPTIONS (
    column_name 'email_address_id'
);


--
-- Name: commits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE commits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commits_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE commits_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'commits_id_seq_view'
);
ALTER FOREIGN TABLE commits_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: name_facts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE name_facts (
    id integer NOT NULL,
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
-- Name: people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE people (
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
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE projects (
    id integer NOT NULL,
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
    CONSTRAINT valid_missing_source CHECK (((missing_source IS NULL) OR (missing_source = 'not available'::text) OR (missing_source = 'not supported'::text)))
);


--
-- Name: contributions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW contributions AS
 SELECT people.id,
    people.id AS person_id,
    people.project_id,
    people.name_fact_id,
    NULL::integer AS position_id
   FROM people
  WHERE (people.project_id IS NOT NULL)
UNION
 SELECT (((positions.project_id)::bigint << 32) + (positions.account_id)::bigint) AS id,
    people.id AS person_id,
    positions.project_id,
    name_facts.id AS name_fact_id,
    positions.id AS position_id
   FROM (((people
     JOIN positions ON ((positions.account_id = people.account_id)))
     LEFT JOIN projects ON ((projects.id = positions.project_id)))
     LEFT JOIN name_facts ON (((name_facts.analysis_id = projects.best_analysis_id) AND (name_facts.name_id = positions.name_id))));


--
-- Name: contributions2; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW contributions2 AS
 SELECT
        CASE
            WHEN (pos.id IS NULL) THEN ((((per.project_id)::bigint << 32) + (per.name_id)::bigint) + (B'10000000000000000000000000000000'::"bit")::bigint)
            ELSE (((pos.project_id)::bigint << 32) + (pos.account_id)::bigint)
        END AS id,
        CASE
            WHEN (pos.id IS NULL) THEN per.name_fact_id
            ELSE ( SELECT name_facts.id
               FROM name_facts
              WHERE ((name_facts.analysis_id = p.best_analysis_id) AND (name_facts.name_id = pos.name_id)))
        END AS name_fact_id,
    pos.id AS position_id,
    per.id AS person_id,
    COALESCE(pos.project_id, per.project_id) AS project_id
   FROM ((people per
     LEFT JOIN positions pos ON ((per.account_id = pos.account_id)))
     JOIN projects p ON ((p.id = COALESCE(pos.project_id, per.project_id))));


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE countries (
    country_code text,
    continent_code text,
    name text,
    region text
);


--
-- Name: deleted_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE deleted_accounts (
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
-- Name: deleted_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE deleted_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deleted_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE deleted_accounts_id_seq OWNED BY deleted_accounts.id;


--
-- Name: deleted_accounts_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW deleted_accounts_id_seq_view AS
 SELECT (nextval('deleted_accounts_id_seq'::regclass))::integer AS id;


--
-- Name: diff_licenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE diff_licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: diff_licenses_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW diff_licenses_id_seq_view AS
 SELECT (nextval('diff_licenses_id_seq'::regclass))::integer AS id;


--
-- Name: diffs; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE diffs (
    id bigint DEFAULT diffs_id_seq_view() NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id integer,
    fyle_id integer,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'diffs'
);
ALTER FOREIGN TABLE diffs ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE diffs ALTER COLUMN sha1 OPTIONS (
    column_name 'sha1'
);
ALTER FOREIGN TABLE diffs ALTER COLUMN parent_sha1 OPTIONS (
    column_name 'parent_sha1'
);
ALTER FOREIGN TABLE diffs ALTER COLUMN commit_id OPTIONS (
    column_name 'commit_id'
);
ALTER FOREIGN TABLE diffs ALTER COLUMN fyle_id OPTIONS (
    column_name 'fyle_id'
);
ALTER FOREIGN TABLE diffs ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE diffs ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
);
ALTER FOREIGN TABLE diffs ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);


--
-- Name: diffs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE diffs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: diffs_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE diffs_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'diffs_id_seq_view'
);
ALTER FOREIGN TABLE diffs_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: duplicates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE duplicates (
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
-- Name: duplicates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE duplicates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: duplicates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE duplicates_id_seq OWNED BY duplicates.id;


--
-- Name: duplicates_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW duplicates_id_seq_view AS
 SELECT (nextval('duplicates_id_seq'::regclass))::integer AS id;


--
-- Name: edits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE edits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: edits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE edits (
    id integer DEFAULT nextval('edits_id_seq'::regclass) NOT NULL,
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
-- Name: edits_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE edits_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: edits_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE edits_id_seq1 OWNED BY edits.id;


--
-- Name: edits_id_seq1_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW edits_id_seq1_view AS
 SELECT (nextval('edits_id_seq1'::regclass))::integer AS id;


--
-- Name: edits_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW edits_id_seq_view AS
 SELECT (nextval('edits_id_seq'::regclass))::integer AS id;


--
-- Name: email_addresses; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE email_addresses (
    id integer DEFAULT email_addresses_id_seq_view() NOT NULL,
    address text NOT NULL
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'email_addresses'
);
ALTER FOREIGN TABLE email_addresses ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE email_addresses ALTER COLUMN address OPTIONS (
    column_name 'address'
);


--
-- Name: email_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE email_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_addresses_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE email_addresses_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'email_addresses_id_seq_view'
);
ALTER FOREIGN TABLE email_addresses_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: enlistments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE enlistments (
    id integer NOT NULL,
    project_id integer NOT NULL,
    repository_id integer,
    deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    updated_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    ignore text,
    code_location_id integer
);


--
-- Name: enlistments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE enlistments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enlistments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE enlistments_id_seq OWNED BY enlistments.id;


--
-- Name: enlistments_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW enlistments_id_seq_view AS
 SELECT (nextval('enlistments_id_seq'::regclass))::integer AS id;


--
-- Name: event_subscription; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE event_subscription (
    id integer NOT NULL,
    subscriber_id integer,
    klass text NOT NULL,
    project_id integer,
    topic_id integer,
    account_id integer,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: event_subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE event_subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_subscription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_subscription_id_seq OWNED BY event_subscription.id;


--
-- Name: event_subscription_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW event_subscription_id_seq_view AS
 SELECT (nextval('event_subscription_id_seq'::regclass))::integer AS id;


--
-- Name: exhibits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE exhibits (
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
-- Name: exhibits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE exhibits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exhibits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE exhibits_id_seq OWNED BY exhibits.id;


--
-- Name: exhibits_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW exhibits_id_seq_view AS
 SELECT (nextval('exhibits_id_seq'::regclass))::integer AS id;


--
-- Name: factoids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE factoids (
    id integer NOT NULL,
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
-- Name: factoids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE factoids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: factoids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE factoids_id_seq OWNED BY factoids.id;


--
-- Name: factoids_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW factoids_id_seq_view AS
 SELECT (nextval('factoids_id_seq'::regclass))::integer AS id;


--
-- Name: failure_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE failure_groups (
    id integer NOT NULL,
    name text NOT NULL,
    pattern text NOT NULL,
    priority integer DEFAULT 0,
    auto_reschedule boolean DEFAULT false
);


--
-- Name: failure_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE failure_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failure_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE failure_groups_id_seq OWNED BY failure_groups.id;


--
-- Name: failure_groups_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW failure_groups_id_seq_view AS
 SELECT (nextval('failure_groups_id_seq'::regclass))::integer AS id;


--
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE feedbacks (
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
-- Name: feedbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE feedbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE feedbacks_id_seq OWNED BY feedbacks.id;


--
-- Name: feedbacks_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW feedbacks_id_seq_view AS
 SELECT (nextval('feedbacks_id_seq'::regclass))::integer AS id;


--
-- Name: fisbot_events; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE fisbot_events (
    id integer DEFAULT fisbot_events_id_seq_view() NOT NULL,
    code_location_id integer,
    type text NOT NULL,
    value text,
    commit_sha1 text,
    status boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    repository_id integer,
    component_id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'fisbot_events'
);
ALTER FOREIGN TABLE fisbot_events ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE fisbot_events ALTER COLUMN code_location_id OPTIONS (
    column_name 'code_location_id'
);
ALTER FOREIGN TABLE fisbot_events ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE fisbot_events ALTER COLUMN value OPTIONS (
    column_name 'value'
);
ALTER FOREIGN TABLE fisbot_events ALTER COLUMN commit_sha1 OPTIONS (
    column_name 'commit_sha1'
);
ALTER FOREIGN TABLE fisbot_events ALTER COLUMN status OPTIONS (
    column_name 'status'
);
ALTER FOREIGN TABLE fisbot_events ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE fisbot_events ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE fisbot_events ALTER COLUMN repository_id OPTIONS (
    column_name 'repository_id'
);
ALTER FOREIGN TABLE fisbot_events ALTER COLUMN component_id OPTIONS (
    column_name 'component_id'
);


--
-- Name: fisbot_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fisbot_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fisbot_events_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE fisbot_events_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'fisbot_events_id_seq_view'
);
ALTER FOREIGN TABLE fisbot_events_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: follows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE follows (
    id integer NOT NULL,
    owner_id integer NOT NULL,
    project_id integer,
    account_id integer,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: message_account_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE message_account_tags (
    id integer NOT NULL,
    message_id integer,
    account_id integer
);


--
-- Name: message_project_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE message_project_tags (
    id integer NOT NULL,
    message_id integer,
    project_id integer
);


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE messages (
    id integer NOT NULL,
    account_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    body text,
    title text
);


--
-- Name: followed_messages; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW followed_messages AS
 SELECT f.owner_id,
    m.id,
    m.account_id,
    m.created_at,
    m.deleted_at,
    m.body,
    m.title
   FROM ((messages m
     JOIN message_project_tags mpt ON ((mpt.message_id = m.id)))
     JOIN follows f ON ((f.project_id = mpt.project_id)))
  WHERE (m.deleted_at IS NULL)
UNION
 SELECT f.owner_id,
    m.id,
    m.account_id,
    m.created_at,
    m.deleted_at,
    m.body,
    m.title
   FROM (messages m
     JOIN follows f ON ((f.account_id = m.account_id)))
  WHERE (m.deleted_at IS NULL)
UNION
 SELECT mat.account_id AS owner_id,
    m.id,
    m.account_id,
    m.created_at,
    m.deleted_at,
    m.body,
    m.title
   FROM (messages m
     JOIN message_account_tags mat ON ((mat.message_id = m.id)))
  WHERE (m.deleted_at IS NULL);


--
-- Name: follows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE follows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: follows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE follows_id_seq OWNED BY follows.id;


--
-- Name: follows_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW follows_id_seq_view AS
 SELECT (nextval('follows_id_seq'::regclass))::integer AS id;


--
-- Name: forges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE forges (
    id integer NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    type text
);


--
-- Name: forges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE forges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE forges_id_seq OWNED BY forges.id;


--
-- Name: forges_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW forges_id_seq_view AS
 SELECT (nextval('forges_id_seq'::regclass))::integer AS id;


--
-- Name: forums; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE forums (
    id integer NOT NULL,
    project_id integer,
    name text NOT NULL,
    topics_count integer DEFAULT 0,
    posts_count integer DEFAULT 0,
    "position" integer,
    description text
);


--
-- Name: forums_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE forums_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forums_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE forums_id_seq OWNED BY forums.id;


--
-- Name: forums_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW forums_id_seq_view AS
 SELECT (nextval('forums_id_seq'::regclass))::integer AS id;


--
-- Name: fyles; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE fyles (
    id integer DEFAULT fyles_id_seq_view() NOT NULL,
    name text NOT NULL,
    code_set_id integer NOT NULL
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'fyles'
);
ALTER FOREIGN TABLE fyles ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE fyles ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE fyles ALTER COLUMN code_set_id OPTIONS (
    column_name 'code_set_id'
);


--
-- Name: fyles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fyles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fyles_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE fyles_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'fyles_id_seq_view'
);
ALTER FOREIGN TABLE fyles_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: github_project; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE github_project (
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
-- Name: guaranteed_spam_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE guaranteed_spam_accounts (
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
-- Name: helpfuls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE helpfuls (
    id integer NOT NULL,
    review_id integer,
    account_id integer NOT NULL,
    yes boolean DEFAULT true
);


--
-- Name: helpfuls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE helpfuls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: helpfuls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE helpfuls_id_seq OWNED BY helpfuls.id;


--
-- Name: helpfuls_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW helpfuls_id_seq_view AS
 SELECT (nextval('helpfuls_id_seq'::regclass))::integer AS id;


--
-- Name: invites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE invites (
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
-- Name: invites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE invites_id_seq OWNED BY invites.id;


--
-- Name: invites_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW invites_id_seq_view AS
 SELECT (nextval('invites_id_seq'::regclass))::integer AS id;


--
-- Name: job_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_statuses (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE jobs (
    id integer NOT NULL,
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

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- Name: jobs_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW jobs_id_seq_view AS
 SELECT (nextval('jobs_id_seq'::regclass))::integer AS id;


--
-- Name: knowledge_base_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE knowledge_base_statuses (
    id integer NOT NULL,
    project_id integer NOT NULL,
    in_sync boolean DEFAULT false,
    updated_at timestamp without time zone
);


--
-- Name: knowledge_base_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE knowledge_base_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_base_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE knowledge_base_statuses_id_seq OWNED BY knowledge_base_statuses.id;


--
-- Name: knowledge_base_statuses_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW knowledge_base_statuses_id_seq_view AS
 SELECT (nextval('knowledge_base_statuses_id_seq'::regclass))::integer AS id;


--
-- Name: kudo_scores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE kudo_scores (
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
-- Name: kudo_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE kudo_scores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
    CYCLE;


--
-- Name: kudo_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE kudo_scores_id_seq OWNED BY kudo_scores.id;


--
-- Name: kudo_scores_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW kudo_scores_id_seq_view AS
 SELECT (nextval('kudo_scores_id_seq'::regclass))::integer AS id;


--
-- Name: kudos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE kudos (
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
-- Name: kudos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE kudos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kudos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE kudos_id_seq OWNED BY kudos.id;


--
-- Name: kudos_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW kudos_id_seq_view AS
 SELECT (nextval('kudos_id_seq'::regclass))::integer AS id;


--
-- Name: language_experiences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE language_experiences (
    id integer NOT NULL,
    position_id integer NOT NULL,
    language_id integer NOT NULL
);


--
-- Name: language_experiences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE language_experiences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: language_experiences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE language_experiences_id_seq OWNED BY language_experiences.id;


--
-- Name: language_experiences_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW language_experiences_id_seq_view AS
 SELECT (nextval('language_experiences_id_seq'::regclass))::integer AS id;


--
-- Name: language_facts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE language_facts (
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
-- Name: language_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE language_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: language_facts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE language_facts_id_seq OWNED BY language_facts.id;


--
-- Name: language_facts_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW language_facts_id_seq_view AS
 SELECT (nextval('language_facts_id_seq'::regclass))::integer AS id;


--
-- Name: languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE languages (
    id integer NOT NULL,
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
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE languages_id_seq OWNED BY languages.id;


--
-- Name: languages_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW languages_id_seq_view AS
 SELECT (nextval('languages_id_seq'::regclass))::integer AS id;


--
-- Name: license_facts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE license_facts (
    license_id integer NOT NULL,
    file_count integer DEFAULT 0 NOT NULL,
    scope integer DEFAULT 0 NOT NULL,
    id integer NOT NULL,
    analysis_id integer NOT NULL
);


--
-- Name: license_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE license_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: license_facts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE license_facts_id_seq OWNED BY license_facts.id;


--
-- Name: license_facts_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW license_facts_id_seq_view AS
 SELECT (nextval('license_facts_id_seq'::regclass))::integer AS id;


--
-- Name: license_permission_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE license_permission_roles (
    id integer NOT NULL,
    license_id integer,
    license_permission_id integer,
    status integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: license_permission_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE license_permission_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: license_permission_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE license_permission_roles_id_seq OWNED BY license_permission_roles.id;


--
-- Name: license_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE license_permissions (
    id integer NOT NULL,
    name character varying,
    description character varying,
    icon character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: license_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE license_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: license_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE license_permissions_id_seq OWNED BY license_permissions.id;


--
-- Name: licenses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE licenses (
    id integer NOT NULL,
    vanity_url text,
    name text,
    abbreviation text,
    url text,
    description text,
    deleted boolean DEFAULT false,
    locked boolean DEFAULT false
);


--
-- Name: licenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: licenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE licenses_id_seq OWNED BY licenses.id;


--
-- Name: licenses_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW licenses_id_seq_view AS
 SELECT (nextval('licenses_id_seq'::regclass))::integer AS id;


--
-- Name: link_categories_deleted; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE link_categories_deleted (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: link_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE link_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: link_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE link_categories_id_seq OWNED BY link_categories_deleted.id;


--
-- Name: link_categories_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW link_categories_id_seq_view AS
 SELECT (nextval('link_categories_id_seq'::regclass))::integer AS id;


--
-- Name: links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE links (
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
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: links_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW links_id_seq_view AS
 SELECT (nextval('links_id_seq'::regclass))::integer AS id;


--
-- Name: load_averages; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE load_averages (
    current numeric DEFAULT 0.0,
    id integer DEFAULT load_averages_id_seq_view() NOT NULL,
    max numeric DEFAULT 3.0
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'load_averages'
);
ALTER FOREIGN TABLE load_averages ALTER COLUMN current OPTIONS (
    column_name 'current'
);
ALTER FOREIGN TABLE load_averages ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE load_averages ALTER COLUMN max OPTIONS (
    column_name 'max'
);


--
-- Name: load_averages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE load_averages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: load_averages_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE load_averages_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'load_averages_id_seq_view'
);
ALTER FOREIGN TABLE load_averages_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: manages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE manages (
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
-- Name: manages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE manages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: manages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE manages_id_seq OWNED BY manages.id;


--
-- Name: manages_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW manages_id_seq_view AS
 SELECT (nextval('manages_id_seq'::regclass))::integer AS id;


--
-- Name: markups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE markups (
    id integer NOT NULL,
    raw text,
    formatted text
);


--
-- Name: markups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE markups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: markups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE markups_id_seq OWNED BY markups.id;


--
-- Name: markups_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW markups_id_seq_view AS
 SELECT (nextval('markups_id_seq'::regclass))::integer AS id;


--
-- Name: message_account_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE message_account_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_account_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE message_account_tags_id_seq OWNED BY message_account_tags.id;


--
-- Name: message_account_tags_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW message_account_tags_id_seq_view AS
 SELECT (nextval('message_account_tags_id_seq'::regclass))::integer AS id;


--
-- Name: message_project_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE message_project_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_project_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE message_project_tags_id_seq OWNED BY message_project_tags.id;


--
-- Name: message_project_tags_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW message_project_tags_id_seq_view AS
 SELECT (nextval('message_project_tags_id_seq'::regclass))::integer AS id;


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE messages_id_seq OWNED BY messages.id;


--
-- Name: messages_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW messages_id_seq_view AS
 SELECT (nextval('messages_id_seq'::regclass))::integer AS id;


--
-- Name: mistaken_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE mistaken_jobs (
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
-- Name: moderatorships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE moderatorships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: moderatorships_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW moderatorships_id_seq_view AS
 SELECT (nextval('moderatorships_id_seq'::regclass))::integer AS id;


--
-- Name: monitorships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE monitorships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitorships_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW monitorships_id_seq_view AS
 SELECT (nextval('monitorships_id_seq'::regclass))::integer AS id;


--
-- Name: monthly_commit_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE monthly_commit_histories (
    id integer NOT NULL,
    analysis_id integer,
    json text
);


--
-- Name: monthly_commit_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE monthly_commit_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monthly_commit_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE monthly_commit_histories_id_seq OWNED BY monthly_commit_histories.id;


--
-- Name: monthly_commit_histories_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW monthly_commit_histories_id_seq_view AS
 SELECT (nextval('monthly_commit_histories_id_seq'::regclass))::integer AS id;


--
-- Name: name_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE name_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: name_facts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE name_facts_id_seq OWNED BY name_facts.id;


--
-- Name: name_facts_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW name_facts_id_seq_view AS
 SELECT (nextval('name_facts_id_seq'::regclass))::integer AS id;


--
-- Name: name_language_facts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE name_language_facts (
    id integer NOT NULL,
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
-- Name: name_language_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE name_language_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: name_language_facts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE name_language_facts_id_seq OWNED BY name_language_facts.id;


--
-- Name: name_language_facts_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW name_language_facts_id_seq_view AS
 SELECT (nextval('name_language_facts_id_seq'::regclass))::integer AS id;


--
-- Name: names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE names (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE names_id_seq OWNED BY names.id;


--
-- Name: names_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW names_id_seq_view AS
 SELECT (nextval('names_id_seq'::regclass))::integer AS id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE oauth_access_grants (
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
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_access_grants_id_seq OWNED BY oauth_access_grants.id;


--
-- Name: oauth_access_grants_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW oauth_access_grants_id_seq_view AS
 SELECT (nextval('oauth_access_grants_id_seq'::regclass))::integer AS id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE oauth_access_tokens (
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
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_access_tokens_id_seq OWNED BY oauth_access_tokens.id;


--
-- Name: oauth_access_tokens_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW oauth_access_tokens_id_seq_view AS
 SELECT (nextval('oauth_access_tokens_id_seq'::regclass))::integer AS id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE oauth_applications (
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
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_applications_id_seq OWNED BY oauth_applications.id;


--
-- Name: oauth_applications_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW oauth_applications_id_seq_view AS
 SELECT (nextval('oauth_applications_id_seq'::regclass))::integer AS id;


--
-- Name: oauth_nonces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE oauth_nonces (
    id integer NOT NULL,
    nonce text NOT NULL,
    "timestamp" integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: oauth_nonces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_nonces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_nonces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_nonces_id_seq OWNED BY oauth_nonces.id;


--
-- Name: oauth_nonces_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW oauth_nonces_id_seq_view AS
 SELECT (nextval('oauth_nonces_id_seq'::regclass))::integer AS id;


--
-- Name: old_edits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE old_edits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: old_edits_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW old_edits_id_seq_view AS
 SELECT (nextval('old_edits_id_seq'::regclass))::integer AS id;


--
-- Name: org_stats_by_sectors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE org_stats_by_sectors (
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
-- Name: org_stats_by_sectors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE org_stats_by_sectors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_stats_by_sectors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE org_stats_by_sectors_id_seq OWNED BY org_stats_by_sectors.id;


--
-- Name: org_stats_by_sectors_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW org_stats_by_sectors_id_seq_view AS
 SELECT (nextval('org_stats_by_sectors_id_seq'::regclass))::integer AS id;


--
-- Name: org_thirty_day_activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE org_thirty_day_activities (
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
-- Name: org_thirty_day_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE org_thirty_day_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_thirty_day_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE org_thirty_day_activities_id_seq OWNED BY org_thirty_day_activities.id;


--
-- Name: org_thirty_day_activities_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW org_thirty_day_activities_id_seq_view AS
 SELECT (nextval('org_thirty_day_activities_id_seq'::regclass))::integer AS id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE organizations (
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
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: organizations_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW organizations_id_seq_view AS
 SELECT (nextval('organizations_id_seq'::regclass))::integer AS id;


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW pages_id_seq_view AS
 SELECT (nextval('pages_id_seq'::regclass))::integer AS id;


--
-- Name: people_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW people_view AS
 SELECT a.id,
    a.name AS effective_name,
    a.id AS account_id,
    NULL::integer AS project_id,
    NULL::integer AS name_id,
    NULL::integer AS name_fact_id,
    ks."position" AS kudo_position,
    ks.score AS kudo_score,
    ks.rank AS kudo_rank
   FROM (accounts a
     LEFT JOIN kudo_scores ks ON ((ks.account_id = a.id)))
  WHERE (a.level <> '-20'::integer)
UNION
 SELECT ((((p.id)::bigint << 32) + (nf.name_id)::bigint) + (B'10000000000000000000000000000000'::"bit")::bigint) AS id,
    n.name AS effective_name,
    NULL::integer AS account_id,
    p.id AS project_id,
    n.id AS name_id,
    nf.id AS name_fact_id,
    ks."position" AS kudo_position,
    ks.score AS kudo_score,
    ks.rank AS kudo_rank
   FROM (((name_facts nf
     JOIN names n ON ((nf.name_id = n.id)))
     JOIN projects p ON (((p.best_analysis_id = nf.analysis_id) AND (NOT p.deleted))))
     LEFT JOIN kudo_scores ks ON (((ks.name_id = nf.name_id) AND (ks.project_id = p.id))))
  WHERE (NOT (nf.name_id IN ( SELECT positions.name_id
           FROM positions
          WHERE ((positions.project_id = p.id) AND (positions.name_id IS NOT NULL)))));


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE permissions (
    id integer NOT NULL,
    target_id integer NOT NULL,
    updated_at timestamp without time zone,
    created_at timestamp without time zone,
    remainder boolean DEFAULT false,
    downloads boolean DEFAULT false,
    target_type text
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE permissions_id_seq OWNED BY permissions.id;


--
-- Name: permissions_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW permissions_id_seq_view AS
 SELECT (nextval('permissions_id_seq'::regclass))::integer AS id;


SET default_with_oids = true;

--
-- Name: pg_ts_cfg; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pg_ts_cfg (
    ts_name text NOT NULL,
    prs_name text NOT NULL,
    locale text
);


--
-- Name: pg_ts_cfgmap; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pg_ts_cfgmap (
    ts_name text NOT NULL,
    tok_alias text NOT NULL,
    dict_name text[]
);


--
-- Name: positions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE positions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: positions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE positions_id_seq OWNED BY positions.id;


--
-- Name: positions_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW positions_id_seq_view AS
 SELECT (nextval('positions_id_seq'::regclass))::integer AS id;


SET default_with_oids = false;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE posts (
    id integer NOT NULL,
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
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;


--
-- Name: posts_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW posts_id_seq_view AS
 SELECT (nextval('posts_id_seq'::regclass))::integer AS id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE profiles (
    id integer NOT NULL,
    job_id integer,
    name text NOT NULL,
    count integer NOT NULL,
    "time" numeric NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profiles_id_seq OWNED BY profiles.id;


--
-- Name: profiles_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW profiles_id_seq_view AS
 SELECT (nextval('profiles_id_seq'::regclass))::integer AS id;


--
-- Name: project_badges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE project_badges (
    id integer NOT NULL,
    identifier character varying,
    type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 1,
    enlistment_id integer
);


--
-- Name: project_badges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_badges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_badges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_badges_id_seq OWNED BY project_badges.id;


--
-- Name: project_badges_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_badges_id_seq_view AS
 SELECT (nextval('project_badges_id_seq'::regclass))::integer AS id;


--
-- Name: project_counts_by_quarter_and_language; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_counts_by_quarter_and_language AS
 SELECT af.language_id,
    date_trunc('quarter'::text, timezone('utc'::text, (af.month)::timestamp with time zone)) AS quarter,
    count(DISTINCT af.analysis_id) AS project_count
   FROM ((activity_facts af
     JOIN analyses a ON ((a.id = af.analysis_id)))
     JOIN projects p ON (((p.best_analysis_id = a.id) AND (NOT p.deleted))))
  GROUP BY af.language_id, (date_trunc('quarter'::text, timezone('utc'::text, (af.month)::timestamp with time zone)));


--
-- Name: project_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE project_events (
    id integer NOT NULL,
    project_id integer,
    type text NOT NULL,
    key text NOT NULL,
    data text,
    "time" timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: project_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_events_id_seq OWNED BY project_events.id;


--
-- Name: project_events_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_events_id_seq_view AS
 SELECT (nextval('project_events_id_seq'::regclass))::integer AS id;


--
-- Name: project_experiences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE project_experiences (
    id integer NOT NULL,
    position_id integer NOT NULL,
    project_id integer NOT NULL,
    promote boolean DEFAULT false NOT NULL
);


--
-- Name: project_experiences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_experiences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_experiences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_experiences_id_seq OWNED BY project_experiences.id;


--
-- Name: project_experiences_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_experiences_id_seq_view AS
 SELECT (nextval('project_experiences_id_seq'::regclass))::integer AS id;


--
-- Name: project_gestalts_tmp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE project_gestalts_tmp (
    id integer,
    date timestamp without time zone,
    project_id integer,
    gestalt_id integer
);


--
-- Name: project_licenses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE project_licenses (
    id integer NOT NULL,
    project_id integer,
    license_id integer,
    deleted boolean DEFAULT false
);


--
-- Name: project_licenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_licenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_licenses_id_seq OWNED BY project_licenses.id;


--
-- Name: project_licenses_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_licenses_id_seq_view AS
 SELECT (nextval('project_licenses_id_seq'::regclass))::integer AS id;


--
-- Name: project_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE project_reports (
    id integer NOT NULL,
    project_id integer NOT NULL,
    report_id integer NOT NULL
);


--
-- Name: project_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_reports_id_seq OWNED BY project_reports.id;


--
-- Name: project_reports_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_reports_id_seq_view AS
 SELECT (nextval('project_reports_id_seq'::regclass))::integer AS id;


--
-- Name: project_security_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE project_security_sets (
    id integer NOT NULL,
    project_id integer,
    uuid character varying NOT NULL,
    etag character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: project_security_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_security_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_security_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_security_sets_id_seq OWNED BY project_security_sets.id;


--
-- Name: project_security_sets_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_security_sets_id_seq_view AS
 SELECT (nextval('project_security_sets_id_seq'::regclass))::integer AS id;


--
-- Name: project_vulnerability_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE project_vulnerability_reports (
    id integer NOT NULL,
    project_id integer,
    etag character varying(255),
    vulnerability_score numeric,
    security_score numeric,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: project_vulnerability_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_vulnerability_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_vulnerability_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_vulnerability_reports_id_seq OWNED BY project_vulnerability_reports.id;


--
-- Name: project_vulnerability_reports_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_vulnerability_reports_id_seq_view AS
 SELECT (nextval('project_vulnerability_reports_id_seq'::regclass))::integer AS id;


--
-- Name: projects_by_month; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW projects_by_month AS
 SELECT m.month,
    ( SELECT count(*) AS count
           FROM (projects p
             JOIN analyses a ON (((p.best_analysis_id = a.id) AND (NOT p.deleted))))
          WHERE (date_trunc('quarter'::text, (a.min_month)::timestamp with time zone) <= date_trunc('quarter'::text, m.month))) AS project_count
   FROM all_months m;


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: projects_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW projects_id_seq_view AS
 SELECT (nextval('projects_id_seq'::regclass))::integer AS id;


--
-- Name: ratings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ratings (
    id integer NOT NULL,
    account_id integer NOT NULL,
    project_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('UTC'::text, now()),
    updated_at timestamp without time zone DEFAULT timezone('UTC'::text, now())
);


--
-- Name: ratings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ratings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ratings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ratings_id_seq OWNED BY ratings.id;


--
-- Name: ratings_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW ratings_id_seq_view AS
 SELECT (nextval('ratings_id_seq'::regclass))::integer AS id;


--
-- Name: recently_active_accounts_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE recently_active_accounts_cache (
    id integer NOT NULL,
    accounts text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: recently_active_accounts_cache_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE recently_active_accounts_cache_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recently_active_accounts_cache_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE recently_active_accounts_cache_id_seq OWNED BY recently_active_accounts_cache.id;


--
-- Name: recently_active_accounts_cache_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW recently_active_accounts_cache_id_seq_view AS
 SELECT (nextval('recently_active_accounts_cache_id_seq'::regclass))::integer AS id;


--
-- Name: recommend_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE recommend_entries (
    id integer NOT NULL,
    project_id integer,
    project_id_recommends integer,
    weight double precision
);


--
-- Name: recommend_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE recommend_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
    CYCLE;


--
-- Name: recommend_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE recommend_entries_id_seq OWNED BY recommend_entries.id;


--
-- Name: recommend_entries_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW recommend_entries_id_seq_view AS
 SELECT (nextval('recommend_entries_id_seq'::regclass))::integer AS id;


--
-- Name: recommendations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE recommendations (
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
-- Name: recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE recommendations_id_seq OWNED BY recommendations.id;


--
-- Name: recommendations_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW recommendations_id_seq_view AS
 SELECT (nextval('recommendations_id_seq'::regclass))::integer AS id;


--
-- Name: releases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE releases (
    id integer NOT NULL,
    kb_release_id character varying NOT NULL,
    released_on timestamp without time zone,
    version character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    project_security_set_id integer
);


--
-- Name: releases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE releases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE releases_id_seq OWNED BY releases.id;


--
-- Name: releases_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW releases_id_seq_view AS
 SELECT (nextval('releases_id_seq'::regclass))::integer AS id;


--
-- Name: releases_vulnerabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE releases_vulnerabilities (
    release_id integer NOT NULL,
    vulnerability_id integer NOT NULL
);


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE reports (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title text
);


--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_id_seq OWNED BY reports.id;


--
-- Name: reports_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW reports_id_seq_view AS
 SELECT (nextval('reports_id_seq'::regclass))::integer AS id;


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE repositories (
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

CREATE SEQUENCE repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE repositories_id_seq OWNED BY repositories.id;


--
-- Name: repositories_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW repositories_id_seq_view AS
 SELECT (nextval('repositories_id_seq'::regclass))::integer AS id;


--
-- Name: repository_directories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE repository_directories (
    id integer NOT NULL,
    code_location_id integer,
    repository_id integer,
    fetched_at timestamp without time zone
);


--
-- Name: repository_directories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE repository_directories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repository_directories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE repository_directories_id_seq OWNED BY repository_directories.id;


--
-- Name: repository_directories_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW repository_directories_id_seq_view AS
 SELECT (nextval('repository_directories_id_seq'::regclass))::integer AS id;


--
-- Name: repository_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE repository_tags (
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

CREATE SEQUENCE repository_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repository_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE repository_tags_id_seq OWNED BY repository_tags.id;


--
-- Name: repository_tags_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW repository_tags_id_seq_view AS
 SELECT (nextval('repository_tags_id_seq'::regclass))::integer AS id;


--
-- Name: reverification_trackers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE reverification_trackers (
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
-- Name: reverification_trackers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reverification_trackers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reverification_trackers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reverification_trackers_id_seq OWNED BY reverification_trackers.id;


--
-- Name: reverification_trackers_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW reverification_trackers_id_seq_view AS
 SELECT (nextval('reverification_trackers_id_seq'::regclass))::integer AS id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE reviews (
    id integer NOT NULL,
    account_id integer NOT NULL,
    project_id integer NOT NULL,
    title text,
    comment text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    helpful_score integer DEFAULT 0 NOT NULL
);


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reviews_id_seq OWNED BY reviews.id;


--
-- Name: reviews_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW reviews_id_seq_view AS
 SELECT (nextval('reviews_id_seq'::regclass))::integer AS id;


--
-- Name: robins_contributions_test; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW robins_contributions_test AS
 SELECT
        CASE
            WHEN (pos.id IS NULL) THEN ((((per.project_id)::bigint << 32) + (per.name_id)::bigint) + (B'10000000000000000000000000000000'::"bit")::bigint)
            ELSE (((pos.project_id)::bigint << 32) + (pos.account_id)::bigint)
        END AS id,
    per.id AS person_id,
    COALESCE(pos.project_id, per.project_id) AS project_id,
        CASE
            WHEN (pos.id IS NULL) THEN per.name_fact_id
            ELSE ( SELECT name_facts.id
               FROM name_facts
              WHERE ((name_facts.analysis_id = p.best_analysis_id) AND (name_facts.name_id = pos.name_id)))
        END AS name_fact_id,
    pos.id AS position_id
   FROM ((people per
     LEFT JOIN positions pos ON ((per.account_id = pos.account_id)))
     JOIN projects p ON ((p.id = COALESCE(pos.project_id, per.project_id))));


--
-- Name: rss_articles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rss_articles (
    id integer NOT NULL,
    rss_feed_id integer,
    guid text NOT NULL,
    "time" timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    title text NOT NULL,
    description text,
    author text,
    link text
);


--
-- Name: rss_articles_2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rss_articles_2 (
    id integer,
    rss_feed_id integer,
    guid text,
    "time" timestamp without time zone,
    title text,
    description text,
    author text,
    link text
);


--
-- Name: rss_articles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rss_articles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rss_articles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rss_articles_id_seq OWNED BY rss_articles.id;


--
-- Name: rss_articles_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW rss_articles_id_seq_view AS
 SELECT (nextval('rss_articles_id_seq'::regclass))::integer AS id;


--
-- Name: rss_feeds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rss_feeds (
    id integer NOT NULL,
    url text NOT NULL,
    last_fetch timestamp without time zone,
    next_fetch timestamp without time zone,
    error text
);


--
-- Name: rss_feeds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rss_feeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rss_feeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rss_feeds_id_seq OWNED BY rss_feeds.id;


--
-- Name: rss_feeds_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW rss_feeds_id_seq_view AS
 SELECT (nextval('rss_feeds_id_seq'::regclass))::integer AS id;


--
-- Name: rss_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rss_subscriptions (
    id integer NOT NULL,
    project_id integer,
    rss_feed_id integer,
    deleted boolean DEFAULT false
);


--
-- Name: rss_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rss_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rss_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rss_subscriptions_id_seq OWNED BY rss_subscriptions.id;


--
-- Name: rss_subscriptions_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW rss_subscriptions_id_seq_view AS
 SELECT (nextval('rss_subscriptions_id_seq'::regclass))::integer AS id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sessions (
    id integer NOT NULL,
    session_id character varying(255),
    data text,
    updated_at timestamp without time zone
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: sessions_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW sessions_id_seq_view AS
 SELECT (nextval('sessions_id_seq'::regclass))::integer AS id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE settings (
    id integer NOT NULL,
    key character varying,
    value character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: settings_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW settings_id_seq_view AS
 SELECT (nextval('settings_id_seq'::regclass))::integer AS id;


--
-- Name: sf_vhosted; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sf_vhosted (
    domain text NOT NULL
);


--
-- Name: sfprojects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sfprojects (
    project_id integer NOT NULL,
    hosted boolean DEFAULT false,
    vhosted boolean DEFAULT false,
    code boolean DEFAULT false,
    downloads boolean DEFAULT false,
    downloads_vhosted boolean DEFAULT false
);


--
-- Name: size_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE size_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: size_facts_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW size_facts_id_seq_view AS
 SELECT (nextval('size_facts_id_seq'::regclass))::integer AS id;


--
-- Name: slave_logs; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE slave_logs (
    id integer DEFAULT slave_logs_id_seq_view() NOT NULL,
    message text,
    created_on timestamp without time zone,
    slave_id integer,
    job_id integer,
    code_set_id integer,
    level integer DEFAULT 0
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'slave_logs'
);
ALTER FOREIGN TABLE slave_logs ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE slave_logs ALTER COLUMN message OPTIONS (
    column_name 'message'
);
ALTER FOREIGN TABLE slave_logs ALTER COLUMN created_on OPTIONS (
    column_name 'created_on'
);
ALTER FOREIGN TABLE slave_logs ALTER COLUMN slave_id OPTIONS (
    column_name 'slave_id'
);
ALTER FOREIGN TABLE slave_logs ALTER COLUMN job_id OPTIONS (
    column_name 'job_id'
);
ALTER FOREIGN TABLE slave_logs ALTER COLUMN code_set_id OPTIONS (
    column_name 'code_set_id'
);
ALTER FOREIGN TABLE slave_logs ALTER COLUMN level OPTIONS (
    column_name 'level'
);


--
-- Name: slave_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE slave_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slave_logs_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE slave_logs_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'slave_logs_id_seq_view'
);
ALTER FOREIGN TABLE slave_logs_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: slave_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE slave_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slave_permissions_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE slave_permissions_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'slave_permissions_id_seq_view'
);
ALTER FOREIGN TABLE slave_permissions_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: slaves; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE slaves (
    id integer DEFAULT slave_permissions_id_seq_view() NOT NULL,
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
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'slaves'
);
ALTER FOREIGN TABLE slaves ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE slaves ALTER COLUMN allow_deny OPTIONS (
    column_name 'allow_deny'
);
ALTER FOREIGN TABLE slaves ALTER COLUMN hostname OPTIONS (
    column_name 'hostname'
);
ALTER FOREIGN TABLE slaves ALTER COLUMN available_blocks OPTIONS (
    column_name 'available_blocks'
);
ALTER FOREIGN TABLE slaves ALTER COLUMN used_blocks OPTIONS (
    column_name 'used_blocks'
);
ALTER FOREIGN TABLE slaves ALTER COLUMN used_percent OPTIONS (
    column_name 'used_percent'
);
ALTER FOREIGN TABLE slaves ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE slaves ALTER COLUMN load_average OPTIONS (
    column_name 'load_average'
);
ALTER FOREIGN TABLE slaves ALTER COLUMN clump_dir OPTIONS (
    column_name 'clump_dir'
);
ALTER FOREIGN TABLE slaves ALTER COLUMN clump_status OPTIONS (
    column_name 'clump_status'
);
ALTER FOREIGN TABLE slaves ALTER COLUMN oldest_clump_timestamp OPTIONS (
    column_name 'oldest_clump_timestamp'
);
ALTER FOREIGN TABLE slaves ALTER COLUMN enable_profiling OPTIONS (
    column_name 'enable_profiling'
);
ALTER FOREIGN TABLE slaves ALTER COLUMN blocked_types OPTIONS (
    column_name 'blocked_types'
);


--
-- Name: sloc_metrics; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE sloc_metrics (
    id bigint DEFAULT sloc_metrics_id_seq_view() NOT NULL,
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
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'sloc_metrics'
);
ALTER FOREIGN TABLE sloc_metrics ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE sloc_metrics ALTER COLUMN diff_id OPTIONS (
    column_name 'diff_id'
);
ALTER FOREIGN TABLE sloc_metrics ALTER COLUMN language_id OPTIONS (
    column_name 'language_id'
);
ALTER FOREIGN TABLE sloc_metrics ALTER COLUMN code_added OPTIONS (
    column_name 'code_added'
);
ALTER FOREIGN TABLE sloc_metrics ALTER COLUMN code_removed OPTIONS (
    column_name 'code_removed'
);
ALTER FOREIGN TABLE sloc_metrics ALTER COLUMN comments_added OPTIONS (
    column_name 'comments_added'
);
ALTER FOREIGN TABLE sloc_metrics ALTER COLUMN comments_removed OPTIONS (
    column_name 'comments_removed'
);
ALTER FOREIGN TABLE sloc_metrics ALTER COLUMN blanks_added OPTIONS (
    column_name 'blanks_added'
);
ALTER FOREIGN TABLE sloc_metrics ALTER COLUMN blanks_removed OPTIONS (
    column_name 'blanks_removed'
);
ALTER FOREIGN TABLE sloc_metrics ALTER COLUMN sloc_set_id OPTIONS (
    column_name 'sloc_set_id'
);


--
-- Name: sloc_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sloc_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sloc_metrics_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE sloc_metrics_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'sloc_metrics_id_seq_view'
);
ALTER FOREIGN TABLE sloc_metrics_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: sloc_sets; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE sloc_sets (
    id integer DEFAULT sloc_sets_id_seq_view() NOT NULL,
    code_set_id integer NOT NULL,
    updated_on timestamp without time zone,
    as_of integer,
    code_set_time timestamp without time zone
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'sloc_sets'
);
ALTER FOREIGN TABLE sloc_sets ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE sloc_sets ALTER COLUMN code_set_id OPTIONS (
    column_name 'code_set_id'
);
ALTER FOREIGN TABLE sloc_sets ALTER COLUMN updated_on OPTIONS (
    column_name 'updated_on'
);
ALTER FOREIGN TABLE sloc_sets ALTER COLUMN as_of OPTIONS (
    column_name 'as_of'
);
ALTER FOREIGN TABLE sloc_sets ALTER COLUMN code_set_time OPTIONS (
    column_name 'code_set_time'
);


--
-- Name: sloc_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sloc_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sloc_sets_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE sloc_sets_id_seq_view (
    id integer
)
SERVER fis
OPTIONS (
    schema_name 'public',
    table_name 'sloc_sets_id_seq_view'
);
ALTER FOREIGN TABLE sloc_sets_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: stack_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE stack_entries (
    id integer NOT NULL,
    stack_id integer,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    note text
);


--
-- Name: stack_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stack_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stack_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stack_entries_id_seq OWNED BY stack_entries.id;


--
-- Name: stack_entries_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW stack_entries_id_seq_view AS
 SELECT (nextval('stack_entries_id_seq'::regclass))::integer AS id;


--
-- Name: stack_ignores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE stack_ignores (
    id integer NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    stack_id integer NOT NULL
);


--
-- Name: stack_ignores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stack_ignores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stack_ignores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stack_ignores_id_seq OWNED BY stack_ignores.id;


--
-- Name: stack_ignores_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW stack_ignores_id_seq_view AS
 SELECT (nextval('stack_ignores_id_seq'::regclass))::integer AS id;


--
-- Name: stacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE stacks (
    id integer NOT NULL,
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
-- Name: stacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stacks_id_seq OWNED BY stacks.id;


--
-- Name: stacks_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW stacks_id_seq_view AS
 SELECT (nextval('stacks_id_seq'::regclass))::integer AS id;


--
-- Name: successful_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE successful_accounts (
    id integer NOT NULL,
    account_id integer
);


--
-- Name: successful_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE successful_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: successful_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE successful_accounts_id_seq OWNED BY successful_accounts.id;


--
-- Name: successful_accounts_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW successful_accounts_id_seq_view AS
 SELECT (nextval('successful_accounts_id_seq'::regclass))::integer AS id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer,
    taggable_id integer,
    taggable_type character varying(255)
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: taggings_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW taggings_id_seq_view AS
 SELECT (nextval('taggings_id_seq'::regclass))::integer AS id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tags (
    id integer NOT NULL,
    name text NOT NULL,
    taggings_count integer DEFAULT 0 NOT NULL,
    weight double precision DEFAULT 1.0 NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: tags_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW tags_id_seq_view AS
 SELECT (nextval('tags_id_seq'::regclass))::integer AS id;


--
-- Name: thirty_day_summaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE thirty_day_summaries (
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
-- Name: thirty_day_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE thirty_day_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thirty_day_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE thirty_day_summaries_id_seq OWNED BY thirty_day_summaries.id;


--
-- Name: thirty_day_summaries_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW thirty_day_summaries_id_seq_view AS
 SELECT (nextval('thirty_day_summaries_id_seq'::regclass))::integer AS id;


--
-- Name: tools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tools (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);


--
-- Name: tools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tools_id_seq OWNED BY tools.id;


--
-- Name: tools_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW tools_id_seq_view AS
 SELECT (nextval('tools_id_seq'::regclass))::integer AS id;


--
-- Name: topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE topics (
    id integer NOT NULL,
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
-- Name: topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE topics_id_seq OWNED BY topics.id;


--
-- Name: topics_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW topics_id_seq_view AS
 SELECT (nextval('topics_id_seq'::regclass))::integer AS id;


--
-- Name: verifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE verifications (
    id integer NOT NULL,
    account_id integer,
    type character varying,
    token character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unique_id character varying
);


--
-- Name: verifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE verifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE verifications_id_seq OWNED BY verifications.id;


--
-- Name: verifications_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW verifications_id_seq_view AS
 SELECT (nextval('verifications_id_seq'::regclass))::integer AS id;


--
-- Name: vita_analyses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vita_analyses (
    id integer NOT NULL,
    vita_id integer,
    analysis_id integer
);


--
-- Name: vita_analyses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vita_analyses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vita_analyses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vita_analyses_id_seq OWNED BY vita_analyses.id;


--
-- Name: vita_analyses_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW vita_analyses_id_seq_view AS
 SELECT (nextval('vita_analyses_id_seq'::regclass))::integer AS id;


--
-- Name: vitae; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vitae (
    id integer NOT NULL,
    account_id integer NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: vitae_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vitae_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vitae_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vitae_id_seq OWNED BY vitae.id;


--
-- Name: vitae_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW vitae_id_seq_view AS
 SELECT (nextval('vitae_id_seq'::regclass))::integer AS id;


--
-- Name: vulnerabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vulnerabilities (
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
-- Name: vulnerabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vulnerabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vulnerabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vulnerabilities_id_seq OWNED BY vulnerabilities.id;


--
-- Name: vulnerabilities_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW vulnerabilities_id_seq_view AS
 SELECT (nextval('vulnerabilities_id_seq'::regclass))::integer AS id;


--
-- Name: vw_projecturlnameedits; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW vw_projecturlnameedits AS
 SELECT edits.project_id,
    edits.value
   FROM edits
  WHERE ((edits.target_type = 'Project'::text) AND (edits.key = 'url_name'::text));


--
-- Name: account_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_reports ALTER COLUMN id SET DEFAULT nextval('account_reports_id_seq'::regclass);


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY actions ALTER COLUMN id SET DEFAULT nextval('actions_id_seq'::regclass);


--
-- Name: activity_facts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY activity_facts ALTER COLUMN id SET DEFAULT nextval('activity_facts_id_seq'::regclass);


--
-- Name: aliases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY aliases ALTER COLUMN id SET DEFAULT nextval('aliases_id_seq'::regclass);


--
-- Name: analyses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY analyses ALTER COLUMN id SET DEFAULT nextval('analyses_id_seq'::regclass);


--
-- Name: analysis_summaries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_summaries ALTER COLUMN id SET DEFAULT nextval('analysis_summaries_id_seq'::regclass);


--
-- Name: api_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys ALTER COLUMN id SET DEFAULT nextval('api_keys_id_seq'::regclass);


--
-- Name: attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: authorizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations ALTER COLUMN id SET DEFAULT nextval('authorizations_id_seq'::regclass);

--
-- Name: broken_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY broken_links ALTER COLUMN id SET DEFAULT nextval('public.broken_links_id_seq'::regclass);


--
-- Name: clumps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY clumps ALTER COLUMN id SET DEFAULT nextval('clumps_id_seq'::regclass);


--
-- Name: code_locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_locations ALTER COLUMN id SET DEFAULT nextval('code_locations_id_seq'::regclass);


--
-- Name: deleted_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY deleted_accounts ALTER COLUMN id SET DEFAULT nextval('deleted_accounts_id_seq'::regclass);


--
-- Name: duplicates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY duplicates ALTER COLUMN id SET DEFAULT nextval('duplicates_id_seq'::regclass);


--
-- Name: enlistments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY enlistments ALTER COLUMN id SET DEFAULT nextval('enlistments_id_seq'::regclass);


--
-- Name: event_subscription id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_subscription ALTER COLUMN id SET DEFAULT nextval('event_subscription_id_seq'::regclass);


--
-- Name: exhibits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY exhibits ALTER COLUMN id SET DEFAULT nextval('exhibits_id_seq'::regclass);


--
-- Name: factoids id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY factoids ALTER COLUMN id SET DEFAULT nextval('factoids_id_seq'::regclass);


--
-- Name: failure_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY failure_groups ALTER COLUMN id SET DEFAULT nextval('failure_groups_id_seq'::regclass);


--
-- Name: feedbacks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY feedbacks ALTER COLUMN id SET DEFAULT nextval('feedbacks_id_seq'::regclass);


--
-- Name: follows id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY follows ALTER COLUMN id SET DEFAULT nextval('follows_id_seq'::regclass);


--
-- Name: forges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY forges ALTER COLUMN id SET DEFAULT nextval('forges_id_seq'::regclass);


--
-- Name: forums id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY forums ALTER COLUMN id SET DEFAULT nextval('forums_id_seq'::regclass);


--
-- Name: helpfuls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY helpfuls ALTER COLUMN id SET DEFAULT nextval('helpfuls_id_seq'::regclass);


--
-- Name: invites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites ALTER COLUMN id SET DEFAULT nextval('invites_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs ALTER COLUMN id SET DEFAULT nextval('jobs_id_seq'::regclass);


--
-- Name: knowledge_base_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY knowledge_base_statuses ALTER COLUMN id SET DEFAULT nextval('knowledge_base_statuses_id_seq'::regclass);


--
-- Name: kudo_scores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY kudo_scores ALTER COLUMN id SET DEFAULT nextval('kudo_scores_id_seq'::regclass);


--
-- Name: kudos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY kudos ALTER COLUMN id SET DEFAULT nextval('kudos_id_seq'::regclass);


--
-- Name: language_experiences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY language_experiences ALTER COLUMN id SET DEFAULT nextval('language_experiences_id_seq'::regclass);


--
-- Name: language_facts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY language_facts ALTER COLUMN id SET DEFAULT nextval('language_facts_id_seq'::regclass);


--
-- Name: languages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY languages ALTER COLUMN id SET DEFAULT nextval('languages_id_seq'::regclass);


--
-- Name: license_facts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY license_facts ALTER COLUMN id SET DEFAULT nextval('license_facts_id_seq'::regclass);


--
-- Name: license_permission_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY license_permission_roles ALTER COLUMN id SET DEFAULT nextval('license_permission_roles_id_seq'::regclass);


--
-- Name: license_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY license_permissions ALTER COLUMN id SET DEFAULT nextval('license_permissions_id_seq'::regclass);


--
-- Name: licenses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY licenses ALTER COLUMN id SET DEFAULT nextval('licenses_id_seq'::regclass);


--
-- Name: link_categories_deleted id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY link_categories_deleted ALTER COLUMN id SET DEFAULT nextval('link_categories_id_seq'::regclass);


--
-- Name: links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: manages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY manages ALTER COLUMN id SET DEFAULT nextval('manages_id_seq'::regclass);


--
-- Name: markups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY markups ALTER COLUMN id SET DEFAULT nextval('markups_id_seq'::regclass);


--
-- Name: message_account_tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_account_tags ALTER COLUMN id SET DEFAULT nextval('message_account_tags_id_seq'::regclass);


--
-- Name: message_project_tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_project_tags ALTER COLUMN id SET DEFAULT nextval('message_project_tags_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: monthly_commit_histories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY monthly_commit_histories ALTER COLUMN id SET DEFAULT nextval('monthly_commit_histories_id_seq'::regclass);


--
-- Name: name_facts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_facts ALTER COLUMN id SET DEFAULT nextval('name_facts_id_seq'::regclass);


--
-- Name: name_language_facts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_language_facts ALTER COLUMN id SET DEFAULT nextval('name_language_facts_id_seq'::regclass);


--
-- Name: names id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY names ALTER COLUMN id SET DEFAULT nextval('names_id_seq'::regclass);


--
-- Name: oauth_access_grants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);


--
-- Name: oauth_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);


--
-- Name: oauth_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);


--
-- Name: oauth_nonces id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_nonces ALTER COLUMN id SET DEFAULT nextval('oauth_nonces_id_seq'::regclass);


--
-- Name: org_stats_by_sectors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY org_stats_by_sectors ALTER COLUMN id SET DEFAULT nextval('org_stats_by_sectors_id_seq'::regclass);


--
-- Name: org_thirty_day_activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY org_thirty_day_activities ALTER COLUMN id SET DEFAULT nextval('org_thirty_day_activities_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions ALTER COLUMN id SET DEFAULT nextval('permissions_id_seq'::regclass);


--
-- Name: positions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions ALTER COLUMN id SET DEFAULT nextval('positions_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- Name: profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);


--
-- Name: project_badges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_badges ALTER COLUMN id SET DEFAULT nextval('project_badges_id_seq'::regclass);


--
-- Name: project_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_events ALTER COLUMN id SET DEFAULT nextval('project_events_id_seq'::regclass);


--
-- Name: project_experiences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_experiences ALTER COLUMN id SET DEFAULT nextval('project_experiences_id_seq'::regclass);


--
-- Name: project_licenses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_licenses ALTER COLUMN id SET DEFAULT nextval('project_licenses_id_seq'::regclass);


--
-- Name: project_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_reports ALTER COLUMN id SET DEFAULT nextval('project_reports_id_seq'::regclass);


--
-- Name: project_security_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_security_sets ALTER COLUMN id SET DEFAULT nextval('project_security_sets_id_seq'::regclass);


--
-- Name: project_vulnerability_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_vulnerability_reports ALTER COLUMN id SET DEFAULT nextval('project_vulnerability_reports_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: ratings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ratings ALTER COLUMN id SET DEFAULT nextval('ratings_id_seq'::regclass);


--
-- Name: recently_active_accounts_cache id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY recently_active_accounts_cache ALTER COLUMN id SET DEFAULT nextval('recently_active_accounts_cache_id_seq'::regclass);


--
-- Name: recommend_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommend_entries ALTER COLUMN id SET DEFAULT nextval('recommend_entries_id_seq'::regclass);


--
-- Name: recommendations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommendations ALTER COLUMN id SET DEFAULT nextval('recommendations_id_seq'::regclass);


--
-- Name: releases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY releases ALTER COLUMN id SET DEFAULT nextval('releases_id_seq'::regclass);


--
-- Name: reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports ALTER COLUMN id SET DEFAULT nextval('reports_id_seq'::regclass);


--
-- Name: repositories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories ALTER COLUMN id SET DEFAULT nextval('repositories_id_seq'::regclass);


--
-- Name: repository_directories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY repository_directories ALTER COLUMN id SET DEFAULT nextval('repository_directories_id_seq'::regclass);


--
-- Name: repository_tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY repository_tags ALTER COLUMN id SET DEFAULT nextval('repository_tags_id_seq'::regclass);


--
-- Name: reverification_trackers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reverification_trackers ALTER COLUMN id SET DEFAULT nextval('reverification_trackers_id_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reviews ALTER COLUMN id SET DEFAULT nextval('reviews_id_seq'::regclass);


--
-- Name: rss_articles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rss_articles ALTER COLUMN id SET DEFAULT nextval('rss_articles_id_seq'::regclass);


--
-- Name: rss_feeds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rss_feeds ALTER COLUMN id SET DEFAULT nextval('rss_feeds_id_seq'::regclass);


--
-- Name: rss_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rss_subscriptions ALTER COLUMN id SET DEFAULT nextval('rss_subscriptions_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: stack_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stack_entries ALTER COLUMN id SET DEFAULT nextval('stack_entries_id_seq'::regclass);


--
-- Name: stack_ignores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stack_ignores ALTER COLUMN id SET DEFAULT nextval('stack_ignores_id_seq'::regclass);


--
-- Name: stacks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stacks ALTER COLUMN id SET DEFAULT nextval('stacks_id_seq'::regclass);


--
-- Name: successful_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY successful_accounts ALTER COLUMN id SET DEFAULT nextval('successful_accounts_id_seq'::regclass);


--
-- Name: taggings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: thirty_day_summaries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY thirty_day_summaries ALTER COLUMN id SET DEFAULT nextval('thirty_day_summaries_id_seq'::regclass);


--
-- Name: tools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tools ALTER COLUMN id SET DEFAULT nextval('tools_id_seq'::regclass);


--
-- Name: topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics ALTER COLUMN id SET DEFAULT nextval('topics_id_seq'::regclass);


--
-- Name: verifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY verifications ALTER COLUMN id SET DEFAULT nextval('verifications_id_seq'::regclass);


--
-- Name: vita_analyses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vita_analyses ALTER COLUMN id SET DEFAULT nextval('vita_analyses_id_seq'::regclass);


--
-- Name: vitae id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vitae ALTER COLUMN id SET DEFAULT nextval('vitae_id_seq'::regclass);


--
-- Name: vulnerabilities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerabilities ALTER COLUMN id SET DEFAULT nextval('vulnerabilities_id_seq'::regclass);


--
-- Name: account_reports account_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_reports
    ADD CONSTRAINT account_reports_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_email_key UNIQUE (email);


--
-- Name: accounts accounts_login_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_login_key UNIQUE (login);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: actions actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (id);


--
-- Name: activity_facts activity_facts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activity_facts
    ADD CONSTRAINT activity_facts_pkey PRIMARY KEY (id);


--
-- Name: aliases aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY aliases
    ADD CONSTRAINT aliases_pkey PRIMARY KEY (id);


--
-- Name: aliases aliases_project_id_name_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY aliases
    ADD CONSTRAINT aliases_project_id_name_id UNIQUE (project_id, commit_name_id);


--
-- Name: analyses analyses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analyses
    ADD CONSTRAINT analyses_pkey PRIMARY KEY (id);


--
-- Name: analysis_summaries analysis_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_summaries
    ADD CONSTRAINT analysis_summaries_pkey PRIMARY KEY (id);


--
-- Name: api_keys api_keys_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT api_keys_key_key UNIQUE (key);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authorizations authorizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT authorizations_pkey PRIMARY KEY (id);


--
-- Name: broken_links broken_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY broken_links
    ADD CONSTRAINT broken_links_pkey PRIMARY KEY (id);


--
-- Name: positions claims_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT claims_pkey PRIMARY KEY (id);


--
-- Name: clumps clumps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY clumps
    ADD CONSTRAINT clumps_pkey PRIMARY KEY (id);


--
-- Name: code_locations code_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_locations
    ADD CONSTRAINT code_locations_pkey PRIMARY KEY (id);


--
-- Name: deleted_accounts deleted_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY deleted_accounts
    ADD CONSTRAINT deleted_accounts_pkey PRIMARY KEY (id);


--
-- Name: duplicates duplicates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY duplicates
    ADD CONSTRAINT duplicates_pkey PRIMARY KEY (id);


--
-- Name: edits edits_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edits
    ADD CONSTRAINT edits_pkey1 PRIMARY KEY (id);


--
-- Name: enlistments enlistments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enlistments
    ADD CONSTRAINT enlistments_pkey PRIMARY KEY (id);


--
-- Name: event_subscription event_subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_subscription
    ADD CONSTRAINT event_subscription_pkey PRIMARY KEY (id);


--
-- Name: exhibits exhibits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY exhibits
    ADD CONSTRAINT exhibits_pkey PRIMARY KEY (id);


--
-- Name: factoids factoids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY factoids
    ADD CONSTRAINT factoids_pkey PRIMARY KEY (id);


--
-- Name: failure_groups failure_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY failure_groups
    ADD CONSTRAINT failure_groups_pkey PRIMARY KEY (id);


--
-- Name: feedbacks feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (id);


--
-- Name: follows follows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY follows
    ADD CONSTRAINT follows_pkey PRIMARY KEY (id);


--
-- Name: forges forges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY forges
    ADD CONSTRAINT forges_pkey PRIMARY KEY (id);


--
-- Name: forges forges_type_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY forges
    ADD CONSTRAINT forges_type_key UNIQUE (type);


--
-- Name: forums forums_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY forums
    ADD CONSTRAINT forums_pkey PRIMARY KEY (id);


--
-- Name: github_project github_project_project_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY github_project
    ADD CONSTRAINT github_project_project_id_key UNIQUE (project_id, owner);


--
-- Name: helpfuls helpfuls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY helpfuls
    ADD CONSTRAINT helpfuls_pkey PRIMARY KEY (id);


--
-- Name: invites invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_statuses knowledge_base_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY knowledge_base_statuses
    ADD CONSTRAINT knowledge_base_statuses_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_statuses knowledge_base_statuses_project_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY knowledge_base_statuses
    ADD CONSTRAINT knowledge_base_statuses_project_id_key UNIQUE (project_id);


--
-- Name: kudo_scores kudo_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY kudo_scores
    ADD CONSTRAINT kudo_scores_pkey PRIMARY KEY (id);


--
-- Name: kudos kudos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY kudos
    ADD CONSTRAINT kudos_pkey PRIMARY KEY (id);


--
-- Name: language_experiences language_experiences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY language_experiences
    ADD CONSTRAINT language_experiences_pkey PRIMARY KEY (id);


--
-- Name: language_facts language_facts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY language_facts
    ADD CONSTRAINT language_facts_pkey PRIMARY KEY (id);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: license_facts license_facts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY license_facts
    ADD CONSTRAINT license_facts_pkey PRIMARY KEY (id);


--
-- Name: license_permission_roles license_permission_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY license_permission_roles
    ADD CONSTRAINT license_permission_roles_pkey PRIMARY KEY (id);


--
-- Name: license_permissions license_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY license_permissions
    ADD CONSTRAINT license_permissions_pkey PRIMARY KEY (id);


--
-- Name: licenses licenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (id);


--
-- Name: link_categories_deleted link_categories_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY link_categories_deleted
    ADD CONSTRAINT link_categories_name_key UNIQUE (name);


--
-- Name: link_categories_deleted link_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY link_categories_deleted
    ADD CONSTRAINT link_categories_pkey PRIMARY KEY (id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: manages manages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY manages
    ADD CONSTRAINT manages_pkey PRIMARY KEY (id);


--
-- Name: markups markups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY markups
    ADD CONSTRAINT markups_pkey PRIMARY KEY (id);


--
-- Name: message_account_tags message_account_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_account_tags
    ADD CONSTRAINT message_account_tags_pkey PRIMARY KEY (id);


--
-- Name: message_project_tags message_project_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_project_tags
    ADD CONSTRAINT message_project_tags_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: monthly_commit_histories monthly_commit_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY monthly_commit_histories
    ADD CONSTRAINT monthly_commit_histories_pkey PRIMARY KEY (id);


--
-- Name: name_facts name_facts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_facts
    ADD CONSTRAINT name_facts_pkey PRIMARY KEY (id);


--
-- Name: name_language_facts name_language_facts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_language_facts
    ADD CONSTRAINT name_language_facts_pkey PRIMARY KEY (id);


--
-- Name: names names_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY names
    ADD CONSTRAINT names_name_key UNIQUE (name);


--
-- Name: names names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY names
    ADD CONSTRAINT names_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: oauth_nonces oauth_nonces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_nonces
    ADD CONSTRAINT oauth_nonces_pkey PRIMARY KEY (id);


--
-- Name: org_stats_by_sectors org_stats_by_sectors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY org_stats_by_sectors
    ADD CONSTRAINT org_stats_by_sectors_pkey PRIMARY KEY (id);


--
-- Name: org_thirty_day_activities org_thirty_day_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY org_thirty_day_activities
    ADD CONSTRAINT org_thirty_day_activities_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: people people_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_id_key UNIQUE (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: pg_ts_cfg pg_ts_cfg_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pg_ts_cfg
    ADD CONSTRAINT pg_ts_cfg_pkey PRIMARY KEY (ts_name);


--
-- Name: pg_ts_cfgmap pg_ts_cfgmap_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pg_ts_cfgmap
    ADD CONSTRAINT pg_ts_cfgmap_pkey PRIMARY KEY (ts_name, tok_alias);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: project_badges project_badges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_badges
    ADD CONSTRAINT project_badges_pkey PRIMARY KEY (id);


--
-- Name: project_events project_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_events
    ADD CONSTRAINT project_events_pkey PRIMARY KEY (id);


--
-- Name: project_experiences project_experiences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_experiences
    ADD CONSTRAINT project_experiences_pkey PRIMARY KEY (id);


--
-- Name: project_licenses project_licenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_licenses
    ADD CONSTRAINT project_licenses_pkey PRIMARY KEY (id);


--
-- Name: project_reports project_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_reports
    ADD CONSTRAINT project_reports_pkey PRIMARY KEY (id);


--
-- Name: project_reports project_reports_project_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_reports
    ADD CONSTRAINT project_reports_project_id_key UNIQUE (project_id, report_id);


--
-- Name: project_security_sets project_security_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_security_sets
    ADD CONSTRAINT project_security_sets_pkey PRIMARY KEY (id);


--
-- Name: project_vulnerability_reports project_vulnerability_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_vulnerability_reports
    ADD CONSTRAINT project_vulnerability_reports_pkey PRIMARY KEY (id);


--
-- Name: projects projects_kb_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_kb_id_key UNIQUE (kb_id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: projects projects_url_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_url_name_key UNIQUE (vanity_url);


--
-- Name: ratings ratings_account_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ratings
    ADD CONSTRAINT ratings_account_id_key UNIQUE (account_id, project_id);


--
-- Name: ratings ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (id);


--
-- Name: recommend_entries recommend_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommend_entries
    ADD CONSTRAINT recommend_entries_pkey PRIMARY KEY (id);


--
-- Name: recommendations recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommendations
    ADD CONSTRAINT recommendations_pkey PRIMARY KEY (id);


--
-- Name: releases releases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY releases
    ADD CONSTRAINT releases_pkey PRIMARY KEY (id);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: repositories repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: repository_directories repository_directories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repository_directories
    ADD CONSTRAINT repository_directories_pkey PRIMARY KEY (id);


--
-- Name: repository_tags repository_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repository_tags
    ADD CONSTRAINT repository_tags_pkey PRIMARY KEY (id);


--
-- Name: reverification_trackers reverification_trackers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reverification_trackers
    ADD CONSTRAINT reverification_trackers_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_account_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_account_id_key UNIQUE (account_id, project_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: rss_articles rss_articles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rss_articles
    ADD CONSTRAINT rss_articles_pkey PRIMARY KEY (id);


--
-- Name: rss_feeds rss_feeds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rss_feeds
    ADD CONSTRAINT rss_feeds_pkey PRIMARY KEY (id);


--
-- Name: rss_subscriptions rss_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rss_subscriptions
    ADD CONSTRAINT rss_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_session_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_session_id_key UNIQUE (session_id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: stack_entries stack_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stack_entries
    ADD CONSTRAINT stack_entries_pkey PRIMARY KEY (id);


--
-- Name: stack_ignores stack_ignores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stack_ignores
    ADD CONSTRAINT stack_ignores_pkey PRIMARY KEY (id);


--
-- Name: stacks stacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stacks
    ADD CONSTRAINT stacks_pkey PRIMARY KEY (id);


--
-- Name: successful_accounts successful_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY successful_accounts
    ADD CONSTRAINT successful_accounts_pkey PRIMARY KEY (id);


--
-- Name: taggings taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: thirty_day_summaries thirty_day_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY thirty_day_summaries
    ADD CONSTRAINT thirty_day_summaries_pkey PRIMARY KEY (id);


--
-- Name: tools tools_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tools
    ADD CONSTRAINT tools_name_key UNIQUE (name);


--
-- Name: tools tools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tools
    ADD CONSTRAINT tools_pkey PRIMARY KEY (id);


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: positions unique_account_id_project_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT unique_account_id_project_id UNIQUE (account_id, project_id);


--
-- Name: authorizations unique_authorizations_token; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT unique_authorizations_token UNIQUE (token);


--
-- Name: oauth_nonces unique_oauth_nonces_nonce_timestamp; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_nonces
    ADD CONSTRAINT unique_oauth_nonces_nonce_timestamp UNIQUE (nonce, "timestamp");


--
-- Name: project_events unique_project_events; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_events
    ADD CONSTRAINT unique_project_events UNIQUE (project_id, type, key);


--
-- Name: positions unique_project_id_name_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT unique_project_id_name_id UNIQUE (project_id, name_id);


--
-- Name: rss_subscriptions unique_project_id_rss_feed_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rss_subscriptions
    ADD CONSTRAINT unique_project_id_rss_feed_id UNIQUE (project_id, rss_feed_id);


--
-- Name: rss_articles unique_rss_feed_id_guid; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rss_articles
    ADD CONSTRAINT unique_rss_feed_id_guid UNIQUE (rss_feed_id, guid);


--
-- Name: taggings unique_taggings_tag_id_taggable_id_taggable_type; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT unique_taggings_tag_id_taggable_id_taggable_type UNIQUE (tag_id, taggable_id, taggable_type);


--
-- Name: verifications verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY verifications
    ADD CONSTRAINT verifications_pkey PRIMARY KEY (id);


--
-- Name: vita_analyses vita_analyses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vita_analyses
    ADD CONSTRAINT vita_analyses_pkey PRIMARY KEY (id);


--
-- Name: vitae vitae_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vitae
    ADD CONSTRAINT vitae_pkey PRIMARY KEY (id);


--
-- Name: vulnerabilities vulnerabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT vulnerabilities_pkey PRIMARY KEY (id);


--
-- Name: edits_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX edits_organization_id ON edits USING btree (organization_id) WHERE (organization_id IS NOT NULL);


--
-- Name: edits_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX edits_project_id ON edits USING btree (project_id) WHERE (project_id IS NOT NULL);


--
-- Name: github_project_owner_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX github_project_owner_idx ON github_project USING btree (owner);


--
-- Name: github_project_project_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX github_project_project_id_idx ON github_project USING btree (project_id);


--
-- Name: index_account_reports_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_reports_on_account_id ON account_reports USING btree (account_id);


--
-- Name: index_account_reports_on_report_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_reports_on_report_id ON account_reports USING btree (report_id);


--
-- Name: index_accounts_on_best_vita_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_best_vita_id ON accounts USING btree (best_vita_id) WHERE (best_vita_id IS NOT NULL);


--
-- Name: index_accounts_on_email_md5; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_email_md5 ON accounts USING btree (email_md5);


--
-- Name: index_accounts_on_lower_login; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_accounts_on_lower_login ON accounts USING btree (lower(login));


--
-- Name: index_accounts_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_organization_id ON accounts USING btree (organization_id);


--
-- Name: index_actions_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_actions_on_account_id ON actions USING btree (account_id);


--
-- Name: index_activity_facts_on_analysis_id_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_facts_on_analysis_id_month ON activity_facts USING btree (analysis_id, month);


--
-- Name: index_activity_facts_on_language_id_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_facts_on_language_id_month ON activity_facts USING btree (language_id, month);


--
-- Name: index_activity_facts_on_name_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_facts_on_name_id ON activity_facts USING btree (name_id);


--
-- Name: index_analyses_on_logged_at_day; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_analyses_on_logged_at_day ON analyses USING btree (oldest_code_set_time, date_trunc('day'::text, oldest_code_set_time)) WHERE (oldest_code_set_time IS NOT NULL);


--
-- Name: index_analyses_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_analyses_on_project_id ON analyses USING btree (project_id);


--
-- Name: index_analysis_summaries_on_analysis_id_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_analysis_summaries_on_analysis_id_type ON analysis_summaries USING btree (analysis_id, type);


--
-- Name: index_api_keys_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_keys_on_key ON api_keys USING btree (key);


--
-- Name: index_api_keys_on_oauth_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_keys_on_oauth_application_id ON api_keys USING btree (oauth_application_id);


--
-- Name: index_authorizations_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorizations_on_account_id ON authorizations USING btree (account_id);


--
-- Name: index_authorizations_on_api_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorizations_on_api_key_id ON authorizations USING btree (api_key_id);


--
-- Name: index_claims_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_claims_on_account_id ON positions USING btree (account_id);


--
-- Name: index_clumps_on_code_set_id_slave_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clumps_on_code_set_id_slave_id ON clumps USING btree (code_set_id, slave_id);


--
-- Name: index_code_locations_on_best_code_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_locations_on_best_code_set_id ON code_locations USING btree (best_code_set_id);


--
-- Name: index_code_locations_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_locations_on_repository_id ON code_locations USING btree (repository_id);


--
-- Name: index_code_locations_on_repository_id_and_module_branch_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_code_locations_on_repository_id_and_module_branch_name ON code_locations USING btree (repository_id, module_branch_name);


--
-- Name: index_duplicates_on_bad_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_duplicates_on_bad_project_id ON duplicates USING btree (bad_project_id);


--
-- Name: index_duplicates_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_duplicates_on_created_at ON duplicates USING btree (created_at);


--
-- Name: index_duplicates_on_good_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_duplicates_on_good_project_id ON duplicates USING btree (good_project_id);


--
-- Name: index_edits_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_edits_on_account_id ON edits USING btree (account_id);


--
-- Name: index_edits_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_edits_on_created_at ON edits USING btree (created_at);


--
-- Name: index_edits_on_edits; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_edits_on_edits ON edits USING btree (target_type, target_id, key);


--
-- Name: index_enlistments_on_code_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enlistments_on_code_location_id ON enlistments USING btree (code_location_id);


--
-- Name: index_enlistments_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enlistments_on_project_id ON enlistments USING btree (project_id) WHERE (deleted IS FALSE);


--
-- Name: index_enlistments_on_project_id_and_code_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_enlistments_on_project_id_and_code_location_id ON enlistments USING btree (project_id, code_location_id);


--
-- Name: index_enlistments_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enlistments_on_repository_id ON enlistments USING btree (repository_id) WHERE (deleted IS FALSE);


--
-- Name: index_exhibits_on_report_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exhibits_on_report_id ON exhibits USING btree (report_id);


--
-- Name: index_factoids_on_analysis_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_factoids_on_analysis_id ON factoids USING btree (analysis_id);


--
-- Name: index_failure_groups_on_priority_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_failure_groups_on_priority_name ON failure_groups USING btree (priority, name);


--
-- Name: index_follows_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_follows_on_account_id ON follows USING btree (account_id);


--
-- Name: index_follows_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_follows_on_owner_id ON follows USING btree (owner_id);


--
-- Name: index_follows_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_follows_on_project_id ON follows USING btree (project_id);


--
-- Name: index_helpfuls_on_review_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_helpfuls_on_review_id ON helpfuls USING btree (review_id);


--
-- Name: index_jobs_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_account_id ON jobs USING btree (account_id);


--
-- Name: index_jobs_on_code_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_code_location_id ON jobs USING btree (code_location_id);


--
-- Name: index_jobs_on_code_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_code_set_id ON jobs USING btree (code_set_id);


--
-- Name: index_jobs_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_project_id ON jobs USING btree (project_id);


--
-- Name: index_jobs_on_slave_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_slave_id_status ON jobs USING btree (slave_id, status);


--
-- Name: index_jobs_on_slave_id_status_current_step; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_slave_id_status_current_step ON jobs USING btree (slave_id, status, current_step_at);


--
-- Name: index_jobs_on_sloc_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_sloc_set_id ON jobs USING btree (sloc_set_id);


--
-- Name: index_kudo_scores_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kudo_scores_on_account_id ON kudo_scores USING btree (account_id);


--
-- Name: index_kudo_scores_on_array_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kudo_scores_on_array_index ON kudo_scores USING btree (array_index);


--
-- Name: index_kudo_scores_on_project_id_name_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kudo_scores_on_project_id_name_id ON kudo_scores USING btree (project_id, name_id);


--
-- Name: index_kudos_on_from_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kudos_on_from_account_id ON kudos USING btree (sender_id);


--
-- Name: index_language_facts_on_month_language_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_language_facts_on_month_language_id ON language_facts USING btree (month, language_id);


--
-- Name: index_license_facts_on_analysis_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_license_facts_on_analysis_id ON license_facts USING btree (analysis_id);


--
-- Name: index_licenses_on_vanity_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_licenses_on_vanity_url ON licenses USING btree (vanity_url);


--
-- Name: index_links_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_project_id ON links USING btree (project_id);


--
-- Name: index_manages_on_target_account_deleted_by; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_manages_on_target_account_deleted_by ON manages USING btree (target_id, target_type, account_id) WHERE ((deleted_at IS NULL) AND (deleted_by IS NULL));


--
-- Name: index_message_account_tags_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_message_account_tags_on_account_id ON message_account_tags USING btree (account_id);


--
-- Name: index_message_account_tags_on_message_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_message_account_tags_on_message_id ON message_account_tags USING btree (message_id);


--
-- Name: index_message_project_tags_on_message_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_message_project_tags_on_message_id ON message_project_tags USING btree (message_id);


--
-- Name: index_message_project_tags_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_message_project_tags_on_project_id ON message_project_tags USING btree (project_id);


--
-- Name: index_messages_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_messages_on_account_id ON messages USING btree (account_id);


--
-- Name: index_monthly_commit_histories_on_analysis_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_monthly_commit_histories_on_analysis_id ON monthly_commit_histories USING btree (analysis_id);


--
-- Name: index_name_facts_email_address_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_name_facts_email_address_ids ON name_facts USING gin (email_address_ids) WHERE (type = 'ContributorFact'::text);


--
-- Name: index_name_facts_on_analysis_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_name_facts_on_analysis_id ON name_facts USING btree (analysis_id);


--
-- Name: index_name_facts_on_analysis_id_and_name_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_name_facts_on_analysis_id_and_name_id ON name_facts USING btree (analysis_id, name_id);


--
-- Name: index_name_facts_on_analysis_id_contributors; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_name_facts_on_analysis_id_contributors ON name_facts USING btree (analysis_id) WHERE (type = 'ContributorFact'::text);


--
-- Name: index_name_facts_on_vita_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_name_facts_on_vita_id ON name_facts USING btree (vita_id);


--
-- Name: index_name_language_facts_analysis_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_name_language_facts_analysis_id ON name_language_facts USING btree (analysis_id);


--
-- Name: index_name_language_facts_name_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_name_language_facts_name_id ON name_language_facts USING btree (name_id);


--
-- Name: index_name_language_facts_on_language_id_total_months; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_name_language_facts_on_language_id_total_months ON name_language_facts USING btree (language_id, total_months DESC) WHERE (vita_id IS NOT NULL);


--
-- Name: index_name_language_facts_on_vita_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_name_language_facts_on_vita_id ON name_language_facts USING btree (vita_id);


--
-- Name: index_names_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_names_on_name ON names USING btree (name);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_org_stats_by_sectors_on_created_at_and_org_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_org_stats_by_sectors_on_created_at_and_org_type ON org_stats_by_sectors USING btree (created_at, org_type);


--
-- Name: index_organizations_on_lower_url_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_lower_url_name ON organizations USING btree (lower(vanity_url));


--
-- Name: index_organizations_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_name ON organizations USING btree (lower(name));


--
-- Name: index_organizations_on_vector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_vector ON organizations USING gin (vector);


--
-- Name: index_people_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_gin ON people USING gin (vector);


--
-- Name: index_people_name_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_name_id ON people USING btree (name_id) WHERE (name_id IS NOT NULL);


--
-- Name: index_people_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_on_account_id ON people USING btree (account_id);


--
-- Name: index_people_on_kudo_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_on_kudo_position ON people USING btree ((COALESCE(kudo_position, 999999999)));


--
-- Name: index_people_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_on_project_id ON people USING btree (project_id);


--
-- Name: index_people_on_vector_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_on_vector_gin ON people USING gin (vector);


--
-- Name: index_permissions_on_target; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_target ON permissions USING btree (target_id, target_type);


--
-- Name: index_positions_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_positions_on_organization_id ON positions USING btree (organization_id);


--
-- Name: index_posts_on_vector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_vector ON posts USING gist (vector);


--
-- Name: index_profiles_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_profiles_on_job_id ON profiles USING btree (job_id);


--
-- Name: index_project_badges_on_enlistment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_badges_on_enlistment_id ON project_badges USING btree (enlistment_id);


--
-- Name: index_project_events_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_events_on_project_id ON project_events USING btree (project_id);


--
-- Name: index_project_experiences_on_position_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_experiences_on_position_id ON project_experiences USING btree (position_id);


--
-- Name: index_project_licenses_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_licenses_project_id ON project_licenses USING btree (project_id);


--
-- Name: index_project_reports_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_reports_on_project_id ON project_reports USING btree (project_id);


--
-- Name: index_project_reports_on_report_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_reports_on_report_id ON project_reports USING btree (report_id);


--
-- Name: index_project_security_sets_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_security_sets_on_project_id ON project_security_sets USING btree (project_id);


--
-- Name: index_project_vulnerability_reports_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_vulnerability_reports_on_project_id ON project_vulnerability_reports USING btree (project_id);


--
-- Name: index_projects_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_deleted ON projects USING btree (deleted, id);


--
-- Name: index_projects_on_best_analysis_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_best_analysis_id ON projects USING btree (best_analysis_id);


--
-- Name: index_projects_on_lower_url_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_lower_url_name ON projects USING btree (lower(vanity_url));


--
-- Name: index_projects_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_name ON projects USING btree (lower(name));


--
-- Name: index_projects_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_organization_id ON projects USING btree (organization_id);


--
-- Name: index_projects_on_user_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_user_count ON projects USING btree (user_count DESC) WHERE (NOT deleted);


--
-- Name: index_projects_on_vector_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_vector_gin ON projects USING gin (vector);


--
-- Name: index_ratings_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ratings_on_project_id ON ratings USING btree (project_id);


--
-- Name: index_recommend_entries_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recommend_entries_on_project_id ON recommend_entries USING btree (project_id);


--
-- Name: index_releases_on_kb_release_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_releases_on_kb_release_id ON releases USING btree (kb_release_id);


--
-- Name: index_releases_on_project_security_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_releases_on_project_security_set_id ON releases USING btree (project_security_set_id);


--
-- Name: index_releases_vulnerabilities_on_release_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_releases_vulnerabilities_on_release_id ON releases_vulnerabilities USING btree (release_id);


--
-- Name: index_releases_vulnerabilities_on_vulnerability_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_releases_vulnerabilities_on_vulnerability_id ON releases_vulnerabilities USING btree (vulnerability_id);


--
-- Name: index_repositories_on_forge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_forge_id ON repositories USING btree (forge_id);


--
-- Name: index_repository_directories_on_code_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repository_directories_on_code_location_id ON repository_directories USING btree (code_location_id);


--
-- Name: index_repository_directories_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repository_directories_on_repository_id ON repository_directories USING btree (repository_id);


--
-- Name: index_repository_tags_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repository_tags_on_repository_id ON repository_tags USING btree (repository_id);


--
-- Name: index_reviews_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_account_id ON reviews USING btree (account_id);


--
-- Name: index_reviews_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_project_id ON reviews USING btree (project_id);


--
-- Name: index_rss_articles_rss_feed_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rss_articles_rss_feed_id ON rss_articles USING btree (rss_feed_id);


--
-- Name: index_rss_articles_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rss_articles_time ON rss_articles USING btree ("time");


--
-- Name: index_rss_subscriptions_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rss_subscriptions_project_id ON rss_subscriptions USING btree (project_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_settings_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_settings_on_key ON settings USING btree (key);


--
-- Name: index_stack_entries_on_project_stack_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stack_entries_on_project_stack_id ON stack_entries USING btree (project_id, stack_id) WHERE (deleted_at IS NULL);


--
-- Name: index_stacks_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stacks_account_id ON stacks USING btree (account_id);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_taggable_id ON taggings USING btree (taggable_id);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_thirty_day_summaries_on_analysis_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_thirty_day_summaries_on_analysis_id ON thirty_day_summaries USING btree (analysis_id);


--
-- Name: index_vita_analyses_on_analysis_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vita_analyses_on_analysis_id ON vita_analyses USING btree (analysis_id);


--
-- Name: index_vita_analyses_on_vita_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vita_analyses_on_vita_id ON vita_analyses USING btree (vita_id);


--
-- Name: index_vitae_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vitae_on_account_id ON vitae USING btree (account_id);


--
-- Name: index_vulnerabilities_on_cve_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerabilities_on_cve_id ON vulnerabilities USING btree (cve_id);


--
-- Name: kudos_uniques; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX kudos_uniques ON kudos USING btree (sender_id, (COALESCE(account_id, 0)), (COALESCE(project_id, 0)), (COALESCE(name_id, 0)));


--
-- Name: people_on_name_fact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX people_on_name_fact_id ON people USING btree (name_fact_id);


--
-- Name: posts_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX posts_account_id ON posts USING btree (account_id);


--
-- Name: posts_topic_ic; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX posts_topic_ic ON posts USING btree (topic_id);


--
-- Name: releases_vulnerabilities_release_id_vulnerability_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX releases_vulnerabilities_release_id_vulnerability_id_idx ON releases_vulnerabilities USING btree (release_id, vulnerability_id);


--
-- Name: robin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX robin ON name_facts USING btree (last_checkin) WHERE (type = 'VitaFact'::text);


--
-- Name: stack_entry_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stack_entry_project_id ON stack_entries USING btree (project_id);


--
-- Name: stack_entry_stack_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stack_entry_stack_id ON stack_entries USING btree (stack_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: unique_stacks_titles_per_account; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_stacks_titles_per_account ON stacks USING btree (account_id, title);


--
-- Name: unique_stacks_titles_per_project; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_stacks_titles_per_project ON stacks USING btree (project_id, title);


--
-- Name: account_reports account_reports_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_reports
    ADD CONSTRAINT account_reports_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: account_reports account_reports_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_reports
    ADD CONSTRAINT account_reports_report_id_fkey FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE;


--
-- Name: accounts accounts_about_markup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_about_markup_id_fkey FOREIGN KEY (about_markup_id) REFERENCES markups(id) ON DELETE CASCADE;


--
-- Name: accounts accounts_best_vita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_best_vita_id_fkey FOREIGN KEY (best_vita_id) REFERENCES vitae(id);


--
-- Name: accounts accounts_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;


--
-- Name: actions actions_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY actions
    ADD CONSTRAINT actions_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: actions actions_claim_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY actions
    ADD CONSTRAINT actions_claim_person_id_fkey FOREIGN KEY (claim_person_id) REFERENCES people(id);


--
-- Name: actions actions_stack_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY actions
    ADD CONSTRAINT actions_stack_project_id_fkey FOREIGN KEY (stack_project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: activity_facts activity_facts_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activity_facts
    ADD CONSTRAINT activity_facts_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: activity_facts activity_facts_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activity_facts
    ADD CONSTRAINT activity_facts_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id);


--
-- Name: aliases aliases_commit_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY aliases
    ADD CONSTRAINT aliases_commit_name_id_fkey FOREIGN KEY (commit_name_id) REFERENCES names(id) ON DELETE CASCADE;


--
-- Name: aliases aliases_preferred_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY aliases
    ADD CONSTRAINT aliases_preferred_name_id_fkey FOREIGN KEY (preferred_name_id) REFERENCES names(id) ON DELETE CASCADE;


--
-- Name: aliases aliases_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY aliases
    ADD CONSTRAINT aliases_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: analyses analyses_main_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analyses
    ADD CONSTRAINT analyses_main_language_id_fkey FOREIGN KEY (main_language_id) REFERENCES languages(id);


--
-- Name: analyses analyses_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analyses
    ADD CONSTRAINT analyses_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: analysis_summaries analysis_summaries_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_summaries
    ADD CONSTRAINT analysis_summaries_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id);


--
-- Name: api_keys api_keys_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT api_keys_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: authorizations authorizations_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT authorizations_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: authorizations authorizations_api_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT authorizations_api_key_id_fkey FOREIGN KEY (api_key_id) REFERENCES api_keys(id) ON DELETE CASCADE;


--
-- Name: positions claims_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT claims_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: positions claims_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT claims_name_id_fkey FOREIGN KEY (name_id) REFERENCES names(id) ON DELETE CASCADE;


--
-- Name: positions claims_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT claims_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: duplicates duplicates_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY duplicates
    ADD CONSTRAINT duplicates_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: duplicates duplicates_bad_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY duplicates
    ADD CONSTRAINT duplicates_bad_project_id_fkey FOREIGN KEY (bad_project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: duplicates duplicates_good_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY duplicates
    ADD CONSTRAINT duplicates_good_project_id_fkey FOREIGN KEY (good_project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: edits edits_account_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edits
    ADD CONSTRAINT edits_account_id_fkey1 FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: edits edits_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edits
    ADD CONSTRAINT edits_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;


--
-- Name: edits edits_project_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edits
    ADD CONSTRAINT edits_project_id_fkey1 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: edits edits_undone_by_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edits
    ADD CONSTRAINT edits_undone_by_fkey1 FOREIGN KEY (undone_by) REFERENCES accounts(id);


--
-- Name: enlistments enlistments_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enlistments
    ADD CONSTRAINT enlistments_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: enlistments enlistments_repository_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enlistments
    ADD CONSTRAINT enlistments_repository_id_fkey FOREIGN KEY (repository_id) REFERENCES repositories(id) ON DELETE CASCADE;


--
-- Name: event_subscription event_subscription_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_subscription
    ADD CONSTRAINT event_subscription_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: event_subscription event_subscription_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_subscription
    ADD CONSTRAINT event_subscription_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: event_subscription event_subscription_subscriber_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_subscription
    ADD CONSTRAINT event_subscription_subscriber_id_fkey FOREIGN KEY (subscriber_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: event_subscription event_subscription_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_subscription
    ADD CONSTRAINT event_subscription_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE;


--
-- Name: exhibits exhibits_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY exhibits
    ADD CONSTRAINT exhibits_report_id_fkey FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE;


--
-- Name: factoids factoids_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY factoids
    ADD CONSTRAINT factoids_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: factoids factoids_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY factoids
    ADD CONSTRAINT factoids_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id);


--
-- Name: factoids factoids_license_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY factoids
    ADD CONSTRAINT factoids_license_id_fkey FOREIGN KEY (license_id) REFERENCES licenses(id);


--
-- Name: org_thirty_day_activities fk_organization_ids; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY org_thirty_day_activities
    ADD CONSTRAINT fk_organization_ids FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;


--
-- Name: project_vulnerability_reports fk_project_ids; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_vulnerability_reports
    ADD CONSTRAINT fk_project_ids FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: code_locations fk_rails_0ff5ad97b1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_locations
    ADD CONSTRAINT fk_rails_0ff5ad97b1 FOREIGN KEY (repository_id) REFERENCES repositories(id);


--
-- Name: repository_tags fk_rails_275a40dd6e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repository_tags
    ADD CONSTRAINT fk_rails_275a40dd6e FOREIGN KEY (repository_id) REFERENCES repositories(id);


--
-- Name: project_badges fk_rails_4c3c9e5c61; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_badges
    ADD CONSTRAINT fk_rails_4c3c9e5c61 FOREIGN KEY (enlistment_id) REFERENCES enlistments(id);


--
-- Name: api_keys fk_rails_8faa63554c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT fk_rails_8faa63554c FOREIGN KEY (oauth_application_id) REFERENCES oauth_applications(id);


--
-- Name: projects fk_rails_c67f665226; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT fk_rails_c67f665226 FOREIGN KEY (best_project_security_set_id) REFERENCES project_security_sets(id);


--
-- Name: repository_directories fk_rails_d33c461543; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repository_directories
    ADD CONSTRAINT fk_rails_d33c461543 FOREIGN KEY (code_location_id) REFERENCES code_locations(id);


--
-- Name: repository_directories fk_rails_d36c79e15c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repository_directories
    ADD CONSTRAINT fk_rails_d36c79e15c FOREIGN KEY (repository_id) REFERENCES repositories(id);


--
-- Name: project_security_sets fk_rails_efaa9c9657; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_security_sets
    ADD CONSTRAINT fk_rails_efaa9c9657 FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: follows follows_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY follows
    ADD CONSTRAINT follows_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: follows follows_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY follows
    ADD CONSTRAINT follows_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: follows follows_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY follows
    ADD CONSTRAINT follows_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: forums forums_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY forums
    ADD CONSTRAINT forums_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: helpfuls helpfuls_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY helpfuls
    ADD CONSTRAINT helpfuls_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: helpfuls helpfuls_review_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY helpfuls
    ADD CONSTRAINT helpfuls_review_id_fkey FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE;


--
-- Name: invites invites_invitee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_invitee_id_fkey FOREIGN KEY (invitee_id) REFERENCES accounts(id);


--
-- Name: invites invites_invitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_invitor_id_fkey FOREIGN KEY (invitor_id) REFERENCES accounts(id);


--
-- Name: invites invites_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_name_id_fkey FOREIGN KEY (name_id) REFERENCES names(id);


--
-- Name: invites invites_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: jobs jobs_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: jobs jobs_failure_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_failure_group_id_fkey FOREIGN KEY (failure_group_id) REFERENCES failure_groups(id);


--
-- Name: jobs jobs_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: knowledge_base_statuses knowledge_base_statuses_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY knowledge_base_statuses
    ADD CONSTRAINT knowledge_base_statuses_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: kudos kudos_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY kudos
    ADD CONSTRAINT kudos_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: kudos kudos_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY kudos
    ADD CONSTRAINT kudos_name_id_fkey FOREIGN KEY (name_id) REFERENCES names(id) ON DELETE CASCADE;


--
-- Name: kudos kudos_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY kudos
    ADD CONSTRAINT kudos_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: kudos kudos_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY kudos
    ADD CONSTRAINT kudos_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: language_experiences language_experiences_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY language_experiences
    ADD CONSTRAINT language_experiences_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE;


--
-- Name: language_experiences language_experiences_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY language_experiences
    ADD CONSTRAINT language_experiences_position_id_fkey FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE CASCADE;


--
-- Name: language_facts language_facts_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY language_facts
    ADD CONSTRAINT language_facts_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE;


--
-- Name: license_facts license_facts_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY license_facts
    ADD CONSTRAINT license_facts_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: license_facts license_facts_license_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY license_facts
    ADD CONSTRAINT license_facts_license_id_fkey FOREIGN KEY (license_id) REFERENCES licenses(id);


--
-- Name: links links_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: manages manages_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY manages
    ADD CONSTRAINT manages_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: manages manages_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY manages
    ADD CONSTRAINT manages_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES accounts(id);


--
-- Name: manages manages_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY manages
    ADD CONSTRAINT manages_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES accounts(id);


--
-- Name: message_account_tags message_account_tags_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_account_tags
    ADD CONSTRAINT message_account_tags_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: message_account_tags message_account_tags_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_account_tags
    ADD CONSTRAINT message_account_tags_message_id_fkey FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE;


--
-- Name: message_project_tags message_project_tags_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_project_tags
    ADD CONSTRAINT message_project_tags_message_id_fkey FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE;


--
-- Name: message_project_tags message_project_tags_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_project_tags
    ADD CONSTRAINT message_project_tags_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: messages messages_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: name_facts name_facts_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_facts
    ADD CONSTRAINT name_facts_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: name_facts name_facts_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_facts
    ADD CONSTRAINT name_facts_name_id_fkey FOREIGN KEY (name_id) REFERENCES names(id);


--
-- Name: name_facts name_facts_primary_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_facts
    ADD CONSTRAINT name_facts_primary_language_id_fkey FOREIGN KEY (primary_language_id) REFERENCES languages(id);


--
-- Name: name_facts name_facts_vita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_facts
    ADD CONSTRAINT name_facts_vita_id_fkey FOREIGN KEY (vita_id) REFERENCES vitae(id) ON DELETE CASCADE;


--
-- Name: name_language_facts name_language_facts_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_language_facts
    ADD CONSTRAINT name_language_facts_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: name_language_facts name_language_facts_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_language_facts
    ADD CONSTRAINT name_language_facts_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE;


--
-- Name: name_language_facts name_language_facts_most_commits_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_language_facts
    ADD CONSTRAINT name_language_facts_most_commits_project_id_fkey FOREIGN KEY (most_commits_project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: name_language_facts name_language_facts_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_language_facts
    ADD CONSTRAINT name_language_facts_name_id_fkey FOREIGN KEY (name_id) REFERENCES names(id) ON DELETE CASCADE;


--
-- Name: name_language_facts name_language_facts_recent_commit_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_language_facts
    ADD CONSTRAINT name_language_facts_recent_commit_project_id_fkey FOREIGN KEY (recent_commit_project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: name_language_facts name_language_facts_vita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_language_facts
    ADD CONSTRAINT name_language_facts_vita_id_fkey FOREIGN KEY (vita_id) REFERENCES vitae(id) ON DELETE CASCADE;


--
-- Name: organizations organizations_logo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_logo_id_fkey FOREIGN KEY (logo_id) REFERENCES attachments(id);


--
-- Name: people people_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: people people_name_fact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_name_fact_id_fkey FOREIGN KEY (name_fact_id) REFERENCES name_facts(id) ON DELETE CASCADE;


--
-- Name: people people_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_name_id_fkey FOREIGN KEY (name_id) REFERENCES names(id) ON DELETE CASCADE;


--
-- Name: people people_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: positions positions_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT positions_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;


--
-- Name: posts posts_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: posts posts_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: project_events project_events_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_events
    ADD CONSTRAINT project_events_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: project_experiences project_experiences_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_experiences
    ADD CONSTRAINT project_experiences_position_id_fkey FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE CASCADE;


--
-- Name: project_experiences project_experiences_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_experiences
    ADD CONSTRAINT project_experiences_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: project_licenses project_licenses_license_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_licenses
    ADD CONSTRAINT project_licenses_license_id_fkey FOREIGN KEY (license_id) REFERENCES licenses(id) ON DELETE CASCADE;


--
-- Name: project_licenses project_licenses_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_licenses
    ADD CONSTRAINT project_licenses_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: project_reports project_reports_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_reports
    ADD CONSTRAINT project_reports_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: project_reports project_reports_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_reports
    ADD CONSTRAINT project_reports_report_id_fkey FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE;


--
-- Name: projects projects_best_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_best_analysis_id_fkey FOREIGN KEY (best_analysis_id) REFERENCES analyses(id);


--
-- Name: projects projects_forge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_forge_id_fkey FOREIGN KEY (forge_id) REFERENCES forges(id);


--
-- Name: projects projects_logo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_logo_id_fkey FOREIGN KEY (logo_id) REFERENCES attachments(id);


--
-- Name: projects projects_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations(id);


--
-- Name: ratings ratings_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ratings
    ADD CONSTRAINT ratings_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: ratings ratings_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ratings
    ADD CONSTRAINT ratings_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: recommend_entries recommend_entries_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommend_entries
    ADD CONSTRAINT recommend_entries_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: recommend_entries recommend_entries_project_id_recommends_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommend_entries
    ADD CONSTRAINT recommend_entries_project_id_recommends_fkey FOREIGN KEY (project_id_recommends) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: recommendations recommendations_invitee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommendations
    ADD CONSTRAINT recommendations_invitee_id_fkey FOREIGN KEY (invitee_id) REFERENCES accounts(id);


--
-- Name: recommendations recommendations_invitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommendations
    ADD CONSTRAINT recommendations_invitor_id_fkey FOREIGN KEY (invitor_id) REFERENCES accounts(id);


--
-- Name: recommendations recommendations_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommendations
    ADD CONSTRAINT recommendations_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: repositories repositories_forge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT repositories_forge_id_fkey FOREIGN KEY (forge_id) REFERENCES forges(id);


--
-- Name: reviews reviews_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: rss_articles rss_articles_rss_feed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rss_articles
    ADD CONSTRAINT rss_articles_rss_feed_id_fkey FOREIGN KEY (rss_feed_id) REFERENCES rss_feeds(id) ON DELETE CASCADE;


--
-- Name: rss_subscriptions rss_subscriptions_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rss_subscriptions
    ADD CONSTRAINT rss_subscriptions_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: rss_subscriptions rss_subscriptions_rss_feed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rss_subscriptions
    ADD CONSTRAINT rss_subscriptions_rss_feed_id_fkey FOREIGN KEY (rss_feed_id) REFERENCES rss_feeds(id) ON DELETE CASCADE;


--
-- Name: sfprojects sfprojects_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sfprojects
    ADD CONSTRAINT sfprojects_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: stack_entries stack_entries_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stack_entries
    ADD CONSTRAINT stack_entries_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: stack_entries stack_entries_stack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stack_entries
    ADD CONSTRAINT stack_entries_stack_id_fkey FOREIGN KEY (stack_id) REFERENCES stacks(id) ON DELETE CASCADE;


--
-- Name: stack_ignores stack_ignores_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stack_ignores
    ADD CONSTRAINT stack_ignores_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: stack_ignores stack_ignores_stack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stack_ignores
    ADD CONSTRAINT stack_ignores_stack_id_fkey FOREIGN KEY (stack_id) REFERENCES stacks(id) ON DELETE CASCADE;


--
-- Name: stacks stacks_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stacks
    ADD CONSTRAINT stacks_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: stacks stacks_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stacks
    ADD CONSTRAINT stacks_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: thirty_day_summaries thirty_day_summaries_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY thirty_day_summaries
    ADD CONSTRAINT thirty_day_summaries_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: topics topics_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: topics topics_forum_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_forum_id_fkey FOREIGN KEY (forum_id) REFERENCES forums(id) ON DELETE CASCADE;


--
-- Name: topics topics_replied_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_replied_by_fkey FOREIGN KEY (replied_by) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: vita_analyses vita_analyses_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vita_analyses
    ADD CONSTRAINT vita_analyses_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: vita_analyses vita_analyses_vita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vita_analyses
    ADD CONSTRAINT vita_analyses_vita_id_fkey FOREIGN KEY (vita_id) REFERENCES vitae(id) ON DELETE CASCADE;


--
-- Name: vitae vitae_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vitae
    ADD CONSTRAINT vitae_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('100');

INSERT INTO schema_migrations (version) VALUES ('101');

INSERT INTO schema_migrations (version) VALUES ('102');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20120917115347');

INSERT INTO schema_migrations (version) VALUES ('20121010151415');

INSERT INTO schema_migrations (version) VALUES ('20121010154611');

INSERT INTO schema_migrations (version) VALUES ('20121019120254');

INSERT INTO schema_migrations (version) VALUES ('20121115192205');

INSERT INTO schema_migrations (version) VALUES ('20121203072938');

INSERT INTO schema_migrations (version) VALUES ('20121221075843');

INSERT INTO schema_migrations (version) VALUES ('20130103212213');

INSERT INTO schema_migrations (version) VALUES ('20130204030958');

INSERT INTO schema_migrations (version) VALUES ('20130327120650');

INSERT INTO schema_migrations (version) VALUES ('20130328044901');

INSERT INTO schema_migrations (version) VALUES ('20130420101845');

INSERT INTO schema_migrations (version) VALUES ('20130523194226');

INSERT INTO schema_migrations (version) VALUES ('20130605004148');

INSERT INTO schema_migrations (version) VALUES ('20130606080722');

INSERT INTO schema_migrations (version) VALUES ('20130619111100');

INSERT INTO schema_migrations (version) VALUES ('20130620090419');

INSERT INTO schema_migrations (version) VALUES ('20130701124737');

INSERT INTO schema_migrations (version) VALUES ('20130702025530');

INSERT INTO schema_migrations (version) VALUES ('20130703092324');

INSERT INTO schema_migrations (version) VALUES ('20130724115118');

INSERT INTO schema_migrations (version) VALUES ('20130902064947');

INSERT INTO schema_migrations (version) VALUES ('20130930174253');

INSERT INTO schema_migrations (version) VALUES ('20131025003543');

INSERT INTO schema_migrations (version) VALUES ('20131104041543');

INSERT INTO schema_migrations (version) VALUES ('20131113192205');

INSERT INTO schema_migrations (version) VALUES ('20140205202717');

INSERT INTO schema_migrations (version) VALUES ('20140206140232');

INSERT INTO schema_migrations (version) VALUES ('20140413074943');

INSERT INTO schema_migrations (version) VALUES ('20140507104529');

INSERT INTO schema_migrations (version) VALUES ('20140507172200');

INSERT INTO schema_migrations (version) VALUES ('20140707112715');

INSERT INTO schema_migrations (version) VALUES ('20140707151308');

INSERT INTO schema_migrations (version) VALUES ('20140707202707');

INSERT INTO schema_migrations (version) VALUES ('20140819100329');

INSERT INTO schema_migrations (version) VALUES ('20140902095714');

INSERT INTO schema_migrations (version) VALUES ('20140905072436');

INSERT INTO schema_migrations (version) VALUES ('20141016164532');

INSERT INTO schema_migrations (version) VALUES ('20141024100301');

INSERT INTO schema_migrations (version) VALUES ('20141111214901');

INSERT INTO schema_migrations (version) VALUES ('20141124061121');

INSERT INTO schema_migrations (version) VALUES ('20141209070219');

INSERT INTO schema_migrations (version) VALUES ('20141209070642');

INSERT INTO schema_migrations (version) VALUES ('20150213162109');

INSERT INTO schema_migrations (version) VALUES ('20150423054225');

INSERT INTO schema_migrations (version) VALUES ('20150423061349');

INSERT INTO schema_migrations (version) VALUES ('20150429084504');

INSERT INTO schema_migrations (version) VALUES ('20150504072306');

INSERT INTO schema_migrations (version) VALUES ('20150615040531');

INSERT INTO schema_migrations (version) VALUES ('20150615041336');

INSERT INTO schema_migrations (version) VALUES ('20150701173333');

INSERT INTO schema_migrations (version) VALUES ('20150911083411');

INSERT INTO schema_migrations (version) VALUES ('20150911094444');

INSERT INTO schema_migrations (version) VALUES ('20150916092930');

INSERT INTO schema_migrations (version) VALUES ('20150918080726');

INSERT INTO schema_migrations (version) VALUES ('20150925101230');

INSERT INTO schema_migrations (version) VALUES ('20150925101715');

INSERT INTO schema_migrations (version) VALUES ('20151116113941');

INSERT INTO schema_migrations (version) VALUES ('20151124143945');

INSERT INTO schema_migrations (version) VALUES ('20160121110527');

INSERT INTO schema_migrations (version) VALUES ('20160209204755');

INSERT INTO schema_migrations (version) VALUES ('20160216095409');

INSERT INTO schema_migrations (version) VALUES ('20160317061932');

INSERT INTO schema_migrations (version) VALUES ('20160318131123');

INSERT INTO schema_migrations (version) VALUES ('20160504104102');

INSERT INTO schema_migrations (version) VALUES ('20160504111046');

INSERT INTO schema_migrations (version) VALUES ('20160512144023');

INSERT INTO schema_migrations (version) VALUES ('20160608090419');

INSERT INTO schema_migrations (version) VALUES ('20160608194402');

INSERT INTO schema_migrations (version) VALUES ('20160610142302');

INSERT INTO schema_migrations (version) VALUES ('20160710125644');

INSERT INTO schema_migrations (version) VALUES ('20160713124305');

INSERT INTO schema_migrations (version) VALUES ('20160725154001');

INSERT INTO schema_migrations (version) VALUES ('20160803102211');

INSERT INTO schema_migrations (version) VALUES ('20160804081950');

INSERT INTO schema_migrations (version) VALUES ('20160808163201');

INSERT INTO schema_migrations (version) VALUES ('20160818102530');

INSERT INTO schema_migrations (version) VALUES ('20160907122530');

INSERT INTO schema_migrations (version) VALUES ('20160916124401');

INSERT INTO schema_migrations (version) VALUES ('20160920113102');

INSERT INTO schema_migrations (version) VALUES ('20160926144901');

INSERT INTO schema_migrations (version) VALUES ('20161006072823');

INSERT INTO schema_migrations (version) VALUES ('20161007083447');

INSERT INTO schema_migrations (version) VALUES ('20161024095609');

INSERT INTO schema_migrations (version) VALUES ('20161027065200');

INSERT INTO schema_migrations (version) VALUES ('20161101134545');

INSERT INTO schema_migrations (version) VALUES ('20161103153643');

INSERT INTO schema_migrations (version) VALUES ('20161114063801');

INSERT INTO schema_migrations (version) VALUES ('20161128183115');

INSERT INTO schema_migrations (version) VALUES ('20161227165430');

INSERT INTO schema_migrations (version) VALUES ('20170112183242');

INSERT INTO schema_migrations (version) VALUES ('20170117164106');

INSERT INTO schema_migrations (version) VALUES ('20170127062247');

INSERT INTO schema_migrations (version) VALUES ('20170206161036');

INSERT INTO schema_migrations (version) VALUES ('20170301092424');

INSERT INTO schema_migrations (version) VALUES ('20170320110140');

INSERT INTO schema_migrations (version) VALUES ('20170323130035');

INSERT INTO schema_migrations (version) VALUES ('20170411054438');

INSERT INTO schema_migrations (version) VALUES ('20170609195100');

INSERT INTO schema_migrations (version) VALUES ('20170616152705');

INSERT INTO schema_migrations (version) VALUES ('20170806122538');

INSERT INTO schema_migrations (version) VALUES ('20170806141217');

INSERT INTO schema_migrations (version) VALUES ('20170904072947');

INSERT INTO schema_migrations (version) VALUES ('20170911071916');

INSERT INTO schema_migrations (version) VALUES ('20171017162841');

INSERT INTO schema_migrations (version) VALUES ('20171107131744');

INSERT INTO schema_migrations (version) VALUES ('20171127153012');

INSERT INTO schema_migrations (version) VALUES ('20171204073648');

INSERT INTO schema_migrations (version) VALUES ('20171220032437');

INSERT INTO schema_migrations (version) VALUES ('20180109182901');

INSERT INTO schema_migrations (version) VALUES ('20180925181605');

INSERT INTO schema_migrations (version) VALUES ('20181126091803');

INSERT INTO schema_migrations (version) VALUES ('20190108060802');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('28');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('30');

INSERT INTO schema_migrations (version) VALUES ('31');

INSERT INTO schema_migrations (version) VALUES ('32');

INSERT INTO schema_migrations (version) VALUES ('33');

INSERT INTO schema_migrations (version) VALUES ('34');

INSERT INTO schema_migrations (version) VALUES ('35');

INSERT INTO schema_migrations (version) VALUES ('36');

INSERT INTO schema_migrations (version) VALUES ('37');

INSERT INTO schema_migrations (version) VALUES ('38');

INSERT INTO schema_migrations (version) VALUES ('39');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('40');

INSERT INTO schema_migrations (version) VALUES ('41');

INSERT INTO schema_migrations (version) VALUES ('42');

INSERT INTO schema_migrations (version) VALUES ('43');

INSERT INTO schema_migrations (version) VALUES ('44');

INSERT INTO schema_migrations (version) VALUES ('45');

INSERT INTO schema_migrations (version) VALUES ('46');

INSERT INTO schema_migrations (version) VALUES ('47');

INSERT INTO schema_migrations (version) VALUES ('48');

INSERT INTO schema_migrations (version) VALUES ('49');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('50');

INSERT INTO schema_migrations (version) VALUES ('51');

INSERT INTO schema_migrations (version) VALUES ('52');

INSERT INTO schema_migrations (version) VALUES ('53');

INSERT INTO schema_migrations (version) VALUES ('54');

INSERT INTO schema_migrations (version) VALUES ('55');

INSERT INTO schema_migrations (version) VALUES ('56');

INSERT INTO schema_migrations (version) VALUES ('57');

INSERT INTO schema_migrations (version) VALUES ('58');

INSERT INTO schema_migrations (version) VALUES ('59');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('60');

INSERT INTO schema_migrations (version) VALUES ('61');

INSERT INTO schema_migrations (version) VALUES ('62');

INSERT INTO schema_migrations (version) VALUES ('63');

INSERT INTO schema_migrations (version) VALUES ('64');

INSERT INTO schema_migrations (version) VALUES ('65');

INSERT INTO schema_migrations (version) VALUES ('66');

INSERT INTO schema_migrations (version) VALUES ('67');

INSERT INTO schema_migrations (version) VALUES ('68');

INSERT INTO schema_migrations (version) VALUES ('69');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('70');

INSERT INTO schema_migrations (version) VALUES ('71');

INSERT INTO schema_migrations (version) VALUES ('72');

INSERT INTO schema_migrations (version) VALUES ('73');

INSERT INTO schema_migrations (version) VALUES ('74');

INSERT INTO schema_migrations (version) VALUES ('75');

INSERT INTO schema_migrations (version) VALUES ('76');

INSERT INTO schema_migrations (version) VALUES ('77');

INSERT INTO schema_migrations (version) VALUES ('78');

INSERT INTO schema_migrations (version) VALUES ('79');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('80');

INSERT INTO schema_migrations (version) VALUES ('81');

INSERT INTO schema_migrations (version) VALUES ('82');

INSERT INTO schema_migrations (version) VALUES ('83');

INSERT INTO schema_migrations (version) VALUES ('84');

INSERT INTO schema_migrations (version) VALUES ('85');

INSERT INTO schema_migrations (version) VALUES ('86');

INSERT INTO schema_migrations (version) VALUES ('87');

INSERT INTO schema_migrations (version) VALUES ('88');

INSERT INTO schema_migrations (version) VALUES ('89');

INSERT INTO schema_migrations (version) VALUES ('9');

INSERT INTO schema_migrations (version) VALUES ('90');

INSERT INTO schema_migrations (version) VALUES ('91');

INSERT INTO schema_migrations (version) VALUES ('92');

INSERT INTO schema_migrations (version) VALUES ('93');

INSERT INTO schema_migrations (version) VALUES ('94');

INSERT INTO schema_migrations (version) VALUES ('95');

INSERT INTO schema_migrations (version) VALUES ('96');

INSERT INTO schema_migrations (version) VALUES ('97');

INSERT INTO schema_migrations (version) VALUES ('98');

INSERT INTO schema_migrations (version) VALUES ('99');

