--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

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
-- Name: check_jobs(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_jobs(integer) RETURNS integer
    LANGUAGE sql
    AS $_$select repository_id as RESULT from jobs where status != 5 AND  repository_id= $1;$_$;


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


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id integer DEFAULT nextval('accounts_id_seq'::regclass) NOT NULL,
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
    reset_password_tokens text,
    organization_id integer,
    affiliation_type text DEFAULT 'unaffiliated'::text NOT NULL,
    organization_name text,
    CONSTRAINT accounts_email_check CHECK ((length(email) >= 3)),
    CONSTRAINT accounts_login_check CHECK ((length(login) >= 3))
);


--
-- Name: actions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: activity_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activity_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_facts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
    id bigint DEFAULT nextval('activity_facts_id_seq'::regclass) NOT NULL,
    analysis_id integer NOT NULL,
    commits integer DEFAULT 0,
    on_trunk boolean DEFAULT true
);


--
-- Name: aliases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: all_months; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE all_months (
    month timestamp without time zone
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
-- Name: analyses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE analyses (
    id integer DEFAULT nextval('analyses_id_seq'::regclass) NOT NULL,
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
    logged_at timestamp without time zone,
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
-- Name: analysis_aliases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE analysis_aliases (
    id integer NOT NULL,
    analysis_id integer NOT NULL,
    commit_name_id integer NOT NULL,
    preferred_name_id integer NOT NULL
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
-- Name: analysis_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE analysis_aliases_id_seq OWNED BY analysis_aliases.id;


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
-- Name: analysis_sloc_sets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE analysis_sloc_sets (
    id integer DEFAULT nextval('analysis_sloc_sets_id_seq'::regclass) NOT NULL,
    analysis_id integer NOT NULL,
    sloc_set_id integer NOT NULL,
    as_of integer,
    logged_at timestamp without time zone,
    ignore text,
    ignored_fyle_count integer
);


--
-- Name: analysis_summaries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: attachments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: authorizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: commits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE commits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE commits (
    id integer DEFAULT nextval('commits_id_seq'::regclass) NOT NULL,
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
-- Name: positions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer DEFAULT nextval('projects_id_seq'::regclass) NOT NULL,
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
    CONSTRAINT valid_missing_source CHECK ((((missing_source IS NULL) OR (missing_source = 'not available'::text)) OR (missing_source = 'not supported'::text)))
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
-- Name: sloc_sets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sloc_sets (
    id integer DEFAULT nextval('sloc_sets_id_seq'::regclass) NOT NULL,
    code_set_id integer NOT NULL,
    updated_on timestamp without time zone,
    as_of integer,
    logged_at timestamp without time zone
);


--
-- Name: c2; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW c2 AS
 SELECT commits.id,
    commits.id AS commit_id,
    analysis_sloc_sets.analysis_id,
    projects.id AS project_id,
    analysis_sloc_sets.sloc_set_id,
    sloc_sets.code_set_id,
    positions.id AS position_id,
    positions.account_id,
        CASE
            WHEN (positions.account_id IS NULL) THEN ((((projects.id)::bigint << 32) + (commits.name_id)::bigint) + (B'10000000000000000000000000000000'::"bit")::bigint)
            ELSE (((projects.id)::bigint << 32) + (positions.account_id)::bigint)
        END AS contribution_id,
        CASE
            WHEN (positions.account_id IS NULL) THEN ((((projects.id)::bigint << 32) + (commits.name_id)::bigint) + (B'10000000000000000000000000000000'::"bit")::bigint)
            ELSE (positions.account_id)::bigint
        END AS person_id
   FROM (((((analysis_sloc_sets
     JOIN projects ON ((analysis_sloc_sets.analysis_id = projects.best_analysis_id)))
     JOIN sloc_sets ON ((sloc_sets.id = analysis_sloc_sets.sloc_set_id)))
     JOIN commits ON (((commits.code_set_id = sloc_sets.code_set_id) AND (commits."position" <= analysis_sloc_sets.as_of))))
     JOIN analysis_aliases ON (((analysis_aliases.analysis_id = projects.best_analysis_id) AND (analysis_aliases.commit_name_id = commits.name_id))))
     LEFT JOIN positions ON (((positions.project_id = projects.id) AND (positions.name_id = analysis_aliases.preferred_name_id))));


--
-- Name: clumps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: code_set_gestalts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE code_set_gestalts (
    id integer NOT NULL,
    date timestamp without time zone NOT NULL,
    code_set_id integer,
    gestalt_id integer
);


--
-- Name: code_set_gestalts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE code_set_gestalts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_set_gestalts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE code_set_gestalts_id_seq OWNED BY code_set_gestalts.id;


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
-- Name: code_sets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE code_sets (
    id integer DEFAULT nextval('code_sets_id_seq'::regclass) NOT NULL,
    repository_id integer NOT NULL,
    updated_on timestamp without time zone,
    best_sloc_set_id integer,
    as_of integer,
    logged_at timestamp without time zone,
    clump_count integer DEFAULT 0,
    fetched_at timestamp without time zone
);


--
-- Name: commit_flags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE commit_flags (
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

CREATE SEQUENCE commit_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commit_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE commit_flags_id_seq OWNED BY commit_flags.id;


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
-- Name: name_facts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE name_facts (
    id integer DEFAULT nextval('name_facts_id_seq'::regclass) NOT NULL,
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
-- Name: people; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
    CONSTRAINT people_name_fact_id_account_id CHECK (((((name_fact_id IS NOT NULL) AND (name_id IS NOT NULL)) AND (project_id IS NOT NULL)) OR (account_id IS NOT NULL)))
);


--
-- Name: contributions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW contributions AS
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
-- Name: countries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE countries (
    country_code text,
    continent_code text,
    name text,
    region text
);


--
-- Name: deleted_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: diff_licenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE diff_licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


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
-- Name: diffs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE diffs (
    id bigint DEFAULT nextval('diffs_id_seq'::regclass) NOT NULL,
    sha1 text,
    parent_sha1 text,
    commit_id integer,
    fyle_id integer,
    name text,
    deleted boolean,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: domain_blacklists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE domain_blacklists (
    id integer NOT NULL,
    domain character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: domain_blacklists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE domain_blacklists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: domain_blacklists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE domain_blacklists_id_seq OWNED BY domain_blacklists.id;


--
-- Name: duplicates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: edits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE edits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: edits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: email_addresses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE email_addresses (
    id integer NOT NULL,
    address text NOT NULL
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
-- Name: email_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE email_addresses_id_seq OWNED BY email_addresses.id;


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
-- Name: enlistments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE enlistments (
    id integer DEFAULT nextval('enlistments_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    repository_id integer NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    updated_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    ignore text
);


--
-- Name: event_subscription; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: exhibits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: factoids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE factoids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: factoids; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE factoids (
    id integer DEFAULT nextval('factoids_id_seq'::regclass) NOT NULL,
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
-- Name: failed_email_ids; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE failed_email_ids (
    account_id integer
);


--
-- Name: failure_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feedbacks (
    id integer NOT NULL,
    rating integer,
    more_info integer,
    uuid character varying,
    project_name character varying,
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
-- Name: follows; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE follows (
    id integer NOT NULL,
    owner_id integer NOT NULL,
    project_id integer,
    account_id integer,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: message_account_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE message_account_tags (
    id integer NOT NULL,
    message_id integer,
    account_id integer
);


--
-- Name: message_project_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE message_project_tags (
    id integer NOT NULL,
    message_id integer,
    project_id integer
);


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: forges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE forges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE forges (
    id integer DEFAULT nextval('forges_id_seq'::regclass) NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    type text
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
-- Name: forums; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE forums (
    id integer DEFAULT nextval('forums_id_seq'::regclass) NOT NULL,
    project_id integer,
    name text NOT NULL,
    topics_count integer DEFAULT 0,
    posts_count integer DEFAULT 0,
    "position" integer,
    description text
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
-- Name: fyles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fyles (
    id integer DEFAULT nextval('fyles_id_seq'::regclass) NOT NULL,
    name text NOT NULL,
    code_set_id integer NOT NULL
);


--
-- Name: project_gestalts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_gestalts (
    id integer NOT NULL,
    date timestamp without time zone NOT NULL,
    project_id integer,
    gestalt_id integer
);


--
-- Name: gestaltings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gestaltings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gestaltings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gestaltings_id_seq OWNED BY project_gestalts.id;


--
-- Name: gestalts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE gestalts (
    id integer NOT NULL,
    type text NOT NULL,
    name text NOT NULL,
    description text
);


--
-- Name: gestalts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gestalts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gestalts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gestalts_id_seq OWNED BY gestalts.id;


--
-- Name: github_project; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: helpfuls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE helpfuls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: helpfuls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE helpfuls (
    id integer DEFAULT nextval('helpfuls_id_seq'::regclass) NOT NULL,
    review_id integer,
    account_id integer NOT NULL,
    yes boolean DEFAULT true
);


--
-- Name: invites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: job_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE job_statuses (
    id integer NOT NULL,
    name text NOT NULL
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
-- Name: jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE jobs (
    id integer DEFAULT nextval('jobs_id_seq'::regclass) NOT NULL,
    project_id integer,
    repository_id integer,
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
    organization_id integer
);


--
-- Name: knowledge_base_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: koders_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE koders_statuses (
    id integer NOT NULL,
    project_id integer NOT NULL,
    koders_id integer,
    flags integer DEFAULT 0 NOT NULL,
    ohloh_updated_at timestamp without time zone,
    koders_updated_at timestamp without time zone,
    error text,
    ohloh_code_ready boolean DEFAULT false
);


--
-- Name: koders_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE koders_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: koders_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE koders_statuses_id_seq OWNED BY koders_statuses.id;


--
-- Name: kudo_scores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: kudos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE kudos (
    id integer NOT NULL,
    sender_id integer NOT NULL,
    account_id integer,
    project_id integer,
    name_id integer,
    created_at timestamp without time zone,
    message character varying(80),
    CONSTRAINT not_all_null CHECK ((NOT (((account_id IS NULL) AND (project_id IS NULL)) AND (name_id IS NULL))))
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
-- Name: language_experiences; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: language_facts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: languages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE languages (
    id integer DEFAULT nextval('languages_id_seq'::regclass) NOT NULL,
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
-- Name: license_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE license_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: license_facts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE license_facts (
    license_id integer NOT NULL,
    file_count integer DEFAULT 0 NOT NULL,
    scope integer DEFAULT 0 NOT NULL,
    id integer DEFAULT nextval('license_facts_id_seq'::regclass) NOT NULL,
    analysis_id integer NOT NULL
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
-- Name: licenses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE licenses (
    id integer DEFAULT nextval('licenses_id_seq'::regclass) NOT NULL,
    vanity_url text,
    name text,
    abbreviation text,
    url text,
    description text,
    deleted boolean DEFAULT false,
    locked boolean DEFAULT false
);


--
-- Name: link_categories_deleted; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: links; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: load_averages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE load_averages (
    current numeric DEFAULT 0.0,
    id integer NOT NULL,
    max numeric DEFAULT 3.0
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
-- Name: load_averages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE load_averages_id_seq OWNED BY load_averages.id;


--
-- Name: manages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: markups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: mistaken_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: monitorships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE monitorships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


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
-- Name: name_language_facts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE name_language_facts (
    id integer DEFAULT nextval('name_language_facts_id_seq'::regclass) NOT NULL,
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
-- Name: named_commits; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW named_commits AS
 SELECT commits.id,
    commits.id AS commit_id,
    analysis_sloc_sets.analysis_id,
    projects.id AS project_id,
    analysis_sloc_sets.sloc_set_id,
    sloc_sets.code_set_id,
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
   FROM (((((analysis_sloc_sets
     JOIN projects ON ((analysis_sloc_sets.analysis_id = projects.best_analysis_id)))
     JOIN sloc_sets ON ((sloc_sets.id = analysis_sloc_sets.sloc_set_id)))
     JOIN commits ON (((commits.code_set_id = sloc_sets.code_set_id) AND (commits."position" <= analysis_sloc_sets.as_of))))
     JOIN analysis_aliases ON (((analysis_aliases.analysis_id = analysis_sloc_sets.analysis_id) AND (analysis_aliases.commit_name_id = commits.name_id))))
     LEFT JOIN positions ON (((positions.project_id = projects.id) AND (positions.name_id = analysis_aliases.preferred_name_id))));


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
-- Name: names; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE names (
    id integer DEFAULT nextval('names_id_seq'::regclass) NOT NULL,
    name text NOT NULL
);


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_applications (
    id integer NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
-- Name: oauth_nonces; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: old_edits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE old_edits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: old_edits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE old_edits (
    id integer DEFAULT nextval('old_edits_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    account_id integer NOT NULL,
    created_at timestamp without time zone,
    type text NOT NULL,
    key text,
    value text,
    undone boolean DEFAULT false NOT NULL,
    undone_at timestamp without time zone,
    undone_by integer
);


--
-- Name: org_stats_by_sectors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: org_thirty_day_activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: organizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


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
  WHERE (a.level <> (-20))
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
-- Name: permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


SET default_with_oids = true;

--
-- Name: pg_ts_cfg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pg_ts_cfg (
    ts_name text NOT NULL,
    prs_name text NOT NULL,
    locale text
);


--
-- Name: pg_ts_cfgmap; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


SET default_with_oids = false;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE posts (
    id integer DEFAULT nextval('posts_id_seq'::regclass) NOT NULL,
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
-- Name: profiles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: project_counts_by_quarter_and_language; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_counts_by_quarter_and_language AS
 SELECT af.language_id,
    date_trunc('quarter'::text, timezone('utc'::text, (af.month)::timestamp with time zone)) AS quarter,
    count(DISTINCT af.analysis_id) AS project_count
   FROM ((activity_facts af
     JOIN analyses a ON ((a.id = af.analysis_id)))
     JOIN projects p ON (((p.best_analysis_id = a.id) AND (NOT p.deleted))))
  GROUP BY af.language_id, date_trunc('quarter'::text, timezone('utc'::text, (af.month)::timestamp with time zone));


--
-- Name: project_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: project_experiences; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: project_gestalt_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_gestalt_view AS
 SELECT p.id AS project_id,
    p.vanity_url AS url_name,
    g.id AS gestalt_id,
    g.name,
    g.type
   FROM ((projects p
     JOIN project_gestalts pg ON ((p.id = pg.project_id)))
     JOIN gestalts g ON ((g.id = pg.gestalt_id)));


--
-- Name: project_gestalts_tmp; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_gestalts_tmp (
    id integer,
    date timestamp without time zone,
    project_id integer,
    gestalt_id integer
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
-- Name: project_licenses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_licenses (
    id integer DEFAULT nextval('project_licenses_id_seq'::regclass) NOT NULL,
    project_id integer,
    license_id integer,
    deleted boolean DEFAULT false
);


--
-- Name: project_reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: ratings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ratings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ratings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ratings (
    id integer DEFAULT nextval('ratings_id_seq'::regclass) NOT NULL,
    account_id integer NOT NULL,
    project_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('UTC'::text, now()),
    updated_at timestamp without time zone DEFAULT timezone('UTC'::text, now())
);


--
-- Name: recently_active_accounts_cache; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: recommend_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: recommendations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE repositories (
    id integer DEFAULT nextval('repositories_id_seq'::regclass) NOT NULL,
    url text,
    module_name text,
    branch_name text,
    best_code_set_id integer,
    forge_id integer,
    username text,
    password text,
    type text NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    updated_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    update_interval integer DEFAULT 3600,
    name_at_forge text,
    owner_at_forge text
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
-- Name: reviews; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reviews (
    id integer DEFAULT nextval('reviews_id_seq'::regclass) NOT NULL,
    account_id integer NOT NULL,
    project_id integer NOT NULL,
    title text,
    comment text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    helpful_score integer DEFAULT 0 NOT NULL
);


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
-- Name: rss_articles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rss_articles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rss_articles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rss_articles (
    id integer DEFAULT nextval('rss_articles_id_seq'::regclass) NOT NULL,
    rss_feed_id integer,
    guid text NOT NULL,
    "time" timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    title text NOT NULL,
    description text,
    author text,
    link text
);


--
-- Name: rss_articles_2; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: rss_feeds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rss_feeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rss_feeds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rss_feeds (
    id integer DEFAULT nextval('rss_feeds_id_seq'::regclass) NOT NULL,
    url text NOT NULL,
    last_fetch timestamp without time zone,
    next_fetch timestamp without time zone,
    error text
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
-- Name: rss_subscriptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rss_subscriptions (
    id integer DEFAULT nextval('rss_subscriptions_id_seq'::regclass) NOT NULL,
    project_id integer,
    rss_feed_id integer,
    deleted boolean DEFAULT false
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
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
-- Name: sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sessions (
    id integer DEFAULT nextval('sessions_id_seq'::regclass) NOT NULL,
    session_id character varying(255),
    data text,
    updated_at timestamp without time zone
);


--
-- Name: sf_vhosted; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sf_vhosted (
    domain text NOT NULL
);


--
-- Name: sfprojects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: slave_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE slave_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slave_logs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE slave_logs (
    id integer DEFAULT nextval('slave_logs_id_seq'::regclass) NOT NULL,
    message text,
    created_on timestamp without time zone,
    slave_id integer,
    job_id integer,
    code_set_id integer,
    level integer DEFAULT 0
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
-- Name: slaves; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE slaves (
    id integer DEFAULT nextval('slave_permissions_id_seq'::regclass) NOT NULL,
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
-- Name: sloc_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sloc_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sloc_metrics; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sloc_metrics (
    id bigint DEFAULT nextval('sloc_metrics_id_seq'::regclass) NOT NULL,
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
-- Name: stack_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stack_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stack_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stack_entries (
    id integer DEFAULT nextval('stack_entries_id_seq'::regclass) NOT NULL,
    stack_id integer,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    note text
);


--
-- Name: stack_ignores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: stacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stacks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stacks (
    id integer DEFAULT nextval('stacks_id_seq'::regclass) NOT NULL,
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
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taggings (
    id integer DEFAULT nextval('taggings_id_seq'::regclass) NOT NULL,
    tag_id integer,
    taggable_id integer,
    taggable_type character varying(255)
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
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer DEFAULT nextval('tags_id_seq'::regclass) NOT NULL,
    name text NOT NULL,
    taggings_count integer DEFAULT 0 NOT NULL,
    weight double precision DEFAULT 1.0 NOT NULL
);


--
-- Name: thirty_day_summaries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: tools; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topics; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE topics (
    id integer DEFAULT nextval('topics_id_seq'::regclass) NOT NULL,
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
-- Name: unknown_email_ids; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE unknown_email_ids (
    account_id integer
);


--
-- Name: verifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE verifications (
    id integer NOT NULL,
    account_id integer,
    type character varying,
    auth_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: vita_analyses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: vitae; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_reports ALTER COLUMN id SET DEFAULT nextval('account_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY actions ALTER COLUMN id SET DEFAULT nextval('actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY aliases ALTER COLUMN id SET DEFAULT nextval('aliases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_aliases ALTER COLUMN id SET DEFAULT nextval('analysis_aliases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_summaries ALTER COLUMN id SET DEFAULT nextval('analysis_summaries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys ALTER COLUMN id SET DEFAULT nextval('api_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations ALTER COLUMN id SET DEFAULT nextval('authorizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY clumps ALTER COLUMN id SET DEFAULT nextval('clumps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_set_gestalts ALTER COLUMN id SET DEFAULT nextval('code_set_gestalts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY commit_flags ALTER COLUMN id SET DEFAULT nextval('commit_flags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY deleted_accounts ALTER COLUMN id SET DEFAULT nextval('deleted_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY domain_blacklists ALTER COLUMN id SET DEFAULT nextval('domain_blacklists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY duplicates ALTER COLUMN id SET DEFAULT nextval('duplicates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_addresses ALTER COLUMN id SET DEFAULT nextval('email_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_subscription ALTER COLUMN id SET DEFAULT nextval('event_subscription_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY exhibits ALTER COLUMN id SET DEFAULT nextval('exhibits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY failure_groups ALTER COLUMN id SET DEFAULT nextval('failure_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY feedbacks ALTER COLUMN id SET DEFAULT nextval('feedbacks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY follows ALTER COLUMN id SET DEFAULT nextval('follows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gestalts ALTER COLUMN id SET DEFAULT nextval('gestalts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites ALTER COLUMN id SET DEFAULT nextval('invites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY knowledge_base_statuses ALTER COLUMN id SET DEFAULT nextval('knowledge_base_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY koders_statuses ALTER COLUMN id SET DEFAULT nextval('koders_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY kudo_scores ALTER COLUMN id SET DEFAULT nextval('kudo_scores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY kudos ALTER COLUMN id SET DEFAULT nextval('kudos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY language_experiences ALTER COLUMN id SET DEFAULT nextval('language_experiences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY language_facts ALTER COLUMN id SET DEFAULT nextval('language_facts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY link_categories_deleted ALTER COLUMN id SET DEFAULT nextval('link_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY load_averages ALTER COLUMN id SET DEFAULT nextval('load_averages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY manages ALTER COLUMN id SET DEFAULT nextval('manages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY markups ALTER COLUMN id SET DEFAULT nextval('markups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_account_tags ALTER COLUMN id SET DEFAULT nextval('message_account_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_project_tags ALTER COLUMN id SET DEFAULT nextval('message_project_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_nonces ALTER COLUMN id SET DEFAULT nextval('oauth_nonces_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY org_stats_by_sectors ALTER COLUMN id SET DEFAULT nextval('org_stats_by_sectors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY org_thirty_day_activities ALTER COLUMN id SET DEFAULT nextval('org_thirty_day_activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions ALTER COLUMN id SET DEFAULT nextval('permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions ALTER COLUMN id SET DEFAULT nextval('positions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_events ALTER COLUMN id SET DEFAULT nextval('project_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_experiences ALTER COLUMN id SET DEFAULT nextval('project_experiences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_gestalts ALTER COLUMN id SET DEFAULT nextval('gestaltings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_reports ALTER COLUMN id SET DEFAULT nextval('project_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY recently_active_accounts_cache ALTER COLUMN id SET DEFAULT nextval('recently_active_accounts_cache_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommend_entries ALTER COLUMN id SET DEFAULT nextval('recommend_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommendations ALTER COLUMN id SET DEFAULT nextval('recommendations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports ALTER COLUMN id SET DEFAULT nextval('reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stack_ignores ALTER COLUMN id SET DEFAULT nextval('stack_ignores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY thirty_day_summaries ALTER COLUMN id SET DEFAULT nextval('thirty_day_summaries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tools ALTER COLUMN id SET DEFAULT nextval('tools_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY verifications ALTER COLUMN id SET DEFAULT nextval('verifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vita_analyses ALTER COLUMN id SET DEFAULT nextval('vita_analyses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vitae ALTER COLUMN id SET DEFAULT nextval('vitae_id_seq'::regclass);


--
-- Name: account_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_reports
    ADD CONSTRAINT account_reports_pkey PRIMARY KEY (id);


--
-- Name: accounts_email_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_email_key UNIQUE (email);


--
-- Name: accounts_login_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_login_key UNIQUE (login);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (id);


--
-- Name: activity_facts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY activity_facts
    ADD CONSTRAINT activity_facts_pkey PRIMARY KEY (id);


--
-- Name: aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY aliases
    ADD CONSTRAINT aliases_pkey PRIMARY KEY (id);


--
-- Name: aliases_project_id_name_id; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY aliases
    ADD CONSTRAINT aliases_project_id_name_id UNIQUE (project_id, commit_name_id);


--
-- Name: analyses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY analyses
    ADD CONSTRAINT analyses_pkey PRIMARY KEY (id);


--
-- Name: analysis_aliases_analysis_id_commit_name_id; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY analysis_aliases
    ADD CONSTRAINT analysis_aliases_analysis_id_commit_name_id UNIQUE (analysis_id, commit_name_id);


--
-- Name: analysis_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY analysis_aliases
    ADD CONSTRAINT analysis_aliases_pkey PRIMARY KEY (id);


--
-- Name: analysis_sloc_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY analysis_sloc_sets
    ADD CONSTRAINT analysis_sloc_sets_pkey PRIMARY KEY (id);


--
-- Name: analysis_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY analysis_summaries
    ADD CONSTRAINT analysis_summaries_pkey PRIMARY KEY (id);


--
-- Name: api_keys_key_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT api_keys_key_key UNIQUE (key);


--
-- Name: api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authorizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT authorizations_pkey PRIMARY KEY (id);


--
-- Name: claims_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT claims_pkey PRIMARY KEY (id);


--
-- Name: clumps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY clumps
    ADD CONSTRAINT clumps_pkey PRIMARY KEY (id);


--
-- Name: code_set_gestalts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY code_set_gestalts
    ADD CONSTRAINT code_set_gestalts_pkey PRIMARY KEY (id);


--
-- Name: code_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY code_sets
    ADD CONSTRAINT code_sets_pkey PRIMARY KEY (id);


--
-- Name: commit_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY commit_flags
    ADD CONSTRAINT commit_flags_pkey PRIMARY KEY (id);


--
-- Name: commits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY commits
    ADD CONSTRAINT commits_pkey PRIMARY KEY (id);


--
-- Name: deleted_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY deleted_accounts
    ADD CONSTRAINT deleted_accounts_pkey PRIMARY KEY (id);


--
-- Name: diffs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY diffs
    ADD CONSTRAINT diffs_pkey PRIMARY KEY (id);


--
-- Name: domain_blacklists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY domain_blacklists
    ADD CONSTRAINT domain_blacklists_pkey PRIMARY KEY (id);


--
-- Name: duplicates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY duplicates
    ADD CONSTRAINT duplicates_pkey PRIMARY KEY (id);


--
-- Name: edits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY old_edits
    ADD CONSTRAINT edits_pkey PRIMARY KEY (id);


--
-- Name: edits_pkey1; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY edits
    ADD CONSTRAINT edits_pkey1 PRIMARY KEY (id);


--
-- Name: email_addresses_address_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY email_addresses
    ADD CONSTRAINT email_addresses_address_key UNIQUE (address);


--
-- Name: email_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY email_addresses
    ADD CONSTRAINT email_addresses_pkey PRIMARY KEY (id);


--
-- Name: enlistments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enlistments
    ADD CONSTRAINT enlistments_pkey PRIMARY KEY (id);


--
-- Name: event_subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY event_subscription
    ADD CONSTRAINT event_subscription_pkey PRIMARY KEY (id);


--
-- Name: exhibits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY exhibits
    ADD CONSTRAINT exhibits_pkey PRIMARY KEY (id);


--
-- Name: factoids_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY factoids
    ADD CONSTRAINT factoids_pkey PRIMARY KEY (id);


--
-- Name: failure_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY failure_groups
    ADD CONSTRAINT failure_groups_pkey PRIMARY KEY (id);


--
-- Name: feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (id);


--
-- Name: follows_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY follows
    ADD CONSTRAINT follows_pkey PRIMARY KEY (id);


--
-- Name: forges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY forges
    ADD CONSTRAINT forges_pkey PRIMARY KEY (id);


--
-- Name: forges_type_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY forges
    ADD CONSTRAINT forges_type_key UNIQUE (type);


--
-- Name: forums_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY forums
    ADD CONSTRAINT forums_pkey PRIMARY KEY (id);


--
-- Name: fyles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fyles
    ADD CONSTRAINT fyles_pkey PRIMARY KEY (id);


--
-- Name: gestalts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gestalts
    ADD CONSTRAINT gestalts_pkey PRIMARY KEY (id);


--
-- Name: github_project_project_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY github_project
    ADD CONSTRAINT github_project_project_id_key UNIQUE (project_id, owner);


--
-- Name: helpfuls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY helpfuls
    ADD CONSTRAINT helpfuls_pkey PRIMARY KEY (id);


--
-- Name: invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


--
-- Name: jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY knowledge_base_statuses
    ADD CONSTRAINT knowledge_base_statuses_pkey PRIMARY KEY (id);


--
-- Name: knowledge_base_statuses_project_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY knowledge_base_statuses
    ADD CONSTRAINT knowledge_base_statuses_project_id_key UNIQUE (project_id);


--
-- Name: koders_statuses_koders_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY koders_statuses
    ADD CONSTRAINT koders_statuses_koders_id_key UNIQUE (koders_id);


--
-- Name: koders_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY koders_statuses
    ADD CONSTRAINT koders_statuses_pkey PRIMARY KEY (id);


--
-- Name: koders_statuses_project_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY koders_statuses
    ADD CONSTRAINT koders_statuses_project_id_key UNIQUE (project_id);


--
-- Name: kudo_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY kudo_scores
    ADD CONSTRAINT kudo_scores_pkey PRIMARY KEY (id);


--
-- Name: kudos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY kudos
    ADD CONSTRAINT kudos_pkey PRIMARY KEY (id);


--
-- Name: language_experiences_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY language_experiences
    ADD CONSTRAINT language_experiences_pkey PRIMARY KEY (id);


--
-- Name: language_facts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY language_facts
    ADD CONSTRAINT language_facts_pkey PRIMARY KEY (id);


--
-- Name: languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: license_facts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY license_facts
    ADD CONSTRAINT license_facts_pkey PRIMARY KEY (id);


--
-- Name: licenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (id);


--
-- Name: link_categories_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY link_categories_deleted
    ADD CONSTRAINT link_categories_name_key UNIQUE (name);


--
-- Name: link_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY link_categories_deleted
    ADD CONSTRAINT link_categories_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: load_averages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY load_averages
    ADD CONSTRAINT load_averages_pkey PRIMARY KEY (id);


--
-- Name: manages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY manages
    ADD CONSTRAINT manages_pkey PRIMARY KEY (id);


--
-- Name: markups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY markups
    ADD CONSTRAINT markups_pkey PRIMARY KEY (id);


--
-- Name: message_account_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY message_account_tags
    ADD CONSTRAINT message_account_tags_pkey PRIMARY KEY (id);


--
-- Name: message_project_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY message_project_tags
    ADD CONSTRAINT message_project_tags_pkey PRIMARY KEY (id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: name_facts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY name_facts
    ADD CONSTRAINT name_facts_pkey PRIMARY KEY (id);


--
-- Name: name_language_facts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY name_language_facts
    ADD CONSTRAINT name_language_facts_pkey PRIMARY KEY (id);


--
-- Name: names_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY names
    ADD CONSTRAINT names_name_key UNIQUE (name);


--
-- Name: names_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY names
    ADD CONSTRAINT names_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: oauth_nonces_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_nonces
    ADD CONSTRAINT oauth_nonces_pkey PRIMARY KEY (id);


--
-- Name: org_stats_by_sectors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY org_stats_by_sectors
    ADD CONSTRAINT org_stats_by_sectors_pkey PRIMARY KEY (id);


--
-- Name: org_thirty_day_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY org_thirty_day_activities
    ADD CONSTRAINT org_thirty_day_activities_pkey PRIMARY KEY (id);


--
-- Name: organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: people_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_id_key UNIQUE (id);


--
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: pg_ts_cfg_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pg_ts_cfg
    ADD CONSTRAINT pg_ts_cfg_pkey PRIMARY KEY (ts_name);


--
-- Name: pg_ts_cfgmap_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pg_ts_cfgmap
    ADD CONSTRAINT pg_ts_cfgmap_pkey PRIMARY KEY (ts_name, tok_alias);


--
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: project_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_events
    ADD CONSTRAINT project_events_pkey PRIMARY KEY (id);


--
-- Name: project_experiences_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_experiences
    ADD CONSTRAINT project_experiences_pkey PRIMARY KEY (id);


--
-- Name: project_gestalts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_gestalts
    ADD CONSTRAINT project_gestalts_pkey PRIMARY KEY (id);


--
-- Name: project_licenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_licenses
    ADD CONSTRAINT project_licenses_pkey PRIMARY KEY (id);


--
-- Name: project_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_reports
    ADD CONSTRAINT project_reports_pkey PRIMARY KEY (id);


--
-- Name: project_reports_project_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_reports
    ADD CONSTRAINT project_reports_project_id_key UNIQUE (project_id, report_id);


--
-- Name: projects_kb_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_kb_id_key UNIQUE (kb_id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: projects_url_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_url_name_key UNIQUE (vanity_url);


--
-- Name: ratings_account_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ratings
    ADD CONSTRAINT ratings_account_id_key UNIQUE (account_id, project_id);


--
-- Name: ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (id);


--
-- Name: recommend_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY recommend_entries
    ADD CONSTRAINT recommend_entries_pkey PRIMARY KEY (id);


--
-- Name: recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY recommendations
    ADD CONSTRAINT recommendations_pkey PRIMARY KEY (id);


--
-- Name: reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: reviews_account_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_account_id_key UNIQUE (account_id, project_id);


--
-- Name: reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: rss_articles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rss_articles
    ADD CONSTRAINT rss_articles_pkey PRIMARY KEY (id);


--
-- Name: rss_feeds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rss_feeds
    ADD CONSTRAINT rss_feeds_pkey PRIMARY KEY (id);


--
-- Name: rss_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rss_subscriptions
    ADD CONSTRAINT rss_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions_session_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_session_id_key UNIQUE (session_id);


--
-- Name: slave_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY slave_logs
    ADD CONSTRAINT slave_logs_pkey PRIMARY KEY (id);


--
-- Name: slave_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY slaves
    ADD CONSTRAINT slave_permissions_pkey PRIMARY KEY (id);


--
-- Name: sloc_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sloc_sets
    ADD CONSTRAINT sloc_sets_pkey PRIMARY KEY (id);


--
-- Name: stack_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stack_entries
    ADD CONSTRAINT stack_entries_pkey PRIMARY KEY (id);


--
-- Name: stack_ignores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stack_ignores
    ADD CONSTRAINT stack_ignores_pkey PRIMARY KEY (id);


--
-- Name: stacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stacks
    ADD CONSTRAINT stacks_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: thirty_day_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY thirty_day_summaries
    ADD CONSTRAINT thirty_day_summaries_pkey PRIMARY KEY (id);


--
-- Name: tools_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tools
    ADD CONSTRAINT tools_name_key UNIQUE (name);


--
-- Name: tools_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tools
    ADD CONSTRAINT tools_pkey PRIMARY KEY (id);


--
-- Name: topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: unique_account_id_project_id; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT unique_account_id_project_id UNIQUE (account_id, project_id);


--
-- Name: unique_authorizations_token; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT unique_authorizations_token UNIQUE (token);


--
-- Name: unique_code_set_gestalts_code_set_id_date_gestalt_id; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY code_set_gestalts
    ADD CONSTRAINT unique_code_set_gestalts_code_set_id_date_gestalt_id UNIQUE (code_set_id, date, gestalt_id);


--
-- Name: unique_diffs_on_commit_id_fyle_id; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY diffs
    ADD CONSTRAINT unique_diffs_on_commit_id_fyle_id UNIQUE (commit_id, fyle_id);


--
-- Name: unique_oauth_nonces_nonce_timestamp; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_nonces
    ADD CONSTRAINT unique_oauth_nonces_nonce_timestamp UNIQUE (nonce, "timestamp");


--
-- Name: unique_project_events; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_events
    ADD CONSTRAINT unique_project_events UNIQUE (project_id, type, key);


--
-- Name: unique_project_gestalts_project_id_date_gestalt_id; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_gestalts
    ADD CONSTRAINT unique_project_gestalts_project_id_date_gestalt_id UNIQUE (project_id, date, gestalt_id);


--
-- Name: unique_project_id_name_id; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT unique_project_id_name_id UNIQUE (project_id, name_id);


--
-- Name: unique_project_id_repository_id; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enlistments
    ADD CONSTRAINT unique_project_id_repository_id UNIQUE (project_id, repository_id);


--
-- Name: unique_project_id_rss_feed_id; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rss_subscriptions
    ADD CONSTRAINT unique_project_id_rss_feed_id UNIQUE (project_id, rss_feed_id);


--
-- Name: unique_rss_feed_id_guid; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rss_articles
    ADD CONSTRAINT unique_rss_feed_id_guid UNIQUE (rss_feed_id, guid);


--
-- Name: unique_taggings_tag_id_taggable_id_taggable_type; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT unique_taggings_tag_id_taggable_id_taggable_type UNIQUE (tag_id, taggable_id, taggable_type);


--
-- Name: verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY verifications
    ADD CONSTRAINT verifications_pkey PRIMARY KEY (id);


--
-- Name: vita_analyses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vita_analyses
    ADD CONSTRAINT vita_analyses_pkey PRIMARY KEY (id);


--
-- Name: vitae_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vitae
    ADD CONSTRAINT vitae_pkey PRIMARY KEY (id);


--
-- Name: edits_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX edits_organization_id ON edits USING btree (organization_id) WHERE (organization_id IS NOT NULL);


--
-- Name: edits_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX edits_project_id ON edits USING btree (project_id) WHERE (project_id IS NOT NULL);


--
-- Name: foo; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX foo ON slaves USING btree (clump_status) WHERE (oldest_clump_timestamp IS NOT NULL);


--
-- Name: github_project_owner_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX github_project_owner_idx ON github_project USING btree (owner);


--
-- Name: github_project_project_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX github_project_project_id_idx ON github_project USING btree (project_id);


--
-- Name: index_account_reports_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_reports_on_account_id ON account_reports USING btree (account_id);


--
-- Name: index_account_reports_on_report_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_reports_on_report_id ON account_reports USING btree (report_id);


--
-- Name: index_accounts_on_best_vita_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_best_vita_id ON accounts USING btree (best_vita_id) WHERE (best_vita_id IS NOT NULL);


--
-- Name: index_accounts_on_email_md5; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_email_md5 ON accounts USING btree (email_md5);


--
-- Name: index_accounts_on_lower_login; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_accounts_on_lower_login ON accounts USING btree (lower(login));


--
-- Name: index_accounts_on_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_organization_id ON accounts USING btree (organization_id);


--
-- Name: index_actions_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_actions_on_account_id ON actions USING btree (account_id);


--
-- Name: index_activity_facts_on_analysis_id_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activity_facts_on_analysis_id_month ON activity_facts USING btree (analysis_id, month);


--
-- Name: index_activity_facts_on_language_id_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activity_facts_on_language_id_month ON activity_facts USING btree (language_id, month);


--
-- Name: index_activity_facts_on_name_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activity_facts_on_name_id ON activity_facts USING btree (name_id);


--
-- Name: index_analyses_on_logged_at_day; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_analyses_on_logged_at_day ON analyses USING btree (logged_at, date_trunc('day'::text, logged_at)) WHERE (logged_at IS NOT NULL);


--
-- Name: index_analyses_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_analyses_on_project_id ON analyses USING btree (project_id);


--
-- Name: index_analysis_aliases_on_analysis_id_preferred_name_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_analysis_aliases_on_analysis_id_preferred_name_id ON analysis_aliases USING btree (analysis_id, preferred_name_id);


--
-- Name: index_analysis_sloc_sets_on_analysis_id_sloc_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_analysis_sloc_sets_on_analysis_id_sloc_set_id ON analysis_sloc_sets USING btree (analysis_id, sloc_set_id);


--
-- Name: index_analysis_sloc_sets_on_sloc_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_analysis_sloc_sets_on_sloc_set_id ON analysis_sloc_sets USING btree (sloc_set_id);


--
-- Name: index_analysis_summaries_on_analysis_id_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_analysis_summaries_on_analysis_id_type ON analysis_summaries USING btree (analysis_id, type);


--
-- Name: index_api_keys_on_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_api_keys_on_key ON api_keys USING btree (key);


--
-- Name: index_api_keys_on_oauth_application_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_api_keys_on_oauth_application_id ON api_keys USING btree (oauth_application_id);


--
-- Name: index_authorizations_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_authorizations_on_account_id ON authorizations USING btree (account_id);


--
-- Name: index_authorizations_on_api_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_authorizations_on_api_key_id ON authorizations USING btree (api_key_id);


--
-- Name: index_claims_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_claims_on_account_id ON positions USING btree (account_id);


--
-- Name: index_clumps_on_code_set_id_slave_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_clumps_on_code_set_id_slave_id ON clumps USING btree (code_set_id, slave_id);


--
-- Name: index_code_set_gestalts_on_code_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_code_set_gestalts_on_code_set_id ON code_set_gestalts USING btree (code_set_id);


--
-- Name: index_code_set_gestalts_on_gestalt_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_code_set_gestalts_on_gestalt_id ON code_set_gestalts USING btree (gestalt_id);


--
-- Name: index_code_sets_on_best_sloc_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_code_sets_on_best_sloc_set_id ON code_sets USING btree (best_sloc_set_id);


--
-- Name: index_code_sets_on_logged_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_code_sets_on_logged_at ON code_sets USING btree ((COALESCE(logged_at, '1970-01-01 00:00:00'::timestamp without time zone)));


--
-- Name: index_code_sets_on_repository_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_code_sets_on_repository_id ON code_sets USING btree (repository_id);


--
-- Name: index_commit_flags_on_commit_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_commit_flags_on_commit_id ON commit_flags USING btree (commit_id);


--
-- Name: index_commit_flags_on_sloc_set_id_commit_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_commit_flags_on_sloc_set_id_commit_id ON commit_flags USING btree (sloc_set_id, commit_id);


--
-- Name: index_commit_flags_on_sloc_set_id_time; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_commit_flags_on_sloc_set_id_time ON commit_flags USING btree (sloc_set_id, "time" DESC);


--
-- Name: index_commits_on_code_set_id_time; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_commits_on_code_set_id_time ON commits USING btree (code_set_id, "time");


--
-- Name: index_commits_on_name_id_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_commits_on_name_id_month ON commits USING btree (name_id, date_trunc('month'::text, "time"));


--
-- Name: index_commits_on_sha1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_commits_on_sha1 ON commits USING btree (sha1);


--
-- Name: index_diffs_on_commit_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_diffs_on_commit_id ON diffs USING btree (commit_id);


--
-- Name: index_diffs_on_fyle_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_diffs_on_fyle_id ON diffs USING btree (fyle_id);


--
-- Name: index_duplicates_on_bad_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_duplicates_on_bad_project_id ON duplicates USING btree (bad_project_id);


--
-- Name: index_duplicates_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_duplicates_on_created_at ON duplicates USING btree (created_at);


--
-- Name: index_duplicates_on_good_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_duplicates_on_good_project_id ON duplicates USING btree (good_project_id);


--
-- Name: index_edits_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_edits_on_account_id ON edits USING btree (account_id);


--
-- Name: index_edits_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_edits_on_created_at ON edits USING btree (created_at);


--
-- Name: index_edits_on_edits; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_edits_on_edits ON edits USING btree (target_type, target_id, key);


--
-- Name: index_enlistments_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_enlistments_on_project_id ON enlistments USING btree (project_id) WHERE (deleted IS FALSE);


--
-- Name: index_enlistments_on_repository_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_enlistments_on_repository_id ON enlistments USING btree (repository_id) WHERE (deleted IS FALSE);


--
-- Name: index_exhibits_on_report_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_exhibits_on_report_id ON exhibits USING btree (report_id);


--
-- Name: index_factoids_on_analysis_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_factoids_on_analysis_id ON factoids USING btree (analysis_id);


--
-- Name: index_failure_groups_on_priority_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_failure_groups_on_priority_name ON failure_groups USING btree (priority, name);


--
-- Name: index_follows_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_follows_on_account_id ON follows USING btree (account_id);


--
-- Name: index_follows_on_owner_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_follows_on_owner_id ON follows USING btree (owner_id);


--
-- Name: index_follows_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_follows_on_project_id ON follows USING btree (project_id);


--
-- Name: index_fyles_on_code_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fyles_on_code_set_id ON fyles USING btree (code_set_id);


--
-- Name: index_fyles_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fyles_on_name ON fyles USING btree (name);


--
-- Name: index_gestalts_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_gestalts_on_name ON gestalts USING btree (name);


--
-- Name: index_helpfuls_on_review_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_helpfuls_on_review_id ON helpfuls USING btree (review_id);


--
-- Name: index_jobs_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_jobs_on_account_id ON jobs USING btree (account_id);


--
-- Name: index_jobs_on_code_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_jobs_on_code_set_id ON jobs USING btree (code_set_id);


--
-- Name: index_jobs_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_jobs_on_project_id ON jobs USING btree (project_id);


--
-- Name: index_jobs_on_repository_id_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_jobs_on_repository_id_status ON jobs USING btree (repository_id, status);


--
-- Name: index_jobs_on_slave_id_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_jobs_on_slave_id_status ON jobs USING btree (slave_id, status);


--
-- Name: index_jobs_on_slave_id_status_current_step; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_jobs_on_slave_id_status_current_step ON jobs USING btree (slave_id, status, current_step_at);


--
-- Name: index_jobs_on_sloc_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_jobs_on_sloc_set_id ON jobs USING btree (sloc_set_id);


--
-- Name: index_kudo_scores_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_kudo_scores_on_account_id ON kudo_scores USING btree (account_id);


--
-- Name: index_kudo_scores_on_array_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_kudo_scores_on_array_index ON kudo_scores USING btree (array_index);


--
-- Name: index_kudo_scores_on_project_id_name_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_kudo_scores_on_project_id_name_id ON kudo_scores USING btree (project_id, name_id);


--
-- Name: index_kudos_on_from_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_kudos_on_from_account_id ON kudos USING btree (sender_id);


--
-- Name: index_language_facts_on_month_language_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_language_facts_on_month_language_id ON language_facts USING btree (month, language_id);


--
-- Name: index_license_facts_on_analysis_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_license_facts_on_analysis_id ON license_facts USING btree (analysis_id);


--
-- Name: index_licenses_on_vanity_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_licenses_on_vanity_url ON licenses USING btree (vanity_url);


--
-- Name: index_links_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_links_project_id ON links USING btree (project_id);


--
-- Name: index_manages_on_target_account_deleted_by; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_manages_on_target_account_deleted_by ON manages USING btree (target_id, target_type, account_id) WHERE ((deleted_at IS NULL) AND (deleted_by IS NULL));


--
-- Name: index_message_account_tags_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_message_account_tags_on_account_id ON message_account_tags USING btree (account_id);


--
-- Name: index_message_account_tags_on_message_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_message_account_tags_on_message_id ON message_account_tags USING btree (message_id);


--
-- Name: index_message_project_tags_on_message_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_message_project_tags_on_message_id ON message_project_tags USING btree (message_id);


--
-- Name: index_message_project_tags_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_message_project_tags_on_project_id ON message_project_tags USING btree (project_id);


--
-- Name: index_messages_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_account_id ON messages USING btree (account_id);


--
-- Name: index_name_facts_email_address_ids; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_name_facts_email_address_ids ON name_facts USING gin (email_address_ids) WHERE (type = 'ContributorFact'::text);


--
-- Name: index_name_facts_on_analysis_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_name_facts_on_analysis_id ON name_facts USING btree (analysis_id);


--
-- Name: index_name_facts_on_analysis_id_contributors; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_name_facts_on_analysis_id_contributors ON name_facts USING btree (analysis_id) WHERE (type = 'ContributorFact'::text);


--
-- Name: index_name_facts_on_vita_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_name_facts_on_vita_id ON name_facts USING btree (vita_id);


--
-- Name: index_name_language_facts_analysis_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_name_language_facts_analysis_id ON name_language_facts USING btree (analysis_id);


--
-- Name: index_name_language_facts_name_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_name_language_facts_name_id ON name_language_facts USING btree (name_id);


--
-- Name: index_name_language_facts_on_language_id_total_months; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_name_language_facts_on_language_id_total_months ON name_language_facts USING btree (language_id, total_months DESC) WHERE (vita_id IS NOT NULL);


--
-- Name: index_name_language_facts_on_vita_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_name_language_facts_on_vita_id ON name_language_facts USING btree (vita_id);


--
-- Name: index_names_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_names_on_name ON names USING btree (name);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_on_commits_code_set_id_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_on_commits_code_set_id_position ON commits USING btree (code_set_id, "position");


--
-- Name: index_org_stats_by_sectors_on_created_at_and_org_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_org_stats_by_sectors_on_created_at_and_org_type ON org_stats_by_sectors USING btree (created_at, org_type);


--
-- Name: index_organizations_on_lower_url_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_organizations_on_lower_url_name ON organizations USING btree (lower(vanity_url));


--
-- Name: index_organizations_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_organizations_on_name ON organizations USING btree (lower(name));


--
-- Name: index_organizations_on_vector; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_organizations_on_vector ON organizations USING gin (vector);


--
-- Name: index_people_gin; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_gin ON people USING gin (vector);


--
-- Name: index_people_name_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_name_id ON people USING btree (name_id) WHERE (name_id IS NOT NULL);


--
-- Name: index_people_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_account_id ON people USING btree (account_id);


--
-- Name: index_people_on_kudo_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_kudo_position ON people USING btree ((COALESCE(kudo_position, 999999999)));


--
-- Name: index_people_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_project_id ON people USING btree (project_id);


--
-- Name: index_people_on_vector_gin; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_vector_gin ON people USING gin (vector);


--
-- Name: index_permissions_on_target; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_permissions_on_target ON permissions USING btree (target_id, target_type);


--
-- Name: index_positions_on_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_positions_on_organization_id ON positions USING btree (organization_id);


--
-- Name: index_posts_on_vector; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_posts_on_vector ON posts USING gist (vector);


--
-- Name: index_profiles_on_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_profiles_on_job_id ON profiles USING btree (job_id);


--
-- Name: index_project_events_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_events_on_project_id ON project_events USING btree (project_id);


--
-- Name: index_project_experiences_on_position_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_experiences_on_position_id ON project_experiences USING btree (position_id);


--
-- Name: index_project_gestalts_on_gestalt_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_gestalts_on_gestalt_id ON project_gestalts USING btree (gestalt_id);


--
-- Name: index_project_gestalts_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_gestalts_on_project_id ON project_gestalts USING btree (project_id);


--
-- Name: index_project_licenses_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_licenses_project_id ON project_licenses USING btree (project_id);


--
-- Name: index_project_reports_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_reports_on_project_id ON project_reports USING btree (project_id);


--
-- Name: index_project_reports_on_report_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_reports_on_report_id ON project_reports USING btree (report_id);


--
-- Name: index_projects_deleted; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_deleted ON projects USING btree (deleted, id);


--
-- Name: index_projects_on_best_analysis_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_best_analysis_id ON projects USING btree (best_analysis_id);


--
-- Name: index_projects_on_lower_url_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_lower_url_name ON projects USING btree (lower(vanity_url));


--
-- Name: index_projects_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_projects_on_name ON projects USING btree (lower(name));


--
-- Name: index_projects_on_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_organization_id ON projects USING btree (organization_id);


--
-- Name: index_projects_on_user_count; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_user_count ON projects USING btree (user_count DESC) WHERE (NOT deleted);


--
-- Name: index_projects_on_vector_gin; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_vector_gin ON projects USING gin (vector);


--
-- Name: index_ratings_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ratings_on_project_id ON ratings USING btree (project_id);


--
-- Name: index_recommend_entries_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_recommend_entries_on_project_id ON recommend_entries USING btree (project_id);


--
-- Name: index_repositories_on_best_code_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_repositories_on_best_code_set_id ON repositories USING btree (best_code_set_id);


--
-- Name: index_repositories_on_forge_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_repositories_on_forge_id ON repositories USING btree (forge_id);


--
-- Name: index_reviews_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reviews_on_account_id ON reviews USING btree (account_id);


--
-- Name: index_reviews_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reviews_on_project_id ON reviews USING btree (project_id);


--
-- Name: index_rss_articles_rss_feed_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rss_articles_rss_feed_id ON rss_articles USING btree (rss_feed_id);


--
-- Name: index_rss_articles_time; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rss_articles_time ON rss_articles USING btree ("time");


--
-- Name: index_rss_subscriptions_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rss_subscriptions_project_id ON rss_subscriptions USING btree (project_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_slave_logs_on_code_sets_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_slave_logs_on_code_sets_id ON slave_logs USING btree (code_set_id);


--
-- Name: index_slave_logs_on_created_on; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_slave_logs_on_created_on ON slave_logs USING btree (created_on);


--
-- Name: index_slave_logs_on_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_slave_logs_on_job_id ON slave_logs USING btree (job_id);


--
-- Name: index_slave_logs_on_slave_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_slave_logs_on_slave_id ON slave_logs USING btree (slave_id);


--
-- Name: index_sloc_metrics_on_diff_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sloc_metrics_on_diff_id ON sloc_metrics USING btree (diff_id);


--
-- Name: index_sloc_metrics_on_sloc_set_id_language_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sloc_metrics_on_sloc_set_id_language_id ON sloc_metrics USING btree (sloc_set_id, language_id);


--
-- Name: index_sloc_sets_on_code_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sloc_sets_on_code_set_id ON sloc_sets USING btree (code_set_id);


--
-- Name: index_stack_entries_on_project_stack_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_stack_entries_on_project_stack_id ON stack_entries USING btree (project_id, stack_id) WHERE (deleted_at IS NULL);


--
-- Name: index_stacks_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stacks_account_id ON stacks USING btree (account_id);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_taggable_id ON taggings USING btree (taggable_id);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_thirty_day_summaries_on_analysis_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_thirty_day_summaries_on_analysis_id ON thirty_day_summaries USING btree (analysis_id);


--
-- Name: index_vita_analyses_on_analysis_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vita_analyses_on_analysis_id ON vita_analyses USING btree (analysis_id);


--
-- Name: index_vita_analyses_on_vita_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vita_analyses_on_vita_id ON vita_analyses USING btree (vita_id);


--
-- Name: index_vitae_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vitae_on_account_id ON vitae USING btree (account_id);


--
-- Name: kudos_uniques; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX kudos_uniques ON kudos USING btree (sender_id, (COALESCE(account_id, 0)), (COALESCE(project_id, 0)), (COALESCE(name_id, 0)));


--
-- Name: people_on_name_fact_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX people_on_name_fact_id ON people USING btree (name_fact_id);


--
-- Name: posts_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX posts_account_id ON posts USING btree (account_id);


--
-- Name: posts_topic_ic; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX posts_topic_ic ON posts USING btree (topic_id);


--
-- Name: robin; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX robin ON name_facts USING btree (last_checkin) WHERE (type = 'VitaFact'::text);


--
-- Name: stack_entry_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stack_entry_project_id ON stack_entries USING btree (project_id);


--
-- Name: stack_entry_stack_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX stack_entry_stack_id ON stack_entries USING btree (stack_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: unique_stacks_titles_per_account; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_stacks_titles_per_account ON stacks USING btree (account_id, title);


--
-- Name: unique_stacks_titles_per_project; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_stacks_titles_per_project ON stacks USING btree (project_id, title);


--
-- Name: account_reports_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_reports
    ADD CONSTRAINT account_reports_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: account_reports_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_reports
    ADD CONSTRAINT account_reports_report_id_fkey FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE;


--
-- Name: accounts_about_markup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_about_markup_id_fkey FOREIGN KEY (about_markup_id) REFERENCES markups(id) ON DELETE CASCADE;


--
-- Name: accounts_best_vita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_best_vita_id_fkey FOREIGN KEY (best_vita_id) REFERENCES vitae(id);


--
-- Name: accounts_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;


--
-- Name: actions_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY actions
    ADD CONSTRAINT actions_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: actions_claim_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY actions
    ADD CONSTRAINT actions_claim_person_id_fkey FOREIGN KEY (claim_person_id) REFERENCES people(id);


--
-- Name: actions_stack_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY actions
    ADD CONSTRAINT actions_stack_project_id_fkey FOREIGN KEY (stack_project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: activity_facts_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activity_facts
    ADD CONSTRAINT activity_facts_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: activity_facts_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activity_facts
    ADD CONSTRAINT activity_facts_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id);


--
-- Name: aliases_commit_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY aliases
    ADD CONSTRAINT aliases_commit_name_id_fkey FOREIGN KEY (commit_name_id) REFERENCES names(id) ON DELETE CASCADE;


--
-- Name: aliases_preferred_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY aliases
    ADD CONSTRAINT aliases_preferred_name_id_fkey FOREIGN KEY (preferred_name_id) REFERENCES names(id) ON DELETE CASCADE;


--
-- Name: aliases_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY aliases
    ADD CONSTRAINT aliases_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: analyses_main_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analyses
    ADD CONSTRAINT analyses_main_language_id_fkey FOREIGN KEY (main_language_id) REFERENCES languages(id);


--
-- Name: analyses_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analyses
    ADD CONSTRAINT analyses_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: analysis_aliases_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_aliases
    ADD CONSTRAINT analysis_aliases_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: analysis_aliases_commit_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_aliases
    ADD CONSTRAINT analysis_aliases_commit_name_id_fkey FOREIGN KEY (commit_name_id) REFERENCES names(id) ON DELETE CASCADE;


--
-- Name: analysis_aliases_preferred_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_aliases
    ADD CONSTRAINT analysis_aliases_preferred_name_id_fkey FOREIGN KEY (preferred_name_id) REFERENCES names(id) ON DELETE CASCADE;


--
-- Name: analysis_sloc_sets_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_sloc_sets
    ADD CONSTRAINT analysis_sloc_sets_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: analysis_sloc_sets_sloc_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_sloc_sets
    ADD CONSTRAINT analysis_sloc_sets_sloc_set_id_fkey FOREIGN KEY (sloc_set_id) REFERENCES sloc_sets(id);


--
-- Name: analysis_summaries_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_summaries
    ADD CONSTRAINT analysis_summaries_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id);


--
-- Name: api_keys_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT api_keys_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: authorizations_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT authorizations_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: authorizations_api_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT authorizations_api_key_id_fkey FOREIGN KEY (api_key_id) REFERENCES api_keys(id) ON DELETE CASCADE;


--
-- Name: claims_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT claims_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: claims_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT claims_name_id_fkey FOREIGN KEY (name_id) REFERENCES names(id) ON DELETE CASCADE;


--
-- Name: claims_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT claims_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: clumps_code_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY clumps
    ADD CONSTRAINT clumps_code_set_id_fkey FOREIGN KEY (code_set_id) REFERENCES code_sets(id) ON DELETE CASCADE;


--
-- Name: clumps_slave_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY clumps
    ADD CONSTRAINT clumps_slave_id_fkey FOREIGN KEY (slave_id) REFERENCES slaves(id) ON DELETE CASCADE;


--
-- Name: code_set_gestalts_code_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_set_gestalts
    ADD CONSTRAINT code_set_gestalts_code_set_id_fkey FOREIGN KEY (code_set_id) REFERENCES code_sets(id) ON DELETE CASCADE;


--
-- Name: code_set_gestalts_gestalt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_set_gestalts
    ADD CONSTRAINT code_set_gestalts_gestalt_id_fkey FOREIGN KEY (gestalt_id) REFERENCES gestalts(id) ON DELETE CASCADE;


--
-- Name: code_sets_best_sloc_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_sets
    ADD CONSTRAINT code_sets_best_sloc_set_id_fkey FOREIGN KEY (best_sloc_set_id) REFERENCES sloc_sets(id);


--
-- Name: code_sets_repository_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_sets
    ADD CONSTRAINT code_sets_repository_id_fkey FOREIGN KEY (repository_id) REFERENCES repositories(id) ON DELETE CASCADE;


--
-- Name: commit_flags_commit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY commit_flags
    ADD CONSTRAINT commit_flags_commit_id_fkey FOREIGN KEY (commit_id) REFERENCES commits(id);


--
-- Name: commit_flags_sloc_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY commit_flags
    ADD CONSTRAINT commit_flags_sloc_set_id_fkey FOREIGN KEY (sloc_set_id) REFERENCES sloc_sets(id) ON DELETE CASCADE;


--
-- Name: commits_code_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY commits
    ADD CONSTRAINT commits_code_set_id_fkey FOREIGN KEY (code_set_id) REFERENCES code_sets(id) ON DELETE CASCADE;


--
-- Name: commits_email_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY commits
    ADD CONSTRAINT commits_email_address_id_fkey FOREIGN KEY (email_address_id) REFERENCES email_addresses(id);


--
-- Name: commits_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY commits
    ADD CONSTRAINT commits_name_id_fkey FOREIGN KEY (name_id) REFERENCES names(id);


--
-- Name: diffs_commit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY diffs
    ADD CONSTRAINT diffs_commit_id_fkey FOREIGN KEY (commit_id) REFERENCES commits(id) ON DELETE CASCADE;


--
-- Name: diffs_fyle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY diffs
    ADD CONSTRAINT diffs_fyle_id_fkey FOREIGN KEY (fyle_id) REFERENCES fyles(id);


--
-- Name: duplicates_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY duplicates
    ADD CONSTRAINT duplicates_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: duplicates_bad_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY duplicates
    ADD CONSTRAINT duplicates_bad_project_id_fkey FOREIGN KEY (bad_project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: duplicates_good_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY duplicates
    ADD CONSTRAINT duplicates_good_project_id_fkey FOREIGN KEY (good_project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: edits_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY old_edits
    ADD CONSTRAINT edits_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: edits_account_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edits
    ADD CONSTRAINT edits_account_id_fkey1 FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: edits_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edits
    ADD CONSTRAINT edits_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;


--
-- Name: edits_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY old_edits
    ADD CONSTRAINT edits_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: edits_project_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edits
    ADD CONSTRAINT edits_project_id_fkey1 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: edits_undone_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY old_edits
    ADD CONSTRAINT edits_undone_by_fkey FOREIGN KEY (undone_by) REFERENCES accounts(id);


--
-- Name: edits_undone_by_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edits
    ADD CONSTRAINT edits_undone_by_fkey1 FOREIGN KEY (undone_by) REFERENCES accounts(id);


--
-- Name: enlistments_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enlistments
    ADD CONSTRAINT enlistments_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: enlistments_repository_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enlistments
    ADD CONSTRAINT enlistments_repository_id_fkey FOREIGN KEY (repository_id) REFERENCES repositories(id) ON DELETE CASCADE;


--
-- Name: event_subscription_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_subscription
    ADD CONSTRAINT event_subscription_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: event_subscription_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_subscription
    ADD CONSTRAINT event_subscription_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: event_subscription_subscriber_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_subscription
    ADD CONSTRAINT event_subscription_subscriber_id_fkey FOREIGN KEY (subscriber_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: event_subscription_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_subscription
    ADD CONSTRAINT event_subscription_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE;


--
-- Name: exhibits_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY exhibits
    ADD CONSTRAINT exhibits_report_id_fkey FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE;


--
-- Name: factoids_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY factoids
    ADD CONSTRAINT factoids_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: factoids_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY factoids
    ADD CONSTRAINT factoids_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id);


--
-- Name: factoids_license_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY factoids
    ADD CONSTRAINT factoids_license_id_fkey FOREIGN KEY (license_id) REFERENCES licenses(id);


--
-- Name: fk_organization_ids; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY org_thirty_day_activities
    ADD CONSTRAINT fk_organization_ids FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;


--
-- Name: fk_rails_8faa63554c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT fk_rails_8faa63554c FOREIGN KEY (oauth_application_id) REFERENCES oauth_applications(id);


--
-- Name: follows_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY follows
    ADD CONSTRAINT follows_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: follows_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY follows
    ADD CONSTRAINT follows_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: follows_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY follows
    ADD CONSTRAINT follows_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: forums_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY forums
    ADD CONSTRAINT forums_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fyles_code_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fyles
    ADD CONSTRAINT fyles_code_set_id_fkey FOREIGN KEY (code_set_id) REFERENCES code_sets(id) ON DELETE CASCADE;


--
-- Name: gestaltings_gestalt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_gestalts
    ADD CONSTRAINT gestaltings_gestalt_id_fkey FOREIGN KEY (gestalt_id) REFERENCES gestalts(id) ON DELETE CASCADE;


--
-- Name: gestaltings_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_gestalts
    ADD CONSTRAINT gestaltings_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: helpfuls_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY helpfuls
    ADD CONSTRAINT helpfuls_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: helpfuls_review_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY helpfuls
    ADD CONSTRAINT helpfuls_review_id_fkey FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE;


--
-- Name: invites_invitee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_invitee_id_fkey FOREIGN KEY (invitee_id) REFERENCES accounts(id);


--
-- Name: invites_invitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_invitor_id_fkey FOREIGN KEY (invitor_id) REFERENCES accounts(id);


--
-- Name: invites_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_name_id_fkey FOREIGN KEY (name_id) REFERENCES names(id);


--
-- Name: invites_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invites
    ADD CONSTRAINT invites_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: jobs_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: jobs_code_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_code_set_id_fkey FOREIGN KEY (code_set_id) REFERENCES code_sets(id) ON DELETE CASCADE;


--
-- Name: jobs_failure_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_failure_group_id_fkey FOREIGN KEY (failure_group_id) REFERENCES failure_groups(id);


--
-- Name: jobs_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: jobs_repository_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_repository_id_fkey FOREIGN KEY (repository_id) REFERENCES repositories(id) ON DELETE CASCADE;


--
-- Name: jobs_slave_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_slave_id_fkey FOREIGN KEY (slave_id) REFERENCES slaves(id) ON DELETE CASCADE;


--
-- Name: jobs_sloc_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_sloc_set_id_fkey FOREIGN KEY (sloc_set_id) REFERENCES sloc_sets(id) ON DELETE CASCADE;


--
-- Name: knowledge_base_statuses_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY knowledge_base_statuses
    ADD CONSTRAINT knowledge_base_statuses_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: koders_statuses_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY koders_statuses
    ADD CONSTRAINT koders_statuses_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: kudos_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY kudos
    ADD CONSTRAINT kudos_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: kudos_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY kudos
    ADD CONSTRAINT kudos_name_id_fkey FOREIGN KEY (name_id) REFERENCES names(id) ON DELETE CASCADE;


--
-- Name: kudos_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY kudos
    ADD CONSTRAINT kudos_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: kudos_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY kudos
    ADD CONSTRAINT kudos_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: language_experiences_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY language_experiences
    ADD CONSTRAINT language_experiences_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE;


--
-- Name: language_experiences_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY language_experiences
    ADD CONSTRAINT language_experiences_position_id_fkey FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE CASCADE;


--
-- Name: language_facts_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY language_facts
    ADD CONSTRAINT language_facts_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE;


--
-- Name: license_facts_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY license_facts
    ADD CONSTRAINT license_facts_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: license_facts_license_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY license_facts
    ADD CONSTRAINT license_facts_license_id_fkey FOREIGN KEY (license_id) REFERENCES licenses(id);


--
-- Name: links_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: manages_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY manages
    ADD CONSTRAINT manages_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: manages_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY manages
    ADD CONSTRAINT manages_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES accounts(id);


--
-- Name: manages_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY manages
    ADD CONSTRAINT manages_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES accounts(id);


--
-- Name: message_account_tags_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_account_tags
    ADD CONSTRAINT message_account_tags_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: message_account_tags_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_account_tags
    ADD CONSTRAINT message_account_tags_message_id_fkey FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE;


--
-- Name: message_project_tags_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_project_tags
    ADD CONSTRAINT message_project_tags_message_id_fkey FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE;


--
-- Name: message_project_tags_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_project_tags
    ADD CONSTRAINT message_project_tags_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: messages_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: name_facts_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_facts
    ADD CONSTRAINT name_facts_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: name_facts_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_facts
    ADD CONSTRAINT name_facts_name_id_fkey FOREIGN KEY (name_id) REFERENCES names(id);


--
-- Name: name_facts_primary_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_facts
    ADD CONSTRAINT name_facts_primary_language_id_fkey FOREIGN KEY (primary_language_id) REFERENCES languages(id);


--
-- Name: name_facts_vita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_facts
    ADD CONSTRAINT name_facts_vita_id_fkey FOREIGN KEY (vita_id) REFERENCES vitae(id) ON DELETE CASCADE;


--
-- Name: name_language_facts_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_language_facts
    ADD CONSTRAINT name_language_facts_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: name_language_facts_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_language_facts
    ADD CONSTRAINT name_language_facts_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE;


--
-- Name: name_language_facts_most_commits_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_language_facts
    ADD CONSTRAINT name_language_facts_most_commits_project_id_fkey FOREIGN KEY (most_commits_project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: name_language_facts_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_language_facts
    ADD CONSTRAINT name_language_facts_name_id_fkey FOREIGN KEY (name_id) REFERENCES names(id) ON DELETE CASCADE;


--
-- Name: name_language_facts_recent_commit_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_language_facts
    ADD CONSTRAINT name_language_facts_recent_commit_project_id_fkey FOREIGN KEY (recent_commit_project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: name_language_facts_vita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY name_language_facts
    ADD CONSTRAINT name_language_facts_vita_id_fkey FOREIGN KEY (vita_id) REFERENCES vitae(id) ON DELETE CASCADE;


--
-- Name: organizations_logo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_logo_id_fkey FOREIGN KEY (logo_id) REFERENCES attachments(id);


--
-- Name: people_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: people_name_fact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_name_fact_id_fkey FOREIGN KEY (name_fact_id) REFERENCES name_facts(id) ON DELETE CASCADE;


--
-- Name: people_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_name_id_fkey FOREIGN KEY (name_id) REFERENCES names(id) ON DELETE CASCADE;


--
-- Name: people_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: positions_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT positions_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;


--
-- Name: posts_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: posts_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE;


--
-- Name: profiles_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: project_events_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_events
    ADD CONSTRAINT project_events_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: project_experiences_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_experiences
    ADD CONSTRAINT project_experiences_position_id_fkey FOREIGN KEY (position_id) REFERENCES positions(id) ON DELETE CASCADE;


--
-- Name: project_experiences_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_experiences
    ADD CONSTRAINT project_experiences_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: project_licenses_license_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_licenses
    ADD CONSTRAINT project_licenses_license_id_fkey FOREIGN KEY (license_id) REFERENCES licenses(id) ON DELETE CASCADE;


--
-- Name: project_licenses_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_licenses
    ADD CONSTRAINT project_licenses_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: project_reports_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_reports
    ADD CONSTRAINT project_reports_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: project_reports_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_reports
    ADD CONSTRAINT project_reports_report_id_fkey FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE;


--
-- Name: projects_best_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_best_analysis_id_fkey FOREIGN KEY (best_analysis_id) REFERENCES analyses(id);


--
-- Name: projects_forge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_forge_id_fkey FOREIGN KEY (forge_id) REFERENCES forges(id);


--
-- Name: projects_logo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_logo_id_fkey FOREIGN KEY (logo_id) REFERENCES attachments(id);


--
-- Name: projects_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations(id);


--
-- Name: ratings_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ratings
    ADD CONSTRAINT ratings_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: ratings_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ratings
    ADD CONSTRAINT ratings_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: recommend_entries_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommend_entries
    ADD CONSTRAINT recommend_entries_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: recommend_entries_project_id_recommends_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommend_entries
    ADD CONSTRAINT recommend_entries_project_id_recommends_fkey FOREIGN KEY (project_id_recommends) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: recommendations_invitee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommendations
    ADD CONSTRAINT recommendations_invitee_id_fkey FOREIGN KEY (invitee_id) REFERENCES accounts(id);


--
-- Name: recommendations_invitor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommendations
    ADD CONSTRAINT recommendations_invitor_id_fkey FOREIGN KEY (invitor_id) REFERENCES accounts(id);


--
-- Name: recommendations_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommendations
    ADD CONSTRAINT recommendations_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: repositories_best_code_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT repositories_best_code_set_id_fkey FOREIGN KEY (best_code_set_id) REFERENCES code_sets(id);


--
-- Name: repositories_forge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT repositories_forge_id_fkey FOREIGN KEY (forge_id) REFERENCES forges(id);


--
-- Name: reviews_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: reviews_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: rss_articles_rss_feed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rss_articles
    ADD CONSTRAINT rss_articles_rss_feed_id_fkey FOREIGN KEY (rss_feed_id) REFERENCES rss_feeds(id) ON DELETE CASCADE;


--
-- Name: rss_subscriptions_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rss_subscriptions
    ADD CONSTRAINT rss_subscriptions_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: rss_subscriptions_rss_feed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rss_subscriptions
    ADD CONSTRAINT rss_subscriptions_rss_feed_id_fkey FOREIGN KEY (rss_feed_id) REFERENCES rss_feeds(id) ON DELETE CASCADE;


--
-- Name: sfprojects_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sfprojects
    ADD CONSTRAINT sfprojects_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: slave_logs_code_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY slave_logs
    ADD CONSTRAINT slave_logs_code_set_id_fkey FOREIGN KEY (code_set_id) REFERENCES code_sets(id) ON DELETE CASCADE;


--
-- Name: slave_logs_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY slave_logs
    ADD CONSTRAINT slave_logs_job_id_fkey FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;


--
-- Name: slave_logs_slave_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY slave_logs
    ADD CONSTRAINT slave_logs_slave_id_fkey FOREIGN KEY (slave_id) REFERENCES slaves(id) ON DELETE CASCADE;


--
-- Name: sloc_metrics_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sloc_metrics
    ADD CONSTRAINT sloc_metrics_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id);


--
-- Name: sloc_metrics_sloc_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sloc_metrics
    ADD CONSTRAINT sloc_metrics_sloc_set_id_fkey FOREIGN KEY (sloc_set_id) REFERENCES sloc_sets(id) ON DELETE CASCADE;


--
-- Name: sloc_sets_code_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sloc_sets
    ADD CONSTRAINT sloc_sets_code_set_id_fkey FOREIGN KEY (code_set_id) REFERENCES code_sets(id) ON DELETE CASCADE;


--
-- Name: stack_entries_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stack_entries
    ADD CONSTRAINT stack_entries_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: stack_entries_stack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stack_entries
    ADD CONSTRAINT stack_entries_stack_id_fkey FOREIGN KEY (stack_id) REFERENCES stacks(id) ON DELETE CASCADE;


--
-- Name: stack_ignores_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stack_ignores
    ADD CONSTRAINT stack_ignores_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: stack_ignores_stack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stack_ignores
    ADD CONSTRAINT stack_ignores_stack_id_fkey FOREIGN KEY (stack_id) REFERENCES stacks(id) ON DELETE CASCADE;


--
-- Name: stacks_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stacks
    ADD CONSTRAINT stacks_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: stacks_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stacks
    ADD CONSTRAINT stacks_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;


--
-- Name: thirty_day_summaries_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY thirty_day_summaries
    ADD CONSTRAINT thirty_day_summaries_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: topics_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: topics_forum_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_forum_id_fkey FOREIGN KEY (forum_id) REFERENCES forums(id) ON DELETE CASCADE;


--
-- Name: topics_replied_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_replied_by_fkey FOREIGN KEY (replied_by) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- Name: vita_analyses_analysis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vita_analyses
    ADD CONSTRAINT vita_analyses_analysis_id_fkey FOREIGN KEY (analysis_id) REFERENCES analyses(id) ON DELETE CASCADE;


--
-- Name: vita_analyses_vita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vita_analyses
    ADD CONSTRAINT vita_analyses_vita_id_fkey FOREIGN KEY (vita_id) REFERENCES vitae(id) ON DELETE CASCADE;


--
-- Name: vitae_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vitae
    ADD CONSTRAINT vitae_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

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

