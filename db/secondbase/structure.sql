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
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


SET search_path = public, pg_catalog;

--
-- Name: account_reports_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION account_reports_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from account_reports_id_seq_view$$;


--
-- Name: accounts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION accounts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from accounts_id_seq_view$$;


--
-- Name: actions_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION actions_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from actions_id_seq_view$$;


--
-- Name: aliases_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION aliases_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from aliases_id_seq_view$$;


--
-- Name: analyses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION analyses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from analyses_id_seq_view$$;


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
-- Name: analysis_summaries_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION analysis_summaries_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from analysis_summaries_id_seq_view$$;


--
-- Name: api_keys_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION api_keys_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from api_keys_id_seq_view$$;


--
-- Name: attachments_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION attachments_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from attachments_id_seq_view$$;


--
-- Name: authorizations_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION authorizations_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from authorizations_id_seq_view$$;


--
-- Name: clumps_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION clumps_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from clumps_id_seq_view$$;


--
-- Name: code_location_tarballs_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION code_location_tarballs_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from code_location_tarballs_id_seq_view$$;


--
-- Name: code_locations_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION code_locations_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from code_locations_id_seq_view$$;


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
-- Name: deleted_accounts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION deleted_accounts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from deleted_accounts_id_seq_view$$;


--
-- Name: diff_licenses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION diff_licenses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from diff_licenses_id_seq_view$$;


--
-- Name: duplicates_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION duplicates_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from duplicates_id_seq_view$$;


--
-- Name: edits_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION edits_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from edits_id_seq_view$$;


--
-- Name: email_addresses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION email_addresses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from email_addresses_id_seq_view$$;


--
-- Name: enlistments_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION enlistments_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from enlistments_id_seq_view$$;


--
-- Name: event_subscription_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION event_subscription_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from event_subscription_id_seq_view$$;


--
-- Name: exhibits_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION exhibits_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from exhibits_id_seq_view$$;


--
-- Name: factoids_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION factoids_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from factoids_id_seq_view$$;


--
-- Name: failure_groups_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION failure_groups_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from failure_groups_id_seq_view$$;


--
-- Name: feedbacks_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION feedbacks_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from feedbacks_id_seq_view$$;


--
-- Name: fisbot_events_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fisbot_events_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from fisbot_events_id_seq_view$$;


--
-- Name: follows_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION follows_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from follows_id_seq_view$$;


--
-- Name: forges_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION forges_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from forges_id_seq_view$$;


--
-- Name: forums_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION forums_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from forums_id_seq_view$$;


--
-- Name: helpfuls_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION helpfuls_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from helpfuls_id_seq_view$$;


--
-- Name: invites_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION invites_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from invites_id_seq_view$$;


--
-- Name: jobs_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION jobs_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from jobs_id_seq_view$$;


--
-- Name: knowledge_base_statuses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION knowledge_base_statuses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from knowledge_base_statuses_id_seq_view$$;


--
-- Name: kudo_scores_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION kudo_scores_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from kudo_scores_id_seq_view$$;


--
-- Name: kudos_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION kudos_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from kudos_id_seq_view$$;


--
-- Name: language_experiences_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION language_experiences_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from language_experiences_id_seq_view$$;


--
-- Name: language_facts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION language_facts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from language_facts_id_seq_view$$;


--
-- Name: languages_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION languages_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from languages_id_seq_view$$;


--
-- Name: license_facts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION license_facts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from license_facts_id_seq_view$$;


--
-- Name: licenses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION licenses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from licenses_id_seq_view$$;


--
-- Name: link_categories_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION link_categories_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from link_categories_id_seq_view$$;


--
-- Name: links_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION links_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from links_id_seq_view$$;


--
-- Name: load_averages_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION load_averages_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from load_averages_id_seq_view$$;


--
-- Name: manages_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION manages_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from manages_id_seq_view$$;


--
-- Name: markups_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION markups_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from markups_id_seq_view$$;


--
-- Name: message_account_tags_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION message_account_tags_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from message_account_tags_id_seq_view$$;


--
-- Name: message_project_tags_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION message_project_tags_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from message_project_tags_id_seq_view$$;


--
-- Name: messages_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION messages_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from messages_id_seq_view$$;


--
-- Name: moderatorships_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION moderatorships_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from moderatorships_id_seq_view$$;


--
-- Name: monitorships_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION monitorships_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from monitorships_id_seq_view$$;


--
-- Name: monthly_commit_histories_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION monthly_commit_histories_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from monthly_commit_histories_id_seq_view$$;


--
-- Name: name_facts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION name_facts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from name_facts_id_seq_view$$;


--
-- Name: name_language_facts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION name_language_facts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from name_language_facts_id_seq_view$$;


--
-- Name: names_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION names_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from names_id_seq_view$$;


--
-- Name: oauth_access_grants_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION oauth_access_grants_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from oauth_access_grants_id_seq_view$$;


--
-- Name: oauth_access_tokens_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION oauth_access_tokens_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from oauth_access_tokens_id_seq_view$$;


--
-- Name: oauth_applications_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION oauth_applications_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from oauth_applications_id_seq_view$$;


--
-- Name: oauth_nonces_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION oauth_nonces_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from oauth_nonces_id_seq_view$$;


--
-- Name: old_edits_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION old_edits_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from old_edits_id_seq_view$$;


--
-- Name: org_stats_by_sectors_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION org_stats_by_sectors_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from org_stats_by_sectors_id_seq_view$$;


--
-- Name: org_thirty_day_activities_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION org_thirty_day_activities_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from org_thirty_day_activities_id_seq_view$$;


--
-- Name: organizations_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION organizations_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from organizations_id_seq_view$$;


--
-- Name: pages_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pages_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from pages_id_seq_view$$;


--
-- Name: permissions_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION permissions_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from permissions_id_seq_view$$;


--
-- Name: positions_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION positions_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from positions_id_seq_view$$;


--
-- Name: posts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION posts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from posts_id_seq_view$$;


--
-- Name: profiles_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION profiles_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from profiles_id_seq_view$$;


--
-- Name: project_badges_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION project_badges_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from project_badges_id_seq_view$$;


--
-- Name: project_events_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION project_events_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from project_events_id_seq_view$$;


--
-- Name: project_experiences_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION project_experiences_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from project_experiences_id_seq_view$$;


--
-- Name: project_licenses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION project_licenses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from project_licenses_id_seq_view$$;


--
-- Name: project_reports_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION project_reports_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from project_reports_id_seq_view$$;


--
-- Name: project_security_sets_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION project_security_sets_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from project_security_sets_id_seq_view$$;


--
-- Name: project_vulnerability_reports_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION project_vulnerability_reports_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from project_vulnerability_reports_id_seq_view$$;


--
-- Name: projects_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION projects_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from projects_id_seq_view$$;


--
-- Name: ratings_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ratings_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from ratings_id_seq_view$$;


--
-- Name: recently_active_accounts_cache_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION recently_active_accounts_cache_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from recently_active_accounts_cache_id_seq_view$$;


--
-- Name: recommend_entries_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION recommend_entries_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from recommend_entries_id_seq_view$$;


--
-- Name: recommendations_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION recommendations_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from recommendations_id_seq_view$$;


--
-- Name: releases_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION releases_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from releases_id_seq_view$$;


--
-- Name: reports_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION reports_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from reports_id_seq_view$$;


--
-- Name: repositories_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION repositories_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from repositories_id_seq_view$$;


--
-- Name: repository_directories_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION repository_directories_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from repository_directories_id_seq_view$$;


--
-- Name: repository_tags_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION repository_tags_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from repository_tags_id_seq_view$$;


--
-- Name: reverification_trackers_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION reverification_trackers_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from reverification_trackers_id_seq_view$$;


--
-- Name: reviews_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION reviews_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from reviews_id_seq_view$$;


--
-- Name: rss_articles_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rss_articles_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from rss_articles_id_seq_view$$;


--
-- Name: rss_feeds_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rss_feeds_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from rss_feeds_id_seq_view$$;


--
-- Name: rss_subscriptions_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rss_subscriptions_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from rss_subscriptions_id_seq_view$$;


--
-- Name: sessions_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sessions_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from sessions_id_seq_view$$;


--
-- Name: settings_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION settings_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from settings_id_seq_view$$;


--
-- Name: size_facts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION size_facts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from size_facts_id_seq_view$$;


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
-- Name: sloc_sets_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sloc_sets_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from sloc_sets_id_seq_view$$;


--
-- Name: stack_entries_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION stack_entries_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from stack_entries_id_seq_view$$;


--
-- Name: stack_ignores_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION stack_ignores_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from stack_ignores_id_seq_view$$;


--
-- Name: stacks_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION stacks_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from stacks_id_seq_view$$;


--
-- Name: successful_accounts_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION successful_accounts_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from successful_accounts_id_seq_view$$;


--
-- Name: taggings_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION taggings_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from taggings_id_seq_view$$;


--
-- Name: tags_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tags_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from tags_id_seq_view$$;


--
-- Name: thirty_day_summaries_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION thirty_day_summaries_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from thirty_day_summaries_id_seq_view$$;


--
-- Name: tools_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tools_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from tools_id_seq_view$$;


--
-- Name: topics_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION topics_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from topics_id_seq_view$$;


--
-- Name: verifications_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION verifications_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from verifications_id_seq_view$$;


--
-- Name: vita_analyses_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION vita_analyses_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from vita_analyses_id_seq_view$$;


--
-- Name: vitae_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION vitae_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from vitae_id_seq_view$$;


--
-- Name: vulnerabilities_id_seq_view(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION vulnerabilities_id_seq_view() RETURNS integer
    LANGUAGE sql
    AS $$select id from vulnerabilities_id_seq_view$$;


--
-- Name: ohloh; Type: SERVER; Schema: -; Owner: -
--

CREATE SERVER ohloh FOREIGN DATA WRAPPER postgres_fdw OPTIONS (
    dbname 'openhub_test',
    host 'localhost',
    port '5432'
);


--
-- Name: USER MAPPING openhub_user SERVER ohloh; Type: USER MAPPING; Schema: -; Owner: -
--

CREATE USER MAPPING FOR openhub_user SERVER ohloh OPTIONS (
    password 'openhub_password',
    "user" 'openhub_user'
);


SET default_tablespace = '';

--
-- Name: account_reports; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE account_reports (
    id integer DEFAULT account_reports_id_seq_view() NOT NULL,
    account_id integer NOT NULL,
    report_id integer NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'account_reports'
);
ALTER FOREIGN TABLE account_reports ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE account_reports ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE account_reports ALTER COLUMN report_id OPTIONS (
    column_name 'report_id'
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
-- Name: account_reports_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE account_reports_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'account_reports_id_seq_view'
);
ALTER FOREIGN TABLE account_reports_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: accounts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE accounts (
    id integer DEFAULT accounts_id_seq_view() NOT NULL,
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
    organization_name text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'accounts'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN login OPTIONS (
    column_name 'login'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN email OPTIONS (
    column_name 'email'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN crypted_password OPTIONS (
    column_name 'crypted_password'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN salt OPTIONS (
    column_name 'salt'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN activation_code OPTIONS (
    column_name 'activation_code'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN activated_at OPTIONS (
    column_name 'activated_at'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN remember_token OPTIONS (
    column_name 'remember_token'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN remember_token_expires_at OPTIONS (
    column_name 'remember_token_expires_at'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN level OPTIONS (
    column_name 'level'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN posts_count OPTIONS (
    column_name 'posts_count'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN last_seen_at OPTIONS (
    column_name 'last_seen_at'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN country_code OPTIONS (
    column_name 'country_code'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN location OPTIONS (
    column_name 'location'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN latitude OPTIONS (
    column_name 'latitude'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN longitude OPTIONS (
    column_name 'longitude'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN best_vita_id OPTIONS (
    column_name 'best_vita_id'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN url OPTIONS (
    column_name 'url'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN about_markup_id OPTIONS (
    column_name 'about_markup_id'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN hide_experience OPTIONS (
    column_name 'hide_experience'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN email_master OPTIONS (
    column_name 'email_master'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN email_posts OPTIONS (
    column_name 'email_posts'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN email_kudos OPTIONS (
    column_name 'email_kudos'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN email_md5 OPTIONS (
    column_name 'email_md5'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN email_opportunities_visited OPTIONS (
    column_name 'email_opportunities_visited'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN activation_resent_at OPTIONS (
    column_name 'activation_resent_at'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN akas OPTIONS (
    column_name 'akas'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN email_new_followers OPTIONS (
    column_name 'email_new_followers'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN last_seen_ip OPTIONS (
    column_name 'last_seen_ip'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN twitter_account OPTIONS (
    column_name 'twitter_account'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN reset_password_tokens OPTIONS (
    column_name 'reset_password_tokens'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN affiliation_type OPTIONS (
    column_name 'affiliation_type'
);
ALTER FOREIGN TABLE accounts ALTER COLUMN organization_name OPTIONS (
    column_name 'organization_name'
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
-- Name: accounts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE accounts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'accounts_id_seq_view'
);
ALTER FOREIGN TABLE accounts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: actions; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE actions (
    id integer DEFAULT actions_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE actions ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE actions ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE actions ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE actions ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE actions ALTER COLUMN status OPTIONS (
    column_name 'status'
);
ALTER FOREIGN TABLE actions ALTER COLUMN stack_project_id OPTIONS (
    column_name 'stack_project_id'
);
ALTER FOREIGN TABLE actions ALTER COLUMN claim_person_id OPTIONS (
    column_name 'claim_person_id'
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
-- Name: actions_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE actions_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'actions_id_seq_view'
);
ALTER FOREIGN TABLE actions_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
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
-- Name: activity_facts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE activity_facts (
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'activity_facts'
);
ALTER FOREIGN TABLE activity_facts ALTER COLUMN month OPTIONS (
    column_name 'month'
);
ALTER FOREIGN TABLE activity_facts ALTER COLUMN language_id OPTIONS (
    column_name 'language_id'
);
ALTER FOREIGN TABLE activity_facts ALTER COLUMN code_added OPTIONS (
    column_name 'code_added'
);
ALTER FOREIGN TABLE activity_facts ALTER COLUMN code_removed OPTIONS (
    column_name 'code_removed'
);
ALTER FOREIGN TABLE activity_facts ALTER COLUMN comments_added OPTIONS (
    column_name 'comments_added'
);
ALTER FOREIGN TABLE activity_facts ALTER COLUMN comments_removed OPTIONS (
    column_name 'comments_removed'
);
ALTER FOREIGN TABLE activity_facts ALTER COLUMN blanks_added OPTIONS (
    column_name 'blanks_added'
);
ALTER FOREIGN TABLE activity_facts ALTER COLUMN blanks_removed OPTIONS (
    column_name 'blanks_removed'
);
ALTER FOREIGN TABLE activity_facts ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE activity_facts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE activity_facts ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE activity_facts ALTER COLUMN commits OPTIONS (
    column_name 'commits'
);
ALTER FOREIGN TABLE activity_facts ALTER COLUMN on_trunk OPTIONS (
    column_name 'on_trunk'
);


--
-- Name: activity_facts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE activity_facts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'activity_facts_id_seq_view'
);
ALTER FOREIGN TABLE activity_facts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: aliases; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE aliases (
    id integer DEFAULT aliases_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE aliases ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE aliases ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE aliases ALTER COLUMN commit_name_id OPTIONS (
    column_name 'commit_name_id'
);
ALTER FOREIGN TABLE aliases ALTER COLUMN preferred_name_id OPTIONS (
    column_name 'preferred_name_id'
);
ALTER FOREIGN TABLE aliases ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
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
-- Name: aliases_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE aliases_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'aliases_id_seq_view'
);
ALTER FOREIGN TABLE aliases_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: all_months; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE all_months (
    month timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'all_months'
);
ALTER FOREIGN TABLE all_months ALTER COLUMN month OPTIONS (
    column_name 'month'
);


--
-- Name: analyses; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE analyses (
    id integer DEFAULT analyses_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE analyses ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN as_of OPTIONS (
    column_name 'as_of'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN updated_on OPTIONS (
    column_name 'updated_on'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN main_language_id OPTIONS (
    column_name 'main_language_id'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN relative_comments OPTIONS (
    column_name 'relative_comments'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN logic_total OPTIONS (
    column_name 'logic_total'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN markup_total OPTIONS (
    column_name 'markup_total'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN headcount OPTIONS (
    column_name 'headcount'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN min_month OPTIONS (
    column_name 'min_month'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN max_month OPTIONS (
    column_name 'max_month'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN oldest_code_set_time OPTIONS (
    column_name 'oldest_code_set_time'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN committers_all_time OPTIONS (
    column_name 'committers_all_time'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN first_commit_time OPTIONS (
    column_name 'first_commit_time'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN last_commit_time OPTIONS (
    column_name 'last_commit_time'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN commit_count OPTIONS (
    column_name 'commit_count'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN build_total OPTIONS (
    column_name 'build_total'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN activity_score OPTIONS (
    column_name 'activity_score'
);
ALTER FOREIGN TABLE analyses ALTER COLUMN hotness_score OPTIONS (
    column_name 'hotness_score'
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
-- Name: analyses_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE analyses_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'analyses_id_seq_view'
);
ALTER FOREIGN TABLE analyses_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


SET default_with_oids = false;

--
-- Name: analysis_aliases; Type: TABLE; Schema: public; Owner: -
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
-- Name: analysis_aliases_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW analysis_aliases_id_seq_view AS
 SELECT (nextval('analysis_aliases_id_seq'::regclass))::integer AS id;


--
-- Name: analysis_sloc_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE analysis_sloc_sets (
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

CREATE SEQUENCE analysis_sloc_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analysis_sloc_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE analysis_sloc_sets_id_seq OWNED BY analysis_sloc_sets.id;


--
-- Name: analysis_sloc_sets_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW analysis_sloc_sets_id_seq_view AS
 SELECT (nextval('analysis_sloc_sets_id_seq'::regclass))::integer AS id;


--
-- Name: analysis_summaries; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE analysis_summaries (
    id integer DEFAULT analysis_summaries_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE analysis_summaries ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE analysis_summaries ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE analysis_summaries ALTER COLUMN files_modified OPTIONS (
    column_name 'files_modified'
);
ALTER FOREIGN TABLE analysis_summaries ALTER COLUMN lines_added OPTIONS (
    column_name 'lines_added'
);
ALTER FOREIGN TABLE analysis_summaries ALTER COLUMN lines_removed OPTIONS (
    column_name 'lines_removed'
);
ALTER FOREIGN TABLE analysis_summaries ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE analysis_summaries ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE analysis_summaries ALTER COLUMN recent_contributors OPTIONS (
    column_name 'recent_contributors'
);
ALTER FOREIGN TABLE analysis_summaries ALTER COLUMN new_contributors_count OPTIONS (
    column_name 'new_contributors_count'
);
ALTER FOREIGN TABLE analysis_summaries ALTER COLUMN affiliated_committers_count OPTIONS (
    column_name 'affiliated_committers_count'
);
ALTER FOREIGN TABLE analysis_summaries ALTER COLUMN affiliated_commits_count OPTIONS (
    column_name 'affiliated_commits_count'
);
ALTER FOREIGN TABLE analysis_summaries ALTER COLUMN outside_committers_count OPTIONS (
    column_name 'outside_committers_count'
);
ALTER FOREIGN TABLE analysis_summaries ALTER COLUMN outside_commits_count OPTIONS (
    column_name 'outside_commits_count'
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
-- Name: analysis_summaries_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE analysis_summaries_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'analysis_summaries_id_seq_view'
);
ALTER FOREIGN TABLE analysis_summaries_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: api_keys; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE api_keys (
    id integer DEFAULT api_keys_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE api_keys ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN key OPTIONS (
    column_name 'key'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN daily_count OPTIONS (
    column_name 'daily_count'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN daily_limit OPTIONS (
    column_name 'daily_limit'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN day_began_at OPTIONS (
    column_name 'day_began_at'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN last_access_at OPTIONS (
    column_name 'last_access_at'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN total_count OPTIONS (
    column_name 'total_count'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN status OPTIONS (
    column_name 'status'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN url OPTIONS (
    column_name 'url'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN support_url OPTIONS (
    column_name 'support_url'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN callback_url OPTIONS (
    column_name 'callback_url'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN secret OPTIONS (
    column_name 'secret'
);
ALTER FOREIGN TABLE api_keys ALTER COLUMN oauth_application_id OPTIONS (
    column_name 'oauth_application_id'
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
-- Name: api_keys_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE api_keys_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'api_keys_id_seq_view'
);
ALTER FOREIGN TABLE api_keys_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: attachments; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE attachments (
    id integer DEFAULT attachments_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE attachments ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE attachments ALTER COLUMN parent_id OPTIONS (
    column_name 'parent_id'
);
ALTER FOREIGN TABLE attachments ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE attachments ALTER COLUMN thumbnail OPTIONS (
    column_name 'thumbnail'
);
ALTER FOREIGN TABLE attachments ALTER COLUMN filename OPTIONS (
    column_name 'filename'
);
ALTER FOREIGN TABLE attachments ALTER COLUMN content_type OPTIONS (
    column_name 'content_type'
);
ALTER FOREIGN TABLE attachments ALTER COLUMN size OPTIONS (
    column_name 'size'
);
ALTER FOREIGN TABLE attachments ALTER COLUMN width OPTIONS (
    column_name 'width'
);
ALTER FOREIGN TABLE attachments ALTER COLUMN height OPTIONS (
    column_name 'height'
);
ALTER FOREIGN TABLE attachments ALTER COLUMN is_default OPTIONS (
    column_name 'is_default'
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
-- Name: attachments_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE attachments_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'attachments_id_seq_view'
);
ALTER FOREIGN TABLE attachments_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: authorizations; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE authorizations (
    id integer DEFAULT authorizations_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE authorizations ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE authorizations ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE authorizations ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE authorizations ALTER COLUMN api_key_id OPTIONS (
    column_name 'api_key_id'
);
ALTER FOREIGN TABLE authorizations ALTER COLUMN token OPTIONS (
    column_name 'token'
);
ALTER FOREIGN TABLE authorizations ALTER COLUMN secret OPTIONS (
    column_name 'secret'
);
ALTER FOREIGN TABLE authorizations ALTER COLUMN authorized_at OPTIONS (
    column_name 'authorized_at'
);
ALTER FOREIGN TABLE authorizations ALTER COLUMN invalidated_at OPTIONS (
    column_name 'invalidated_at'
);
ALTER FOREIGN TABLE authorizations ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE authorizations ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: authorizations_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE authorizations_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'authorizations_id_seq_view'
);
ALTER FOREIGN TABLE authorizations_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: claims_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE claims_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'claims_id_seq_view'
);
ALTER FOREIGN TABLE claims_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: clumps; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE clumps (
    id integer DEFAULT clumps_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE clumps ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE clumps ALTER COLUMN slave_id OPTIONS (
    column_name 'slave_id'
);
ALTER FOREIGN TABLE clumps ALTER COLUMN code_set_id OPTIONS (
    column_name 'code_set_id'
);
ALTER FOREIGN TABLE clumps ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE clumps ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE clumps ALTER COLUMN fetched_at OPTIONS (
    column_name 'fetched_at'
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
-- Name: clumps_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE clumps_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'clumps_id_seq_view'
);
ALTER FOREIGN TABLE clumps_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: code_location_job_feeders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE code_location_job_feeders (
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

CREATE SEQUENCE code_location_job_feeders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_location_job_feeders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE code_location_job_feeders_id_seq OWNED BY code_location_job_feeders.id;


--
-- Name: code_location_tarballs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE code_location_tarballs (
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

CREATE SEQUENCE code_location_tarballs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_location_tarballs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE code_location_tarballs_id_seq OWNED BY code_location_tarballs.id;


--
-- Name: code_location_tarballs_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW code_location_tarballs_id_seq_view AS
 SELECT (nextval('code_location_tarballs_id_seq'::regclass))::integer AS id;


--
-- Name: code_locations; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE code_locations (
    id integer DEFAULT code_locations_id_seq_view() NOT NULL,
    repository_id integer,
    module_branch_name text,
    status integer DEFAULT 0,
    best_code_set_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    update_interval integer DEFAULT 3600,
    best_repository_directory_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'code_locations'
);
ALTER FOREIGN TABLE code_locations ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE code_locations ALTER COLUMN repository_id OPTIONS (
    column_name 'repository_id'
);
ALTER FOREIGN TABLE code_locations ALTER COLUMN module_branch_name OPTIONS (
    column_name 'module_branch_name'
);
ALTER FOREIGN TABLE code_locations ALTER COLUMN status OPTIONS (
    column_name 'status'
);
ALTER FOREIGN TABLE code_locations ALTER COLUMN best_code_set_id OPTIONS (
    column_name 'best_code_set_id'
);
ALTER FOREIGN TABLE code_locations ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE code_locations ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE code_locations ALTER COLUMN update_interval OPTIONS (
    column_name 'update_interval'
);
ALTER FOREIGN TABLE code_locations ALTER COLUMN best_repository_directory_id OPTIONS (
    column_name 'best_repository_directory_id'
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
-- Name: code_locations_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE code_locations_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'code_locations_id_seq_view'
);
ALTER FOREIGN TABLE code_locations_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: code_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE code_sets (
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

CREATE SEQUENCE code_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE code_sets_id_seq OWNED BY code_sets.id;


--
-- Name: code_sets_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW code_sets_id_seq_view AS
 SELECT (nextval('code_sets_id_seq'::regclass))::integer AS id;


--
-- Name: positions; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE positions (
    id integer DEFAULT positions_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE positions ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE positions ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE positions ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE positions ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE positions ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE positions ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE positions ALTER COLUMN organization_name OPTIONS (
    column_name 'organization_name'
);
ALTER FOREIGN TABLE positions ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE positions ALTER COLUMN start_date OPTIONS (
    column_name 'start_date'
);
ALTER FOREIGN TABLE positions ALTER COLUMN stop_date OPTIONS (
    column_name 'stop_date'
);
ALTER FOREIGN TABLE positions ALTER COLUMN ongoing OPTIONS (
    column_name 'ongoing'
);
ALTER FOREIGN TABLE positions ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);
ALTER FOREIGN TABLE positions ALTER COLUMN affiliation_type OPTIONS (
    column_name 'affiliation_type'
);


--
-- Name: projects; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE projects (
    id integer DEFAULT projects_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE projects ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE projects ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE projects ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE projects ALTER COLUMN comments OPTIONS (
    column_name 'comments'
);
ALTER FOREIGN TABLE projects ALTER COLUMN best_analysis_id OPTIONS (
    column_name 'best_analysis_id'
);
ALTER FOREIGN TABLE projects ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
);
ALTER FOREIGN TABLE projects ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE projects ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE projects ALTER COLUMN old_name OPTIONS (
    column_name 'old_name'
);
ALTER FOREIGN TABLE projects ALTER COLUMN missing_source OPTIONS (
    column_name 'missing_source'
);
ALTER FOREIGN TABLE projects ALTER COLUMN logo_id OPTIONS (
    column_name 'logo_id'
);
ALTER FOREIGN TABLE projects ALTER COLUMN vanity_url OPTIONS (
    column_name 'vanity_url'
);
ALTER FOREIGN TABLE projects ALTER COLUMN downloadable OPTIONS (
    column_name 'downloadable'
);
ALTER FOREIGN TABLE projects ALTER COLUMN scraped OPTIONS (
    column_name 'scraped'
);
ALTER FOREIGN TABLE projects ALTER COLUMN vector OPTIONS (
    column_name 'vector'
);
ALTER FOREIGN TABLE projects ALTER COLUMN popularity_factor OPTIONS (
    column_name 'popularity_factor'
);
ALTER FOREIGN TABLE projects ALTER COLUMN user_count OPTIONS (
    column_name 'user_count'
);
ALTER FOREIGN TABLE projects ALTER COLUMN rating_average OPTIONS (
    column_name 'rating_average'
);
ALTER FOREIGN TABLE projects ALTER COLUMN forge_id OPTIONS (
    column_name 'forge_id'
);
ALTER FOREIGN TABLE projects ALTER COLUMN name_at_forge OPTIONS (
    column_name 'name_at_forge'
);
ALTER FOREIGN TABLE projects ALTER COLUMN owner_at_forge OPTIONS (
    column_name 'owner_at_forge'
);
ALTER FOREIGN TABLE projects ALTER COLUMN active_committers OPTIONS (
    column_name 'active_committers'
);
ALTER FOREIGN TABLE projects ALTER COLUMN kb_id OPTIONS (
    column_name 'kb_id'
);
ALTER FOREIGN TABLE projects ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);
ALTER FOREIGN TABLE projects ALTER COLUMN activity_level_index OPTIONS (
    column_name 'activity_level_index'
);
ALTER FOREIGN TABLE projects ALTER COLUMN uuid OPTIONS (
    column_name 'uuid'
);
ALTER FOREIGN TABLE projects ALTER COLUMN best_project_security_set_id OPTIONS (
    column_name 'best_project_security_set_id'
);


--
-- Name: sloc_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sloc_sets (
    id integer NOT NULL,
    code_set_id integer NOT NULL,
    updated_on timestamp without time zone,
    as_of integer,
    code_set_time timestamp without time zone
);


--
-- Name: commit_contributors; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW commit_contributors AS
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
   FROM ((((analysis_sloc_sets
     JOIN sloc_sets ON ((analysis_sloc_sets.sloc_set_id = sloc_sets.id)))
     JOIN projects ON ((analysis_sloc_sets.analysis_id = projects.best_analysis_id)))
     JOIN analysis_aliases ON ((analysis_aliases.analysis_id = analysis_sloc_sets.analysis_id)))
     LEFT JOIN positions ON (((positions.project_id = projects.id) AND (positions.name_id = analysis_aliases.preferred_name_id))));


--
-- Name: commit_flags; Type: TABLE; Schema: public; Owner: -
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
-- Name: commit_flags_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW commit_flags_id_seq_view AS
 SELECT (nextval('commit_flags_id_seq'::regclass))::integer AS id;


--
-- Name: commit_spark_analysis_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE commit_spark_analysis_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE commits (
    id integer NOT NULL,
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

CREATE SEQUENCE commits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE commits_id_seq OWNED BY commits.id;


--
-- Name: commits_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW commits_id_seq_view AS
 SELECT (nextval('commits_id_seq'::regclass))::integer AS id;


--
-- Name: contributions; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE contributions (
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
ALTER FOREIGN TABLE contributions ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE contributions ALTER COLUMN person_id OPTIONS (
    column_name 'person_id'
);
ALTER FOREIGN TABLE contributions ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE contributions ALTER COLUMN name_fact_id OPTIONS (
    column_name 'name_fact_id'
);
ALTER FOREIGN TABLE contributions ALTER COLUMN position_id OPTIONS (
    column_name 'position_id'
);


--
-- Name: contributions2; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE contributions2 (
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
ALTER FOREIGN TABLE contributions2 ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE contributions2 ALTER COLUMN name_fact_id OPTIONS (
    column_name 'name_fact_id'
);
ALTER FOREIGN TABLE contributions2 ALTER COLUMN position_id OPTIONS (
    column_name 'position_id'
);
ALTER FOREIGN TABLE contributions2 ALTER COLUMN person_id OPTIONS (
    column_name 'person_id'
);
ALTER FOREIGN TABLE contributions2 ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);


--
-- Name: countries; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE countries (
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
ALTER FOREIGN TABLE countries ALTER COLUMN country_code OPTIONS (
    column_name 'country_code'
);
ALTER FOREIGN TABLE countries ALTER COLUMN continent_code OPTIONS (
    column_name 'continent_code'
);
ALTER FOREIGN TABLE countries ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE countries ALTER COLUMN region OPTIONS (
    column_name 'region'
);


--
-- Name: deleted_accounts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE deleted_accounts (
    id integer DEFAULT deleted_accounts_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE deleted_accounts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE deleted_accounts ALTER COLUMN login OPTIONS (
    column_name 'login'
);
ALTER FOREIGN TABLE deleted_accounts ALTER COLUMN email OPTIONS (
    column_name 'email'
);
ALTER FOREIGN TABLE deleted_accounts ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);
ALTER FOREIGN TABLE deleted_accounts ALTER COLUMN claimed_project_ids OPTIONS (
    column_name 'claimed_project_ids'
);
ALTER FOREIGN TABLE deleted_accounts ALTER COLUMN reasons OPTIONS (
    column_name 'reasons'
);
ALTER FOREIGN TABLE deleted_accounts ALTER COLUMN reason_other OPTIONS (
    column_name 'reason_other'
);
ALTER FOREIGN TABLE deleted_accounts ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE deleted_accounts ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: deleted_accounts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE deleted_accounts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'deleted_accounts_id_seq_view'
);
ALTER FOREIGN TABLE deleted_accounts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


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
-- Name: diff_licenses_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE diff_licenses_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'diff_licenses_id_seq_view'
);
ALTER FOREIGN TABLE diff_licenses_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: diffs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE diffs (
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

CREATE SEQUENCE diffs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: diffs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE diffs_id_seq OWNED BY diffs.id;


--
-- Name: diffs_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW diffs_id_seq_view AS
 SELECT (nextval('diffs_id_seq'::regclass))::integer AS id;


--
-- Name: duplicates; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE duplicates (
    id integer DEFAULT duplicates_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE duplicates ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE duplicates ALTER COLUMN good_project_id OPTIONS (
    column_name 'good_project_id'
);
ALTER FOREIGN TABLE duplicates ALTER COLUMN bad_project_id OPTIONS (
    column_name 'bad_project_id'
);
ALTER FOREIGN TABLE duplicates ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE duplicates ALTER COLUMN comment OPTIONS (
    column_name 'comment'
);
ALTER FOREIGN TABLE duplicates ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE duplicates ALTER COLUMN resolved OPTIONS (
    column_name 'resolved'
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
-- Name: duplicates_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE duplicates_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'duplicates_id_seq_view'
);
ALTER FOREIGN TABLE duplicates_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: edits; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE edits (
    id integer DEFAULT edits_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE edits ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE edits ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE edits ALTER COLUMN target_id OPTIONS (
    column_name 'target_id'
);
ALTER FOREIGN TABLE edits ALTER COLUMN target_type OPTIONS (
    column_name 'target_type'
);
ALTER FOREIGN TABLE edits ALTER COLUMN key OPTIONS (
    column_name 'key'
);
ALTER FOREIGN TABLE edits ALTER COLUMN value OPTIONS (
    column_name 'value'
);
ALTER FOREIGN TABLE edits ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE edits ALTER COLUMN ip OPTIONS (
    column_name 'ip'
);
ALTER FOREIGN TABLE edits ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE edits ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE edits ALTER COLUMN undone OPTIONS (
    column_name 'undone'
);
ALTER FOREIGN TABLE edits ALTER COLUMN undone_at OPTIONS (
    column_name 'undone_at'
);
ALTER FOREIGN TABLE edits ALTER COLUMN undone_by OPTIONS (
    column_name 'undone_by'
);
ALTER FOREIGN TABLE edits ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE edits ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);


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
-- Name: edits_id_seq1_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE edits_id_seq1_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'edits_id_seq1_view'
);
ALTER FOREIGN TABLE edits_id_seq1_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: edits_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE edits_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'edits_id_seq_view'
);
ALTER FOREIGN TABLE edits_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: email_addresses; Type: TABLE; Schema: public; Owner: -
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
-- Name: email_addresses_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW email_addresses_id_seq_view AS
 SELECT (nextval('email_addresses_id_seq'::regclass))::integer AS id;


--
-- Name: enlistments; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE enlistments (
    id integer DEFAULT enlistments_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE enlistments ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE enlistments ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE enlistments ALTER COLUMN repository_id OPTIONS (
    column_name 'repository_id'
);
ALTER FOREIGN TABLE enlistments ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
);
ALTER FOREIGN TABLE enlistments ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE enlistments ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE enlistments ALTER COLUMN ignore OPTIONS (
    column_name 'ignore'
);
ALTER FOREIGN TABLE enlistments ALTER COLUMN code_location_id OPTIONS (
    column_name 'code_location_id'
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
-- Name: enlistments_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE enlistments_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'enlistments_id_seq_view'
);
ALTER FOREIGN TABLE enlistments_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: event_subscription; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE event_subscription (
    id integer DEFAULT event_subscription_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE event_subscription ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE event_subscription ALTER COLUMN subscriber_id OPTIONS (
    column_name 'subscriber_id'
);
ALTER FOREIGN TABLE event_subscription ALTER COLUMN klass OPTIONS (
    column_name 'klass'
);
ALTER FOREIGN TABLE event_subscription ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE event_subscription ALTER COLUMN topic_id OPTIONS (
    column_name 'topic_id'
);
ALTER FOREIGN TABLE event_subscription ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE event_subscription ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
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
-- Name: event_subscription_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE event_subscription_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'event_subscription_id_seq_view'
);
ALTER FOREIGN TABLE event_subscription_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: exhibits; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE exhibits (
    id integer DEFAULT exhibits_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE exhibits ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE exhibits ALTER COLUMN report_id OPTIONS (
    column_name 'report_id'
);
ALTER FOREIGN TABLE exhibits ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE exhibits ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE exhibits ALTER COLUMN params OPTIONS (
    column_name 'params'
);
ALTER FOREIGN TABLE exhibits ALTER COLUMN result OPTIONS (
    column_name 'result'
);
ALTER FOREIGN TABLE exhibits ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE exhibits ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: exhibits_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE exhibits_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'exhibits_id_seq_view'
);
ALTER FOREIGN TABLE exhibits_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: factoids; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE factoids (
    id integer DEFAULT factoids_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE factoids ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE factoids ALTER COLUMN severity OPTIONS (
    column_name 'severity'
);
ALTER FOREIGN TABLE factoids ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE factoids ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE factoids ALTER COLUMN license_id OPTIONS (
    column_name 'license_id'
);
ALTER FOREIGN TABLE factoids ALTER COLUMN language_id OPTIONS (
    column_name 'language_id'
);
ALTER FOREIGN TABLE factoids ALTER COLUMN previous_count OPTIONS (
    column_name 'previous_count'
);
ALTER FOREIGN TABLE factoids ALTER COLUMN current_count OPTIONS (
    column_name 'current_count'
);
ALTER FOREIGN TABLE factoids ALTER COLUMN max_count OPTIONS (
    column_name 'max_count'
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
-- Name: factoids_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE factoids_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'factoids_id_seq_view'
);
ALTER FOREIGN TABLE factoids_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: failure_groups; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE failure_groups (
    id integer DEFAULT failure_groups_id_seq_view() NOT NULL,
    name text NOT NULL,
    pattern text NOT NULL,
    priority integer DEFAULT 0,
    auto_reschedule boolean DEFAULT false
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'failure_groups'
);
ALTER FOREIGN TABLE failure_groups ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE failure_groups ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE failure_groups ALTER COLUMN pattern OPTIONS (
    column_name 'pattern'
);
ALTER FOREIGN TABLE failure_groups ALTER COLUMN priority OPTIONS (
    column_name 'priority'
);
ALTER FOREIGN TABLE failure_groups ALTER COLUMN auto_reschedule OPTIONS (
    column_name 'auto_reschedule'
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
-- Name: failure_groups_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE failure_groups_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'failure_groups_id_seq_view'
);
ALTER FOREIGN TABLE failure_groups_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: feedbacks; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE feedbacks (
    id integer DEFAULT feedbacks_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE feedbacks ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE feedbacks ALTER COLUMN rating OPTIONS (
    column_name 'rating'
);
ALTER FOREIGN TABLE feedbacks ALTER COLUMN more_info OPTIONS (
    column_name 'more_info'
);
ALTER FOREIGN TABLE feedbacks ALTER COLUMN uuid OPTIONS (
    column_name 'uuid'
);
ALTER FOREIGN TABLE feedbacks ALTER COLUMN ip_address OPTIONS (
    column_name 'ip_address'
);
ALTER FOREIGN TABLE feedbacks ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE feedbacks ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE feedbacks ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: feedbacks_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE feedbacks_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'feedbacks_id_seq_view'
);
ALTER FOREIGN TABLE feedbacks_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: fisbot_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE fisbot_events (
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

CREATE SEQUENCE fisbot_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fisbot_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fisbot_events_id_seq OWNED BY fisbot_events.id;


--
-- Name: fisbot_events_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW fisbot_events_id_seq_view AS
 SELECT (nextval('fisbot_events_id_seq'::regclass))::integer AS id;


--
-- Name: followed_messages; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE followed_messages (
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
ALTER FOREIGN TABLE followed_messages ALTER COLUMN owner_id OPTIONS (
    column_name 'owner_id'
);
ALTER FOREIGN TABLE followed_messages ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE followed_messages ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE followed_messages ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE followed_messages ALTER COLUMN deleted_at OPTIONS (
    column_name 'deleted_at'
);
ALTER FOREIGN TABLE followed_messages ALTER COLUMN body OPTIONS (
    column_name 'body'
);
ALTER FOREIGN TABLE followed_messages ALTER COLUMN title OPTIONS (
    column_name 'title'
);


--
-- Name: follows; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE follows (
    id integer DEFAULT follows_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE follows ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE follows ALTER COLUMN owner_id OPTIONS (
    column_name 'owner_id'
);
ALTER FOREIGN TABLE follows ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE follows ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE follows ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);


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
-- Name: follows_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE follows_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'follows_id_seq_view'
);
ALTER FOREIGN TABLE follows_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: forges; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE forges (
    id integer DEFAULT forges_id_seq_view() NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    type text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'forges'
);
ALTER FOREIGN TABLE forges ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE forges ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE forges ALTER COLUMN url OPTIONS (
    column_name 'url'
);
ALTER FOREIGN TABLE forges ALTER COLUMN type OPTIONS (
    column_name 'type'
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
-- Name: forges_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE forges_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'forges_id_seq_view'
);
ALTER FOREIGN TABLE forges_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: forums; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE forums (
    id integer DEFAULT forums_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE forums ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE forums ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE forums ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE forums ALTER COLUMN topics_count OPTIONS (
    column_name 'topics_count'
);
ALTER FOREIGN TABLE forums ALTER COLUMN posts_count OPTIONS (
    column_name 'posts_count'
);
ALTER FOREIGN TABLE forums ALTER COLUMN "position" OPTIONS (
    column_name 'position'
);
ALTER FOREIGN TABLE forums ALTER COLUMN description OPTIONS (
    column_name 'description'
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
-- Name: forums_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE forums_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'forums_id_seq_view'
);
ALTER FOREIGN TABLE forums_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: fyles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE fyles (
    id integer NOT NULL,
    name text NOT NULL,
    code_set_id integer NOT NULL
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
-- Name: fyles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fyles_id_seq OWNED BY fyles.id;


--
-- Name: fyles_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW fyles_id_seq_view AS
 SELECT (nextval('fyles_id_seq'::regclass))::integer AS id;


--
-- Name: github_project; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE github_project (
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
ALTER FOREIGN TABLE github_project ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN owner OPTIONS (
    column_name 'owner'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN state_code OPTIONS (
    column_name 'state_code'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN homepage OPTIONS (
    column_name 'homepage'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN has_downloads OPTIONS (
    column_name 'has_downloads'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN is_fork OPTIONS (
    column_name 'is_fork'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN created OPTIONS (
    column_name 'created'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN updated OPTIONS (
    column_name 'updated'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN last_spidered OPTIONS (
    column_name 'last_spidered'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN parent OPTIONS (
    column_name 'parent'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN source OPTIONS (
    column_name 'source'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN watchers OPTIONS (
    column_name 'watchers'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN forks OPTIONS (
    column_name 'forks'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN project_created OPTIONS (
    column_name 'project_created'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN note OPTIONS (
    column_name 'note'
);
ALTER FOREIGN TABLE github_project ALTER COLUMN organization OPTIONS (
    column_name 'organization'
);


--
-- Name: guaranteed_spam_accounts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE guaranteed_spam_accounts (
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
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN login OPTIONS (
    column_name 'login'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN email OPTIONS (
    column_name 'email'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN crypted_password OPTIONS (
    column_name 'crypted_password'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN salt OPTIONS (
    column_name 'salt'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN activation_code OPTIONS (
    column_name 'activation_code'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN activated_at OPTIONS (
    column_name 'activated_at'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN remember_token OPTIONS (
    column_name 'remember_token'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN remember_token_expires_at OPTIONS (
    column_name 'remember_token_expires_at'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN level OPTIONS (
    column_name 'level'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN posts_count OPTIONS (
    column_name 'posts_count'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN last_seen_at OPTIONS (
    column_name 'last_seen_at'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN country_code OPTIONS (
    column_name 'country_code'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN location OPTIONS (
    column_name 'location'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN latitude OPTIONS (
    column_name 'latitude'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN longitude OPTIONS (
    column_name 'longitude'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN best_vita_id OPTIONS (
    column_name 'best_vita_id'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN url OPTIONS (
    column_name 'url'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN about_markup_id OPTIONS (
    column_name 'about_markup_id'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN hide_experience OPTIONS (
    column_name 'hide_experience'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN email_master OPTIONS (
    column_name 'email_master'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN email_posts OPTIONS (
    column_name 'email_posts'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN email_kudos OPTIONS (
    column_name 'email_kudos'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN email_md5 OPTIONS (
    column_name 'email_md5'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN email_opportunities_visited OPTIONS (
    column_name 'email_opportunities_visited'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN activation_resent_at OPTIONS (
    column_name 'activation_resent_at'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN akas OPTIONS (
    column_name 'akas'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN email_new_followers OPTIONS (
    column_name 'email_new_followers'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN last_seen_ip OPTIONS (
    column_name 'last_seen_ip'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN twitter_account OPTIONS (
    column_name 'twitter_account'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN reset_password_tokens OPTIONS (
    column_name 'reset_password_tokens'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN affiliation_type OPTIONS (
    column_name 'affiliation_type'
);
ALTER FOREIGN TABLE guaranteed_spam_accounts ALTER COLUMN organization_name OPTIONS (
    column_name 'organization_name'
);


--
-- Name: helpfuls; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE helpfuls (
    id integer DEFAULT helpfuls_id_seq_view() NOT NULL,
    review_id integer,
    account_id integer NOT NULL,
    yes boolean DEFAULT true
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'helpfuls'
);
ALTER FOREIGN TABLE helpfuls ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE helpfuls ALTER COLUMN review_id OPTIONS (
    column_name 'review_id'
);
ALTER FOREIGN TABLE helpfuls ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE helpfuls ALTER COLUMN yes OPTIONS (
    column_name 'yes'
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
-- Name: helpfuls_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE helpfuls_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'helpfuls_id_seq_view'
);
ALTER FOREIGN TABLE helpfuls_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: invites; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE invites (
    id integer DEFAULT invites_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE invites ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE invites ALTER COLUMN invitor_id OPTIONS (
    column_name 'invitor_id'
);
ALTER FOREIGN TABLE invites ALTER COLUMN invitee_id OPTIONS (
    column_name 'invitee_id'
);
ALTER FOREIGN TABLE invites ALTER COLUMN invitee_email OPTIONS (
    column_name 'invitee_email'
);
ALTER FOREIGN TABLE invites ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE invites ALTER COLUMN activation_code OPTIONS (
    column_name 'activation_code'
);
ALTER FOREIGN TABLE invites ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE invites ALTER COLUMN activated_at OPTIONS (
    column_name 'activated_at'
);
ALTER FOREIGN TABLE invites ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE invites ALTER COLUMN contribution_id OPTIONS (
    column_name 'contribution_id'
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
-- Name: invites_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE invites_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'invites_id_seq_view'
);
ALTER FOREIGN TABLE invites_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: job_statuses; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE job_statuses (
    id integer NOT NULL,
    name text NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'job_statuses'
);
ALTER FOREIGN TABLE job_statuses ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE job_statuses ALTER COLUMN name OPTIONS (
    column_name 'name'
);


--
-- Name: jobs; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE jobs (
    id integer DEFAULT jobs_id_seq_view() NOT NULL,
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'jobs'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN status OPTIONS (
    column_name 'status'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN priority OPTIONS (
    column_name 'priority'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN current_step OPTIONS (
    column_name 'current_step'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN current_step_at OPTIONS (
    column_name 'current_step_at'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN max_steps OPTIONS (
    column_name 'max_steps'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN exception OPTIONS (
    column_name 'exception'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN backtrace OPTIONS (
    column_name 'backtrace'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN code_set_id OPTIONS (
    column_name 'code_set_id'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN sloc_set_id OPTIONS (
    column_name 'sloc_set_id'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN notes OPTIONS (
    column_name 'notes'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN wait_until OPTIONS (
    column_name 'wait_until'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN logged_at OPTIONS (
    column_name 'logged_at'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN slave_id OPTIONS (
    column_name 'slave_id'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN started_at OPTIONS (
    column_name 'started_at'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN retry_count OPTIONS (
    column_name 'retry_count'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN do_not_retry OPTIONS (
    column_name 'do_not_retry'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN failure_group_id OPTIONS (
    column_name 'failure_group_id'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN code_location_id OPTIONS (
    column_name 'code_location_id'
);
ALTER FOREIGN TABLE jobs ALTER COLUMN code_location_tarball_id OPTIONS (
    column_name 'code_location_tarball_id'
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
-- Name: jobs_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE jobs_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'jobs_id_seq_view'
);
ALTER FOREIGN TABLE jobs_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: knowledge_base_statuses; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE knowledge_base_statuses (
    id integer DEFAULT knowledge_base_statuses_id_seq_view() NOT NULL,
    project_id integer NOT NULL,
    in_sync boolean DEFAULT false,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'knowledge_base_statuses'
);
ALTER FOREIGN TABLE knowledge_base_statuses ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE knowledge_base_statuses ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE knowledge_base_statuses ALTER COLUMN in_sync OPTIONS (
    column_name 'in_sync'
);
ALTER FOREIGN TABLE knowledge_base_statuses ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: knowledge_base_statuses_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE knowledge_base_statuses_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'knowledge_base_statuses_id_seq_view'
);
ALTER FOREIGN TABLE knowledge_base_statuses_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: kudo_scores; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE kudo_scores (
    id integer DEFAULT kudo_scores_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE kudo_scores ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE kudo_scores ALTER COLUMN array_index OPTIONS (
    column_name 'array_index'
);
ALTER FOREIGN TABLE kudo_scores ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE kudo_scores ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE kudo_scores ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE kudo_scores ALTER COLUMN damping OPTIONS (
    column_name 'damping'
);
ALTER FOREIGN TABLE kudo_scores ALTER COLUMN fraction OPTIONS (
    column_name 'fraction'
);
ALTER FOREIGN TABLE kudo_scores ALTER COLUMN score OPTIONS (
    column_name 'score'
);
ALTER FOREIGN TABLE kudo_scores ALTER COLUMN "position" OPTIONS (
    column_name 'position'
);
ALTER FOREIGN TABLE kudo_scores ALTER COLUMN rank OPTIONS (
    column_name 'rank'
);


--
-- Name: kudo_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE kudo_scores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kudo_scores_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE kudo_scores_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'kudo_scores_id_seq_view'
);
ALTER FOREIGN TABLE kudo_scores_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: kudos; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE kudos (
    id integer DEFAULT kudos_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE kudos ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE kudos ALTER COLUMN sender_id OPTIONS (
    column_name 'sender_id'
);
ALTER FOREIGN TABLE kudos ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE kudos ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE kudos ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE kudos ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE kudos ALTER COLUMN message OPTIONS (
    column_name 'message'
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
-- Name: kudos_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE kudos_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'kudos_id_seq_view'
);
ALTER FOREIGN TABLE kudos_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: language_experiences; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE language_experiences (
    id integer DEFAULT language_experiences_id_seq_view() NOT NULL,
    position_id integer NOT NULL,
    language_id integer NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'language_experiences'
);
ALTER FOREIGN TABLE language_experiences ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE language_experiences ALTER COLUMN position_id OPTIONS (
    column_name 'position_id'
);
ALTER FOREIGN TABLE language_experiences ALTER COLUMN language_id OPTIONS (
    column_name 'language_id'
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
-- Name: language_experiences_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE language_experiences_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'language_experiences_id_seq_view'
);
ALTER FOREIGN TABLE language_experiences_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: language_facts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE language_facts (
    id integer DEFAULT language_facts_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE language_facts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE language_facts ALTER COLUMN month OPTIONS (
    column_name 'month'
);
ALTER FOREIGN TABLE language_facts ALTER COLUMN language_id OPTIONS (
    column_name 'language_id'
);
ALTER FOREIGN TABLE language_facts ALTER COLUMN commits OPTIONS (
    column_name 'commits'
);
ALTER FOREIGN TABLE language_facts ALTER COLUMN loc_changed OPTIONS (
    column_name 'loc_changed'
);
ALTER FOREIGN TABLE language_facts ALTER COLUMN loc_total OPTIONS (
    column_name 'loc_total'
);
ALTER FOREIGN TABLE language_facts ALTER COLUMN projects OPTIONS (
    column_name 'projects'
);
ALTER FOREIGN TABLE language_facts ALTER COLUMN contributors OPTIONS (
    column_name 'contributors'
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
-- Name: language_facts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE language_facts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'language_facts_id_seq_view'
);
ALTER FOREIGN TABLE language_facts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: languages; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE languages (
    id integer DEFAULT languages_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE languages ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE languages ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE languages ALTER COLUMN nice_name OPTIONS (
    column_name 'nice_name'
);
ALTER FOREIGN TABLE languages ALTER COLUMN category OPTIONS (
    column_name 'category'
);
ALTER FOREIGN TABLE languages ALTER COLUMN avg_percent_comments OPTIONS (
    column_name 'avg_percent_comments'
);
ALTER FOREIGN TABLE languages ALTER COLUMN code OPTIONS (
    column_name 'code'
);
ALTER FOREIGN TABLE languages ALTER COLUMN comments OPTIONS (
    column_name 'comments'
);
ALTER FOREIGN TABLE languages ALTER COLUMN blanks OPTIONS (
    column_name 'blanks'
);
ALTER FOREIGN TABLE languages ALTER COLUMN commits OPTIONS (
    column_name 'commits'
);
ALTER FOREIGN TABLE languages ALTER COLUMN projects OPTIONS (
    column_name 'projects'
);
ALTER FOREIGN TABLE languages ALTER COLUMN contributors OPTIONS (
    column_name 'contributors'
);
ALTER FOREIGN TABLE languages ALTER COLUMN active_contributors OPTIONS (
    column_name 'active_contributors'
);
ALTER FOREIGN TABLE languages ALTER COLUMN experienced_contributors OPTIONS (
    column_name 'experienced_contributors'
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
-- Name: languages_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE languages_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'languages_id_seq_view'
);
ALTER FOREIGN TABLE languages_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: license_facts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE license_facts (
    license_id integer NOT NULL,
    file_count integer DEFAULT 0 NOT NULL,
    scope integer DEFAULT 0 NOT NULL,
    id integer DEFAULT license_facts_id_seq_view() NOT NULL,
    analysis_id integer NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'license_facts'
);
ALTER FOREIGN TABLE license_facts ALTER COLUMN license_id OPTIONS (
    column_name 'license_id'
);
ALTER FOREIGN TABLE license_facts ALTER COLUMN file_count OPTIONS (
    column_name 'file_count'
);
ALTER FOREIGN TABLE license_facts ALTER COLUMN scope OPTIONS (
    column_name 'scope'
);
ALTER FOREIGN TABLE license_facts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE license_facts ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
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
-- Name: license_facts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE license_facts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'license_facts_id_seq_view'
);
ALTER FOREIGN TABLE license_facts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: licenses; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE licenses (
    id integer DEFAULT licenses_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE licenses ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE licenses ALTER COLUMN vanity_url OPTIONS (
    column_name 'vanity_url'
);
ALTER FOREIGN TABLE licenses ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE licenses ALTER COLUMN abbreviation OPTIONS (
    column_name 'abbreviation'
);
ALTER FOREIGN TABLE licenses ALTER COLUMN url OPTIONS (
    column_name 'url'
);
ALTER FOREIGN TABLE licenses ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE licenses ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
);
ALTER FOREIGN TABLE licenses ALTER COLUMN locked OPTIONS (
    column_name 'locked'
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
-- Name: licenses_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE licenses_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'licenses_id_seq_view'
);
ALTER FOREIGN TABLE licenses_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
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
-- Name: link_categories_deleted; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE link_categories_deleted (
    id integer DEFAULT nextval('link_categories_id_seq'::regclass) NOT NULL,
    name text NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'link_categories_deleted'
);
ALTER FOREIGN TABLE link_categories_deleted ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE link_categories_deleted ALTER COLUMN name OPTIONS (
    column_name 'name'
);


--
-- Name: link_categories_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE link_categories_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'link_categories_id_seq_view'
);
ALTER FOREIGN TABLE link_categories_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: links; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE links (
    id integer DEFAULT links_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE links ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE links ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE links ALTER COLUMN url OPTIONS (
    column_name 'url'
);
ALTER FOREIGN TABLE links ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE links ALTER COLUMN link_category_id OPTIONS (
    column_name 'link_category_id'
);
ALTER FOREIGN TABLE links ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
);
ALTER FOREIGN TABLE links ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE links ALTER COLUMN helpful_score OPTIONS (
    column_name 'helpful_score'
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
-- Name: links_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE links_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'links_id_seq_view'
);
ALTER FOREIGN TABLE links_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: load_averages; Type: TABLE; Schema: public; Owner: -
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
-- Name: load_averages_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW load_averages_id_seq_view AS
 SELECT (nextval('load_averages_id_seq'::regclass))::integer AS id;


--
-- Name: manages; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE manages (
    id integer DEFAULT manages_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE manages ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE manages ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE manages ALTER COLUMN target_id OPTIONS (
    column_name 'target_id'
);
ALTER FOREIGN TABLE manages ALTER COLUMN message OPTIONS (
    column_name 'message'
);
ALTER FOREIGN TABLE manages ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE manages ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE manages ALTER COLUMN approved_by OPTIONS (
    column_name 'approved_by'
);
ALTER FOREIGN TABLE manages ALTER COLUMN deleted_by OPTIONS (
    column_name 'deleted_by'
);
ALTER FOREIGN TABLE manages ALTER COLUMN deleted_at OPTIONS (
    column_name 'deleted_at'
);
ALTER FOREIGN TABLE manages ALTER COLUMN target_type OPTIONS (
    column_name 'target_type'
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
-- Name: manages_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE manages_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'manages_id_seq_view'
);
ALTER FOREIGN TABLE manages_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: markups; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE markups (
    id integer DEFAULT markups_id_seq_view() NOT NULL,
    raw text,
    formatted text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'markups'
);
ALTER FOREIGN TABLE markups ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE markups ALTER COLUMN raw OPTIONS (
    column_name 'raw'
);
ALTER FOREIGN TABLE markups ALTER COLUMN formatted OPTIONS (
    column_name 'formatted'
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
-- Name: markups_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE markups_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'markups_id_seq_view'
);
ALTER FOREIGN TABLE markups_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: message_account_tags; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE message_account_tags (
    id integer DEFAULT message_account_tags_id_seq_view() NOT NULL,
    message_id integer,
    account_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'message_account_tags'
);
ALTER FOREIGN TABLE message_account_tags ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE message_account_tags ALTER COLUMN message_id OPTIONS (
    column_name 'message_id'
);
ALTER FOREIGN TABLE message_account_tags ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);


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
-- Name: message_account_tags_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE message_account_tags_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'message_account_tags_id_seq_view'
);
ALTER FOREIGN TABLE message_account_tags_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: message_project_tags; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE message_project_tags (
    id integer DEFAULT message_project_tags_id_seq_view() NOT NULL,
    message_id integer,
    project_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'message_project_tags'
);
ALTER FOREIGN TABLE message_project_tags ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE message_project_tags ALTER COLUMN message_id OPTIONS (
    column_name 'message_id'
);
ALTER FOREIGN TABLE message_project_tags ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);


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
-- Name: message_project_tags_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE message_project_tags_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'message_project_tags_id_seq_view'
);
ALTER FOREIGN TABLE message_project_tags_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: messages; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE messages (
    id integer DEFAULT messages_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE messages ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE messages ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE messages ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE messages ALTER COLUMN deleted_at OPTIONS (
    column_name 'deleted_at'
);
ALTER FOREIGN TABLE messages ALTER COLUMN body OPTIONS (
    column_name 'body'
);
ALTER FOREIGN TABLE messages ALTER COLUMN title OPTIONS (
    column_name 'title'
);


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
-- Name: messages_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE messages_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'messages_id_seq_view'
);
ALTER FOREIGN TABLE messages_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: mistaken_jobs; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE mistaken_jobs (
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
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN repository_id OPTIONS (
    column_name 'repository_id'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN status OPTIONS (
    column_name 'status'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN priority OPTIONS (
    column_name 'priority'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN current_step OPTIONS (
    column_name 'current_step'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN current_step_at OPTIONS (
    column_name 'current_step_at'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN max_steps OPTIONS (
    column_name 'max_steps'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN exception OPTIONS (
    column_name 'exception'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN backtrace OPTIONS (
    column_name 'backtrace'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN code_set_id OPTIONS (
    column_name 'code_set_id'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN sloc_set_id OPTIONS (
    column_name 'sloc_set_id'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN notes OPTIONS (
    column_name 'notes'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN wait_until OPTIONS (
    column_name 'wait_until'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN logged_at OPTIONS (
    column_name 'logged_at'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN slave_id OPTIONS (
    column_name 'slave_id'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN started_at OPTIONS (
    column_name 'started_at'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN retry_count OPTIONS (
    column_name 'retry_count'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN do_not_retry OPTIONS (
    column_name 'do_not_retry'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN failure_group_id OPTIONS (
    column_name 'failure_group_id'
);
ALTER FOREIGN TABLE mistaken_jobs ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);


--
-- Name: moderatorships_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE moderatorships_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'moderatorships_id_seq_view'
);
ALTER FOREIGN TABLE moderatorships_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: monitorships_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE monitorships_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'monitorships_id_seq_view'
);
ALTER FOREIGN TABLE monitorships_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: monthly_commit_histories; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE monthly_commit_histories (
    id integer DEFAULT monthly_commit_histories_id_seq_view() NOT NULL,
    analysis_id integer,
    json text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'monthly_commit_histories'
);
ALTER FOREIGN TABLE monthly_commit_histories ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE monthly_commit_histories ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE monthly_commit_histories ALTER COLUMN json OPTIONS (
    column_name 'json'
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
-- Name: monthly_commit_histories_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE monthly_commit_histories_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'monthly_commit_histories_id_seq_view'
);
ALTER FOREIGN TABLE monthly_commit_histories_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: name_facts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE name_facts (
    id integer DEFAULT name_facts_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE name_facts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN primary_language_id OPTIONS (
    column_name 'primary_language_id'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN total_code_added OPTIONS (
    column_name 'total_code_added'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN last_checkin OPTIONS (
    column_name 'last_checkin'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN comment_ratio OPTIONS (
    column_name 'comment_ratio'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN man_months OPTIONS (
    column_name 'man_months'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN commits OPTIONS (
    column_name 'commits'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN median_commits OPTIONS (
    column_name 'median_commits'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN median_activity_lines OPTIONS (
    column_name 'median_activity_lines'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN first_checkin OPTIONS (
    column_name 'first_checkin'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN vita_id OPTIONS (
    column_name 'vita_id'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN thirty_day_commits OPTIONS (
    column_name 'thirty_day_commits'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN twelve_month_commits OPTIONS (
    column_name 'twelve_month_commits'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN commits_by_project OPTIONS (
    column_name 'commits_by_project'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN commits_by_language OPTIONS (
    column_name 'commits_by_language'
);
ALTER FOREIGN TABLE name_facts ALTER COLUMN email_address_ids OPTIONS (
    column_name 'email_address_ids'
);


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
-- Name: name_facts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE name_facts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'name_facts_id_seq_view'
);
ALTER FOREIGN TABLE name_facts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: name_language_facts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE name_language_facts (
    id integer DEFAULT name_language_facts_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE name_language_facts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE name_language_facts ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE name_language_facts ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE name_language_facts ALTER COLUMN language_id OPTIONS (
    column_name 'language_id'
);
ALTER FOREIGN TABLE name_language_facts ALTER COLUMN total_months OPTIONS (
    column_name 'total_months'
);
ALTER FOREIGN TABLE name_language_facts ALTER COLUMN total_commits OPTIONS (
    column_name 'total_commits'
);
ALTER FOREIGN TABLE name_language_facts ALTER COLUMN total_activity_lines OPTIONS (
    column_name 'total_activity_lines'
);
ALTER FOREIGN TABLE name_language_facts ALTER COLUMN vita_id OPTIONS (
    column_name 'vita_id'
);
ALTER FOREIGN TABLE name_language_facts ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE name_language_facts ALTER COLUMN comment_ratio OPTIONS (
    column_name 'comment_ratio'
);
ALTER FOREIGN TABLE name_language_facts ALTER COLUMN most_commits_project_id OPTIONS (
    column_name 'most_commits_project_id'
);
ALTER FOREIGN TABLE name_language_facts ALTER COLUMN most_commits OPTIONS (
    column_name 'most_commits'
);
ALTER FOREIGN TABLE name_language_facts ALTER COLUMN recent_commit_project_id OPTIONS (
    column_name 'recent_commit_project_id'
);
ALTER FOREIGN TABLE name_language_facts ALTER COLUMN recent_commit_month OPTIONS (
    column_name 'recent_commit_month'
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
-- Name: name_language_facts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE name_language_facts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'name_language_facts_id_seq_view'
);
ALTER FOREIGN TABLE name_language_facts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: names; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE names (
    id integer DEFAULT names_id_seq_view() NOT NULL,
    name text NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'names'
);
ALTER FOREIGN TABLE names ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE names ALTER COLUMN name OPTIONS (
    column_name 'name'
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
-- Name: names_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE names_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'names_id_seq_view'
);
ALTER FOREIGN TABLE names_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: oauth_access_grants; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE oauth_access_grants (
    id integer DEFAULT oauth_access_grants_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE oauth_access_grants ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE oauth_access_grants ALTER COLUMN resource_owner_id OPTIONS (
    column_name 'resource_owner_id'
);
ALTER FOREIGN TABLE oauth_access_grants ALTER COLUMN application_id OPTIONS (
    column_name 'application_id'
);
ALTER FOREIGN TABLE oauth_access_grants ALTER COLUMN token OPTIONS (
    column_name 'token'
);
ALTER FOREIGN TABLE oauth_access_grants ALTER COLUMN expires_in OPTIONS (
    column_name 'expires_in'
);
ALTER FOREIGN TABLE oauth_access_grants ALTER COLUMN redirect_uri OPTIONS (
    column_name 'redirect_uri'
);
ALTER FOREIGN TABLE oauth_access_grants ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE oauth_access_grants ALTER COLUMN revoked_at OPTIONS (
    column_name 'revoked_at'
);
ALTER FOREIGN TABLE oauth_access_grants ALTER COLUMN scopes OPTIONS (
    column_name 'scopes'
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
-- Name: oauth_access_grants_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE oauth_access_grants_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'oauth_access_grants_id_seq_view'
);
ALTER FOREIGN TABLE oauth_access_grants_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: oauth_access_tokens; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE oauth_access_tokens (
    id integer DEFAULT oauth_access_tokens_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE oauth_access_tokens ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE oauth_access_tokens ALTER COLUMN resource_owner_id OPTIONS (
    column_name 'resource_owner_id'
);
ALTER FOREIGN TABLE oauth_access_tokens ALTER COLUMN application_id OPTIONS (
    column_name 'application_id'
);
ALTER FOREIGN TABLE oauth_access_tokens ALTER COLUMN token OPTIONS (
    column_name 'token'
);
ALTER FOREIGN TABLE oauth_access_tokens ALTER COLUMN refresh_token OPTIONS (
    column_name 'refresh_token'
);
ALTER FOREIGN TABLE oauth_access_tokens ALTER COLUMN expires_in OPTIONS (
    column_name 'expires_in'
);
ALTER FOREIGN TABLE oauth_access_tokens ALTER COLUMN revoked_at OPTIONS (
    column_name 'revoked_at'
);
ALTER FOREIGN TABLE oauth_access_tokens ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE oauth_access_tokens ALTER COLUMN scopes OPTIONS (
    column_name 'scopes'
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
-- Name: oauth_access_tokens_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE oauth_access_tokens_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'oauth_access_tokens_id_seq_view'
);
ALTER FOREIGN TABLE oauth_access_tokens_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: oauth_applications; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE oauth_applications (
    id integer DEFAULT oauth_applications_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE oauth_applications ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE oauth_applications ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE oauth_applications ALTER COLUMN uid OPTIONS (
    column_name 'uid'
);
ALTER FOREIGN TABLE oauth_applications ALTER COLUMN secret OPTIONS (
    column_name 'secret'
);
ALTER FOREIGN TABLE oauth_applications ALTER COLUMN redirect_uri OPTIONS (
    column_name 'redirect_uri'
);
ALTER FOREIGN TABLE oauth_applications ALTER COLUMN scopes OPTIONS (
    column_name 'scopes'
);
ALTER FOREIGN TABLE oauth_applications ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE oauth_applications ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: oauth_applications_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE oauth_applications_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'oauth_applications_id_seq_view'
);
ALTER FOREIGN TABLE oauth_applications_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: oauth_nonces; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE oauth_nonces (
    id integer DEFAULT oauth_nonces_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE oauth_nonces ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE oauth_nonces ALTER COLUMN nonce OPTIONS (
    column_name 'nonce'
);
ALTER FOREIGN TABLE oauth_nonces ALTER COLUMN "timestamp" OPTIONS (
    column_name 'timestamp'
);
ALTER FOREIGN TABLE oauth_nonces ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE oauth_nonces ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: oauth_nonces_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE oauth_nonces_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'oauth_nonces_id_seq_view'
);
ALTER FOREIGN TABLE oauth_nonces_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: old_edits_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE old_edits_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'old_edits_id_seq_view'
);
ALTER FOREIGN TABLE old_edits_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: org_stats_by_sectors; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE org_stats_by_sectors (
    id integer DEFAULT org_stats_by_sectors_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE org_stats_by_sectors ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE org_stats_by_sectors ALTER COLUMN org_type OPTIONS (
    column_name 'org_type'
);
ALTER FOREIGN TABLE org_stats_by_sectors ALTER COLUMN organization_count OPTIONS (
    column_name 'organization_count'
);
ALTER FOREIGN TABLE org_stats_by_sectors ALTER COLUMN commits_count OPTIONS (
    column_name 'commits_count'
);
ALTER FOREIGN TABLE org_stats_by_sectors ALTER COLUMN affiliate_count OPTIONS (
    column_name 'affiliate_count'
);
ALTER FOREIGN TABLE org_stats_by_sectors ALTER COLUMN average_commits OPTIONS (
    column_name 'average_commits'
);
ALTER FOREIGN TABLE org_stats_by_sectors ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE org_stats_by_sectors ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: org_stats_by_sectors_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE org_stats_by_sectors_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'org_stats_by_sectors_id_seq_view'
);
ALTER FOREIGN TABLE org_stats_by_sectors_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: org_thirty_day_activities; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE org_thirty_day_activities (
    id integer DEFAULT org_thirty_day_activities_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE org_thirty_day_activities ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE org_thirty_day_activities ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE org_thirty_day_activities ALTER COLUMN organization_id OPTIONS (
    column_name 'organization_id'
);
ALTER FOREIGN TABLE org_thirty_day_activities ALTER COLUMN vanity_url OPTIONS (
    column_name 'vanity_url'
);
ALTER FOREIGN TABLE org_thirty_day_activities ALTER COLUMN org_type OPTIONS (
    column_name 'org_type'
);
ALTER FOREIGN TABLE org_thirty_day_activities ALTER COLUMN project_count OPTIONS (
    column_name 'project_count'
);
ALTER FOREIGN TABLE org_thirty_day_activities ALTER COLUMN affiliate_count OPTIONS (
    column_name 'affiliate_count'
);
ALTER FOREIGN TABLE org_thirty_day_activities ALTER COLUMN thirty_day_commit_count OPTIONS (
    column_name 'thirty_day_commit_count'
);
ALTER FOREIGN TABLE org_thirty_day_activities ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE org_thirty_day_activities ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: org_thirty_day_activities_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE org_thirty_day_activities_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'org_thirty_day_activities_id_seq_view'
);
ALTER FOREIGN TABLE org_thirty_day_activities_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: organizations; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE organizations (
    id integer DEFAULT organizations_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE organizations ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE organizations ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE organizations ALTER COLUMN vanity_url OPTIONS (
    column_name 'vanity_url'
);
ALTER FOREIGN TABLE organizations ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE organizations ALTER COLUMN org_type OPTIONS (
    column_name 'org_type'
);
ALTER FOREIGN TABLE organizations ALTER COLUMN homepage_url OPTIONS (
    column_name 'homepage_url'
);
ALTER FOREIGN TABLE organizations ALTER COLUMN logo_id OPTIONS (
    column_name 'logo_id'
);
ALTER FOREIGN TABLE organizations ALTER COLUMN vector OPTIONS (
    column_name 'vector'
);
ALTER FOREIGN TABLE organizations ALTER COLUMN popularity_factor OPTIONS (
    column_name 'popularity_factor'
);
ALTER FOREIGN TABLE organizations ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
);
ALTER FOREIGN TABLE organizations ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE organizations ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE organizations ALTER COLUMN projects_count OPTIONS (
    column_name 'projects_count'
);
ALTER FOREIGN TABLE organizations ALTER COLUMN thirty_day_activity_id OPTIONS (
    column_name 'thirty_day_activity_id'
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
-- Name: organizations_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE organizations_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'organizations_id_seq_view'
);
ALTER FOREIGN TABLE organizations_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: pages_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE pages_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'pages_id_seq_view'
);
ALTER FOREIGN TABLE pages_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: people; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE people (
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
ALTER FOREIGN TABLE people ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE people ALTER COLUMN effective_name OPTIONS (
    column_name 'effective_name'
);
ALTER FOREIGN TABLE people ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE people ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE people ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE people ALTER COLUMN name_fact_id OPTIONS (
    column_name 'name_fact_id'
);
ALTER FOREIGN TABLE people ALTER COLUMN kudo_position OPTIONS (
    column_name 'kudo_position'
);
ALTER FOREIGN TABLE people ALTER COLUMN kudo_score OPTIONS (
    column_name 'kudo_score'
);
ALTER FOREIGN TABLE people ALTER COLUMN kudo_rank OPTIONS (
    column_name 'kudo_rank'
);
ALTER FOREIGN TABLE people ALTER COLUMN vector OPTIONS (
    column_name 'vector'
);
ALTER FOREIGN TABLE people ALTER COLUMN popularity_factor OPTIONS (
    column_name 'popularity_factor'
);


--
-- Name: people_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE people_view (
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
ALTER FOREIGN TABLE people_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE people_view ALTER COLUMN effective_name OPTIONS (
    column_name 'effective_name'
);
ALTER FOREIGN TABLE people_view ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE people_view ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE people_view ALTER COLUMN name_id OPTIONS (
    column_name 'name_id'
);
ALTER FOREIGN TABLE people_view ALTER COLUMN name_fact_id OPTIONS (
    column_name 'name_fact_id'
);
ALTER FOREIGN TABLE people_view ALTER COLUMN kudo_position OPTIONS (
    column_name 'kudo_position'
);
ALTER FOREIGN TABLE people_view ALTER COLUMN kudo_score OPTIONS (
    column_name 'kudo_score'
);
ALTER FOREIGN TABLE people_view ALTER COLUMN kudo_rank OPTIONS (
    column_name 'kudo_rank'
);


--
-- Name: permissions; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE permissions (
    id integer DEFAULT permissions_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE permissions ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE permissions ALTER COLUMN target_id OPTIONS (
    column_name 'target_id'
);
ALTER FOREIGN TABLE permissions ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE permissions ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE permissions ALTER COLUMN remainder OPTIONS (
    column_name 'remainder'
);
ALTER FOREIGN TABLE permissions ALTER COLUMN downloads OPTIONS (
    column_name 'downloads'
);
ALTER FOREIGN TABLE permissions ALTER COLUMN target_type OPTIONS (
    column_name 'target_type'
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
-- Name: permissions_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE permissions_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'permissions_id_seq_view'
);
ALTER FOREIGN TABLE permissions_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: pg_ts_cfg; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE pg_ts_cfg (
    ts_name text NOT NULL,
    prs_name text NOT NULL,
    locale text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'pg_ts_cfg'
);
ALTER FOREIGN TABLE pg_ts_cfg ALTER COLUMN ts_name OPTIONS (
    column_name 'ts_name'
);
ALTER FOREIGN TABLE pg_ts_cfg ALTER COLUMN prs_name OPTIONS (
    column_name 'prs_name'
);
ALTER FOREIGN TABLE pg_ts_cfg ALTER COLUMN locale OPTIONS (
    column_name 'locale'
);


--
-- Name: pg_ts_cfgmap; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE pg_ts_cfgmap (
    ts_name text NOT NULL,
    tok_alias text NOT NULL,
    dict_name text[]
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'pg_ts_cfgmap'
);
ALTER FOREIGN TABLE pg_ts_cfgmap ALTER COLUMN ts_name OPTIONS (
    column_name 'ts_name'
);
ALTER FOREIGN TABLE pg_ts_cfgmap ALTER COLUMN tok_alias OPTIONS (
    column_name 'tok_alias'
);
ALTER FOREIGN TABLE pg_ts_cfgmap ALTER COLUMN dict_name OPTIONS (
    column_name 'dict_name'
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
-- Name: positions_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE positions_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'positions_id_seq_view'
);
ALTER FOREIGN TABLE positions_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: posts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE posts (
    id integer DEFAULT posts_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE posts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE posts ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE posts ALTER COLUMN topic_id OPTIONS (
    column_name 'topic_id'
);
ALTER FOREIGN TABLE posts ALTER COLUMN body OPTIONS (
    column_name 'body'
);
ALTER FOREIGN TABLE posts ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE posts ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE posts ALTER COLUMN notified_at OPTIONS (
    column_name 'notified_at'
);
ALTER FOREIGN TABLE posts ALTER COLUMN vector OPTIONS (
    column_name 'vector'
);
ALTER FOREIGN TABLE posts ALTER COLUMN popularity_factor OPTIONS (
    column_name 'popularity_factor'
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
-- Name: posts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE posts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'posts_id_seq_view'
);
ALTER FOREIGN TABLE posts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: profiles; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE profiles (
    id integer DEFAULT profiles_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE profiles ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE profiles ALTER COLUMN job_id OPTIONS (
    column_name 'job_id'
);
ALTER FOREIGN TABLE profiles ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE profiles ALTER COLUMN count OPTIONS (
    column_name 'count'
);
ALTER FOREIGN TABLE profiles ALTER COLUMN "time" OPTIONS (
    column_name 'time'
);
ALTER FOREIGN TABLE profiles ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
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
-- Name: profiles_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE profiles_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'profiles_id_seq_view'
);
ALTER FOREIGN TABLE profiles_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: project_badges; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_badges (
    id integer DEFAULT project_badges_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE project_badges ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE project_badges ALTER COLUMN identifier OPTIONS (
    column_name 'identifier'
);
ALTER FOREIGN TABLE project_badges ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE project_badges ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE project_badges ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE project_badges ALTER COLUMN status OPTIONS (
    column_name 'status'
);
ALTER FOREIGN TABLE project_badges ALTER COLUMN enlistment_id OPTIONS (
    column_name 'enlistment_id'
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
-- Name: project_badges_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_badges_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_badges_id_seq_view'
);
ALTER FOREIGN TABLE project_badges_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: project_counts_by_quarter_and_language; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_counts_by_quarter_and_language (
    language_id integer,
    quarter timestamp without time zone,
    project_count bigint
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_counts_by_quarter_and_language'
);
ALTER FOREIGN TABLE project_counts_by_quarter_and_language ALTER COLUMN language_id OPTIONS (
    column_name 'language_id'
);
ALTER FOREIGN TABLE project_counts_by_quarter_and_language ALTER COLUMN quarter OPTIONS (
    column_name 'quarter'
);
ALTER FOREIGN TABLE project_counts_by_quarter_and_language ALTER COLUMN project_count OPTIONS (
    column_name 'project_count'
);


--
-- Name: project_events; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_events (
    id integer DEFAULT project_events_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE project_events ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE project_events ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE project_events ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE project_events ALTER COLUMN key OPTIONS (
    column_name 'key'
);
ALTER FOREIGN TABLE project_events ALTER COLUMN data OPTIONS (
    column_name 'data'
);
ALTER FOREIGN TABLE project_events ALTER COLUMN "time" OPTIONS (
    column_name 'time'
);
ALTER FOREIGN TABLE project_events ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
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
-- Name: project_events_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_events_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_events_id_seq_view'
);
ALTER FOREIGN TABLE project_events_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: project_experiences; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_experiences (
    id integer DEFAULT project_experiences_id_seq_view() NOT NULL,
    position_id integer NOT NULL,
    project_id integer NOT NULL,
    promote boolean DEFAULT false NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_experiences'
);
ALTER FOREIGN TABLE project_experiences ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE project_experiences ALTER COLUMN position_id OPTIONS (
    column_name 'position_id'
);
ALTER FOREIGN TABLE project_experiences ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE project_experiences ALTER COLUMN promote OPTIONS (
    column_name 'promote'
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
-- Name: project_experiences_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_experiences_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_experiences_id_seq_view'
);
ALTER FOREIGN TABLE project_experiences_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: project_gestalts_tmp; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_gestalts_tmp (
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
ALTER FOREIGN TABLE project_gestalts_tmp ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE project_gestalts_tmp ALTER COLUMN date OPTIONS (
    column_name 'date'
);
ALTER FOREIGN TABLE project_gestalts_tmp ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE project_gestalts_tmp ALTER COLUMN gestalt_id OPTIONS (
    column_name 'gestalt_id'
);


--
-- Name: project_licenses; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_licenses (
    id integer DEFAULT project_licenses_id_seq_view() NOT NULL,
    project_id integer,
    license_id integer,
    deleted boolean DEFAULT false
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_licenses'
);
ALTER FOREIGN TABLE project_licenses ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE project_licenses ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE project_licenses ALTER COLUMN license_id OPTIONS (
    column_name 'license_id'
);
ALTER FOREIGN TABLE project_licenses ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
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
-- Name: project_licenses_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_licenses_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_licenses_id_seq_view'
);
ALTER FOREIGN TABLE project_licenses_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: project_reports; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_reports (
    id integer DEFAULT project_reports_id_seq_view() NOT NULL,
    project_id integer NOT NULL,
    report_id integer NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_reports'
);
ALTER FOREIGN TABLE project_reports ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE project_reports ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE project_reports ALTER COLUMN report_id OPTIONS (
    column_name 'report_id'
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
-- Name: project_reports_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_reports_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_reports_id_seq_view'
);
ALTER FOREIGN TABLE project_reports_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: project_security_sets; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_security_sets (
    id integer DEFAULT project_security_sets_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE project_security_sets ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE project_security_sets ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE project_security_sets ALTER COLUMN uuid OPTIONS (
    column_name 'uuid'
);
ALTER FOREIGN TABLE project_security_sets ALTER COLUMN etag OPTIONS (
    column_name 'etag'
);
ALTER FOREIGN TABLE project_security_sets ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE project_security_sets ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: project_security_sets_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_security_sets_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_security_sets_id_seq_view'
);
ALTER FOREIGN TABLE project_security_sets_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: project_vulnerability_reports; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_vulnerability_reports (
    id integer DEFAULT project_vulnerability_reports_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE project_vulnerability_reports ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE project_vulnerability_reports ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE project_vulnerability_reports ALTER COLUMN etag OPTIONS (
    column_name 'etag'
);
ALTER FOREIGN TABLE project_vulnerability_reports ALTER COLUMN vulnerability_score OPTIONS (
    column_name 'vulnerability_score'
);
ALTER FOREIGN TABLE project_vulnerability_reports ALTER COLUMN security_score OPTIONS (
    column_name 'security_score'
);
ALTER FOREIGN TABLE project_vulnerability_reports ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE project_vulnerability_reports ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: project_vulnerability_reports_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE project_vulnerability_reports_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'project_vulnerability_reports_id_seq_view'
);
ALTER FOREIGN TABLE project_vulnerability_reports_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: projects_by_month; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE projects_by_month (
    month timestamp without time zone,
    project_count bigint
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'projects_by_month'
);
ALTER FOREIGN TABLE projects_by_month ALTER COLUMN month OPTIONS (
    column_name 'month'
);
ALTER FOREIGN TABLE projects_by_month ALTER COLUMN project_count OPTIONS (
    column_name 'project_count'
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
-- Name: projects_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE projects_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'projects_id_seq_view'
);
ALTER FOREIGN TABLE projects_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: ratings; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE ratings (
    id integer DEFAULT ratings_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE ratings ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE ratings ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE ratings ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE ratings ALTER COLUMN score OPTIONS (
    column_name 'score'
);
ALTER FOREIGN TABLE ratings ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE ratings ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: ratings_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE ratings_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'ratings_id_seq_view'
);
ALTER FOREIGN TABLE ratings_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: recently_active_accounts_cache; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE recently_active_accounts_cache (
    id integer DEFAULT recently_active_accounts_cache_id_seq_view() NOT NULL,
    accounts text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'recently_active_accounts_cache'
);
ALTER FOREIGN TABLE recently_active_accounts_cache ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE recently_active_accounts_cache ALTER COLUMN accounts OPTIONS (
    column_name 'accounts'
);
ALTER FOREIGN TABLE recently_active_accounts_cache ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE recently_active_accounts_cache ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: recently_active_accounts_cache_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE recently_active_accounts_cache_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'recently_active_accounts_cache_id_seq_view'
);
ALTER FOREIGN TABLE recently_active_accounts_cache_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: recommend_entries; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE recommend_entries (
    id integer DEFAULT recommend_entries_id_seq_view() NOT NULL,
    project_id integer,
    project_id_recommends integer,
    weight double precision
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'recommend_entries'
);
ALTER FOREIGN TABLE recommend_entries ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE recommend_entries ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE recommend_entries ALTER COLUMN project_id_recommends OPTIONS (
    column_name 'project_id_recommends'
);
ALTER FOREIGN TABLE recommend_entries ALTER COLUMN weight OPTIONS (
    column_name 'weight'
);


--
-- Name: recommend_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE recommend_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommend_entries_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE recommend_entries_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'recommend_entries_id_seq_view'
);
ALTER FOREIGN TABLE recommend_entries_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: recommendations; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE recommendations (
    id integer DEFAULT recommendations_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE recommendations ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE recommendations ALTER COLUMN invitor_id OPTIONS (
    column_name 'invitor_id'
);
ALTER FOREIGN TABLE recommendations ALTER COLUMN invitee_id OPTIONS (
    column_name 'invitee_id'
);
ALTER FOREIGN TABLE recommendations ALTER COLUMN invitee_email OPTIONS (
    column_name 'invitee_email'
);
ALTER FOREIGN TABLE recommendations ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE recommendations ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE recommendations ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE recommendations ALTER COLUMN activation_code OPTIONS (
    column_name 'activation_code'
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
-- Name: recommendations_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE recommendations_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'recommendations_id_seq_view'
);
ALTER FOREIGN TABLE recommendations_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: releases; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE releases (
    id integer DEFAULT releases_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE releases ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE releases ALTER COLUMN kb_release_id OPTIONS (
    column_name 'kb_release_id'
);
ALTER FOREIGN TABLE releases ALTER COLUMN released_on OPTIONS (
    column_name 'released_on'
);
ALTER FOREIGN TABLE releases ALTER COLUMN version OPTIONS (
    column_name 'version'
);
ALTER FOREIGN TABLE releases ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE releases ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE releases ALTER COLUMN project_security_set_id OPTIONS (
    column_name 'project_security_set_id'
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
-- Name: releases_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE releases_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'releases_id_seq_view'
);
ALTER FOREIGN TABLE releases_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: releases_vulnerabilities; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE releases_vulnerabilities (
    release_id integer NOT NULL,
    vulnerability_id integer NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'releases_vulnerabilities'
);
ALTER FOREIGN TABLE releases_vulnerabilities ALTER COLUMN release_id OPTIONS (
    column_name 'release_id'
);
ALTER FOREIGN TABLE releases_vulnerabilities ALTER COLUMN vulnerability_id OPTIONS (
    column_name 'vulnerability_id'
);


--
-- Name: reports; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE reports (
    id integer DEFAULT reports_id_seq_view() NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'reports'
);
ALTER FOREIGN TABLE reports ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE reports ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE reports ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE reports ALTER COLUMN title OPTIONS (
    column_name 'title'
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
-- Name: reports_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE reports_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'reports_id_seq_view'
);
ALTER FOREIGN TABLE reports_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: repositories; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE repositories (
    id integer DEFAULT repositories_id_seq_view() NOT NULL,
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
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'repositories'
);
ALTER FOREIGN TABLE repositories ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE repositories ALTER COLUMN url OPTIONS (
    column_name 'url'
);
ALTER FOREIGN TABLE repositories ALTER COLUMN forge_id OPTIONS (
    column_name 'forge_id'
);
ALTER FOREIGN TABLE repositories ALTER COLUMN username OPTIONS (
    column_name 'username'
);
ALTER FOREIGN TABLE repositories ALTER COLUMN password OPTIONS (
    column_name 'password'
);
ALTER FOREIGN TABLE repositories ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE repositories ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE repositories ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE repositories ALTER COLUMN update_interval OPTIONS (
    column_name 'update_interval'
);
ALTER FOREIGN TABLE repositories ALTER COLUMN name_at_forge OPTIONS (
    column_name 'name_at_forge'
);
ALTER FOREIGN TABLE repositories ALTER COLUMN owner_at_forge OPTIONS (
    column_name 'owner_at_forge'
);
ALTER FOREIGN TABLE repositories ALTER COLUMN best_repository_directory_id OPTIONS (
    column_name 'best_repository_directory_id'
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
-- Name: repositories_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE repositories_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'repositories_id_seq_view'
);
ALTER FOREIGN TABLE repositories_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: repository_directories; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE repository_directories (
    id integer DEFAULT repository_directories_id_seq_view() NOT NULL,
    code_location_id integer,
    repository_id integer,
    fetched_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'repository_directories'
);
ALTER FOREIGN TABLE repository_directories ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE repository_directories ALTER COLUMN code_location_id OPTIONS (
    column_name 'code_location_id'
);
ALTER FOREIGN TABLE repository_directories ALTER COLUMN repository_id OPTIONS (
    column_name 'repository_id'
);
ALTER FOREIGN TABLE repository_directories ALTER COLUMN fetched_at OPTIONS (
    column_name 'fetched_at'
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
-- Name: repository_directories_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE repository_directories_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'repository_directories_id_seq_view'
);
ALTER FOREIGN TABLE repository_directories_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: repository_tags; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE repository_tags (
    id integer DEFAULT repository_tags_id_seq_view() NOT NULL,
    repository_id integer,
    name text,
    commit_sha1 text,
    message text,
    "timestamp" timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'repository_tags'
);
ALTER FOREIGN TABLE repository_tags ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE repository_tags ALTER COLUMN repository_id OPTIONS (
    column_name 'repository_id'
);
ALTER FOREIGN TABLE repository_tags ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE repository_tags ALTER COLUMN commit_sha1 OPTIONS (
    column_name 'commit_sha1'
);
ALTER FOREIGN TABLE repository_tags ALTER COLUMN message OPTIONS (
    column_name 'message'
);
ALTER FOREIGN TABLE repository_tags ALTER COLUMN "timestamp" OPTIONS (
    column_name 'timestamp'
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
-- Name: repository_tags_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE repository_tags_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'repository_tags_id_seq_view'
);
ALTER FOREIGN TABLE repository_tags_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: reverification_trackers; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE reverification_trackers (
    id integer DEFAULT reverification_trackers_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE reverification_trackers ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE reverification_trackers ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE reverification_trackers ALTER COLUMN message_id OPTIONS (
    column_name 'message_id'
);
ALTER FOREIGN TABLE reverification_trackers ALTER COLUMN phase OPTIONS (
    column_name 'phase'
);
ALTER FOREIGN TABLE reverification_trackers ALTER COLUMN status OPTIONS (
    column_name 'status'
);
ALTER FOREIGN TABLE reverification_trackers ALTER COLUMN feedback OPTIONS (
    column_name 'feedback'
);
ALTER FOREIGN TABLE reverification_trackers ALTER COLUMN attempts OPTIONS (
    column_name 'attempts'
);
ALTER FOREIGN TABLE reverification_trackers ALTER COLUMN sent_at OPTIONS (
    column_name 'sent_at'
);
ALTER FOREIGN TABLE reverification_trackers ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE reverification_trackers ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: reverification_trackers_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE reverification_trackers_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'reverification_trackers_id_seq_view'
);
ALTER FOREIGN TABLE reverification_trackers_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: reviews; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE reviews (
    id integer DEFAULT reviews_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE reviews ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE reviews ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE reviews ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE reviews ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE reviews ALTER COLUMN comment OPTIONS (
    column_name 'comment'
);
ALTER FOREIGN TABLE reviews ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE reviews ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE reviews ALTER COLUMN helpful_score OPTIONS (
    column_name 'helpful_score'
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
-- Name: reviews_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE reviews_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'reviews_id_seq_view'
);
ALTER FOREIGN TABLE reviews_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: robins_contributions_test; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE robins_contributions_test (
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
ALTER FOREIGN TABLE robins_contributions_test ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE robins_contributions_test ALTER COLUMN person_id OPTIONS (
    column_name 'person_id'
);
ALTER FOREIGN TABLE robins_contributions_test ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE robins_contributions_test ALTER COLUMN name_fact_id OPTIONS (
    column_name 'name_fact_id'
);
ALTER FOREIGN TABLE robins_contributions_test ALTER COLUMN position_id OPTIONS (
    column_name 'position_id'
);


--
-- Name: rss_articles; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE rss_articles (
    id integer DEFAULT rss_articles_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE rss_articles ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE rss_articles ALTER COLUMN rss_feed_id OPTIONS (
    column_name 'rss_feed_id'
);
ALTER FOREIGN TABLE rss_articles ALTER COLUMN guid OPTIONS (
    column_name 'guid'
);
ALTER FOREIGN TABLE rss_articles ALTER COLUMN "time" OPTIONS (
    column_name 'time'
);
ALTER FOREIGN TABLE rss_articles ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE rss_articles ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE rss_articles ALTER COLUMN author OPTIONS (
    column_name 'author'
);
ALTER FOREIGN TABLE rss_articles ALTER COLUMN link OPTIONS (
    column_name 'link'
);


--
-- Name: rss_articles_2; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE rss_articles_2 (
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
ALTER FOREIGN TABLE rss_articles_2 ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE rss_articles_2 ALTER COLUMN rss_feed_id OPTIONS (
    column_name 'rss_feed_id'
);
ALTER FOREIGN TABLE rss_articles_2 ALTER COLUMN guid OPTIONS (
    column_name 'guid'
);
ALTER FOREIGN TABLE rss_articles_2 ALTER COLUMN "time" OPTIONS (
    column_name 'time'
);
ALTER FOREIGN TABLE rss_articles_2 ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE rss_articles_2 ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE rss_articles_2 ALTER COLUMN author OPTIONS (
    column_name 'author'
);
ALTER FOREIGN TABLE rss_articles_2 ALTER COLUMN link OPTIONS (
    column_name 'link'
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
-- Name: rss_articles_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE rss_articles_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'rss_articles_id_seq_view'
);
ALTER FOREIGN TABLE rss_articles_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: rss_feeds; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE rss_feeds (
    id integer DEFAULT rss_feeds_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE rss_feeds ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE rss_feeds ALTER COLUMN url OPTIONS (
    column_name 'url'
);
ALTER FOREIGN TABLE rss_feeds ALTER COLUMN last_fetch OPTIONS (
    column_name 'last_fetch'
);
ALTER FOREIGN TABLE rss_feeds ALTER COLUMN next_fetch OPTIONS (
    column_name 'next_fetch'
);
ALTER FOREIGN TABLE rss_feeds ALTER COLUMN error OPTIONS (
    column_name 'error'
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
-- Name: rss_feeds_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE rss_feeds_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'rss_feeds_id_seq_view'
);
ALTER FOREIGN TABLE rss_feeds_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: rss_subscriptions; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE rss_subscriptions (
    id integer DEFAULT rss_subscriptions_id_seq_view() NOT NULL,
    project_id integer,
    rss_feed_id integer,
    deleted boolean DEFAULT false
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'rss_subscriptions'
);
ALTER FOREIGN TABLE rss_subscriptions ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE rss_subscriptions ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE rss_subscriptions ALTER COLUMN rss_feed_id OPTIONS (
    column_name 'rss_feed_id'
);
ALTER FOREIGN TABLE rss_subscriptions ALTER COLUMN deleted OPTIONS (
    column_name 'deleted'
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
-- Name: rss_subscriptions_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE rss_subscriptions_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'rss_subscriptions_id_seq_view'
);
ALTER FOREIGN TABLE rss_subscriptions_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sessions; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE sessions (
    id integer DEFAULT sessions_id_seq_view() NOT NULL,
    session_id character varying(255),
    data text,
    updated_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'sessions'
);
ALTER FOREIGN TABLE sessions ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE sessions ALTER COLUMN session_id OPTIONS (
    column_name 'session_id'
);
ALTER FOREIGN TABLE sessions ALTER COLUMN data OPTIONS (
    column_name 'data'
);
ALTER FOREIGN TABLE sessions ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: sessions_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE sessions_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'sessions_id_seq_view'
);
ALTER FOREIGN TABLE sessions_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: settings; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE settings (
    id integer DEFAULT settings_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE settings ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE settings ALTER COLUMN key OPTIONS (
    column_name 'key'
);
ALTER FOREIGN TABLE settings ALTER COLUMN value OPTIONS (
    column_name 'value'
);
ALTER FOREIGN TABLE settings ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE settings ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: settings_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE settings_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'settings_id_seq_view'
);
ALTER FOREIGN TABLE settings_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: sf_vhosted; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE sf_vhosted (
    domain text NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'sf_vhosted'
);
ALTER FOREIGN TABLE sf_vhosted ALTER COLUMN domain OPTIONS (
    column_name 'domain'
);


--
-- Name: sfprojects; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE sfprojects (
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
ALTER FOREIGN TABLE sfprojects ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE sfprojects ALTER COLUMN hosted OPTIONS (
    column_name 'hosted'
);
ALTER FOREIGN TABLE sfprojects ALTER COLUMN vhosted OPTIONS (
    column_name 'vhosted'
);
ALTER FOREIGN TABLE sfprojects ALTER COLUMN code OPTIONS (
    column_name 'code'
);
ALTER FOREIGN TABLE sfprojects ALTER COLUMN downloads OPTIONS (
    column_name 'downloads'
);
ALTER FOREIGN TABLE sfprojects ALTER COLUMN downloads_vhosted OPTIONS (
    column_name 'downloads_vhosted'
);


--
-- Name: size_facts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE size_facts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'size_facts_id_seq_view'
);
ALTER FOREIGN TABLE size_facts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: slave_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE slave_logs (
    id integer NOT NULL,
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

CREATE SEQUENCE slave_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slave_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE slave_logs_id_seq OWNED BY slave_logs.id;


--
-- Name: slave_logs_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW slave_logs_id_seq_view AS
 SELECT (nextval('slave_logs_id_seq'::regclass))::integer AS id;


--
-- Name: slaves; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE slaves (
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

CREATE SEQUENCE slave_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slave_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE slave_permissions_id_seq OWNED BY slaves.id;


--
-- Name: slave_permissions_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW slave_permissions_id_seq_view AS
 SELECT (nextval('slave_permissions_id_seq'::regclass))::integer AS id;


--
-- Name: sloc_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sloc_metrics (
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

CREATE SEQUENCE sloc_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sloc_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sloc_metrics_id_seq OWNED BY sloc_metrics.id;


--
-- Name: sloc_metrics_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW sloc_metrics_id_seq_view AS
 SELECT (nextval('sloc_metrics_id_seq'::regclass))::integer AS id;


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
-- Name: sloc_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sloc_sets_id_seq OWNED BY sloc_sets.id;


--
-- Name: sloc_sets_id_seq_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW sloc_sets_id_seq_view AS
 SELECT (nextval('sloc_sets_id_seq'::regclass))::integer AS id;


--
-- Name: stack_entries; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE stack_entries (
    id integer DEFAULT stack_entries_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE stack_entries ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE stack_entries ALTER COLUMN stack_id OPTIONS (
    column_name 'stack_id'
);
ALTER FOREIGN TABLE stack_entries ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE stack_entries ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE stack_entries ALTER COLUMN deleted_at OPTIONS (
    column_name 'deleted_at'
);
ALTER FOREIGN TABLE stack_entries ALTER COLUMN note OPTIONS (
    column_name 'note'
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
-- Name: stack_entries_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE stack_entries_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'stack_entries_id_seq_view'
);
ALTER FOREIGN TABLE stack_entries_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: stack_ignores; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE stack_ignores (
    id integer DEFAULT stack_ignores_id_seq_view() NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    stack_id integer NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'stack_ignores'
);
ALTER FOREIGN TABLE stack_ignores ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE stack_ignores ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE stack_ignores ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE stack_ignores ALTER COLUMN stack_id OPTIONS (
    column_name 'stack_id'
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
-- Name: stack_ignores_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE stack_ignores_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'stack_ignores_id_seq_view'
);
ALTER FOREIGN TABLE stack_ignores_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: stacks; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE stacks (
    id integer DEFAULT stacks_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE stacks ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE stacks ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE stacks ALTER COLUMN session_id OPTIONS (
    column_name 'session_id'
);
ALTER FOREIGN TABLE stacks ALTER COLUMN project_count OPTIONS (
    column_name 'project_count'
);
ALTER FOREIGN TABLE stacks ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE stacks ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE stacks ALTER COLUMN description OPTIONS (
    column_name 'description'
);
ALTER FOREIGN TABLE stacks ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE stacks ALTER COLUMN deleted_at OPTIONS (
    column_name 'deleted_at'
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
-- Name: stacks_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE stacks_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'stacks_id_seq_view'
);
ALTER FOREIGN TABLE stacks_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: successful_accounts; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE successful_accounts (
    id integer DEFAULT successful_accounts_id_seq_view() NOT NULL,
    account_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'successful_accounts'
);
ALTER FOREIGN TABLE successful_accounts ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE successful_accounts ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
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
-- Name: successful_accounts_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE successful_accounts_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'successful_accounts_id_seq_view'
);
ALTER FOREIGN TABLE successful_accounts_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: taggings; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE taggings (
    id integer DEFAULT taggings_id_seq_view() NOT NULL,
    tag_id integer,
    taggable_id integer,
    taggable_type character varying(255)
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'taggings'
);
ALTER FOREIGN TABLE taggings ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE taggings ALTER COLUMN tag_id OPTIONS (
    column_name 'tag_id'
);
ALTER FOREIGN TABLE taggings ALTER COLUMN taggable_id OPTIONS (
    column_name 'taggable_id'
);
ALTER FOREIGN TABLE taggings ALTER COLUMN taggable_type OPTIONS (
    column_name 'taggable_type'
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
-- Name: taggings_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE taggings_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'taggings_id_seq_view'
);
ALTER FOREIGN TABLE taggings_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: tags; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE tags (
    id integer DEFAULT tags_id_seq_view() NOT NULL,
    name text NOT NULL,
    taggings_count integer DEFAULT 0 NOT NULL,
    weight double precision DEFAULT 1.0 NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'tags'
);
ALTER FOREIGN TABLE tags ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE tags ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE tags ALTER COLUMN taggings_count OPTIONS (
    column_name 'taggings_count'
);
ALTER FOREIGN TABLE tags ALTER COLUMN weight OPTIONS (
    column_name 'weight'
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
-- Name: tags_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE tags_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'tags_id_seq_view'
);
ALTER FOREIGN TABLE tags_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: thirty_day_summaries; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE thirty_day_summaries (
    id integer DEFAULT thirty_day_summaries_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE thirty_day_summaries ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE thirty_day_summaries ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
);
ALTER FOREIGN TABLE thirty_day_summaries ALTER COLUMN committer_count OPTIONS (
    column_name 'committer_count'
);
ALTER FOREIGN TABLE thirty_day_summaries ALTER COLUMN commit_count OPTIONS (
    column_name 'commit_count'
);
ALTER FOREIGN TABLE thirty_day_summaries ALTER COLUMN files_modified OPTIONS (
    column_name 'files_modified'
);
ALTER FOREIGN TABLE thirty_day_summaries ALTER COLUMN lines_added OPTIONS (
    column_name 'lines_added'
);
ALTER FOREIGN TABLE thirty_day_summaries ALTER COLUMN lines_removed OPTIONS (
    column_name 'lines_removed'
);
ALTER FOREIGN TABLE thirty_day_summaries ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
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
-- Name: thirty_day_summaries_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE thirty_day_summaries_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'thirty_day_summaries_id_seq_view'
);
ALTER FOREIGN TABLE thirty_day_summaries_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: tools; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE tools (
    id integer DEFAULT tools_id_seq_view() NOT NULL,
    name text NOT NULL,
    description text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'tools'
);
ALTER FOREIGN TABLE tools ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE tools ALTER COLUMN name OPTIONS (
    column_name 'name'
);
ALTER FOREIGN TABLE tools ALTER COLUMN description OPTIONS (
    column_name 'description'
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
-- Name: tools_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE tools_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'tools_id_seq_view'
);
ALTER FOREIGN TABLE tools_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: topics; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE topics (
    id integer DEFAULT topics_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE topics ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE topics ALTER COLUMN forum_id OPTIONS (
    column_name 'forum_id'
);
ALTER FOREIGN TABLE topics ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE topics ALTER COLUMN title OPTIONS (
    column_name 'title'
);
ALTER FOREIGN TABLE topics ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE topics ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE topics ALTER COLUMN hits OPTIONS (
    column_name 'hits'
);
ALTER FOREIGN TABLE topics ALTER COLUMN sticky OPTIONS (
    column_name 'sticky'
);
ALTER FOREIGN TABLE topics ALTER COLUMN posts_count OPTIONS (
    column_name 'posts_count'
);
ALTER FOREIGN TABLE topics ALTER COLUMN replied_at OPTIONS (
    column_name 'replied_at'
);
ALTER FOREIGN TABLE topics ALTER COLUMN closed OPTIONS (
    column_name 'closed'
);
ALTER FOREIGN TABLE topics ALTER COLUMN replied_by OPTIONS (
    column_name 'replied_by'
);
ALTER FOREIGN TABLE topics ALTER COLUMN last_post_id OPTIONS (
    column_name 'last_post_id'
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
-- Name: topics_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE topics_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'topics_id_seq_view'
);
ALTER FOREIGN TABLE topics_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: verifications; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE verifications (
    id integer DEFAULT verifications_id_seq_view() NOT NULL,
    account_id integer,
    type character varying,
    auth_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'verifications'
);
ALTER FOREIGN TABLE verifications ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE verifications ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE verifications ALTER COLUMN type OPTIONS (
    column_name 'type'
);
ALTER FOREIGN TABLE verifications ALTER COLUMN auth_id OPTIONS (
    column_name 'auth_id'
);
ALTER FOREIGN TABLE verifications ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE verifications ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
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
-- Name: verifications_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE verifications_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'verifications_id_seq_view'
);
ALTER FOREIGN TABLE verifications_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: vita_analyses; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE vita_analyses (
    id integer DEFAULT vita_analyses_id_seq_view() NOT NULL,
    vita_id integer,
    analysis_id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'vita_analyses'
);
ALTER FOREIGN TABLE vita_analyses ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE vita_analyses ALTER COLUMN vita_id OPTIONS (
    column_name 'vita_id'
);
ALTER FOREIGN TABLE vita_analyses ALTER COLUMN analysis_id OPTIONS (
    column_name 'analysis_id'
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
-- Name: vita_analyses_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE vita_analyses_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'vita_analyses_id_seq_view'
);
ALTER FOREIGN TABLE vita_analyses_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: vitae; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE vitae (
    id integer DEFAULT vitae_id_seq_view() NOT NULL,
    account_id integer NOT NULL,
    created_at timestamp without time zone
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'vitae'
);
ALTER FOREIGN TABLE vitae ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE vitae ALTER COLUMN account_id OPTIONS (
    column_name 'account_id'
);
ALTER FOREIGN TABLE vitae ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
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
-- Name: vitae_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE vitae_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'vitae_id_seq_view'
);
ALTER FOREIGN TABLE vitae_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: vulnerabilities; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE vulnerabilities (
    id integer DEFAULT vulnerabilities_id_seq_view() NOT NULL,
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
ALTER FOREIGN TABLE vulnerabilities ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE vulnerabilities ALTER COLUMN cve_id OPTIONS (
    column_name 'cve_id'
);
ALTER FOREIGN TABLE vulnerabilities ALTER COLUMN generated_on OPTIONS (
    column_name 'generated_on'
);
ALTER FOREIGN TABLE vulnerabilities ALTER COLUMN published_on OPTIONS (
    column_name 'published_on'
);
ALTER FOREIGN TABLE vulnerabilities ALTER COLUMN severity OPTIONS (
    column_name 'severity'
);
ALTER FOREIGN TABLE vulnerabilities ALTER COLUMN score OPTIONS (
    column_name 'score'
);
ALTER FOREIGN TABLE vulnerabilities ALTER COLUMN created_at OPTIONS (
    column_name 'created_at'
);
ALTER FOREIGN TABLE vulnerabilities ALTER COLUMN updated_at OPTIONS (
    column_name 'updated_at'
);
ALTER FOREIGN TABLE vulnerabilities ALTER COLUMN description OPTIONS (
    column_name 'description'
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
-- Name: vulnerabilities_id_seq_view; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE vulnerabilities_id_seq_view (
    id integer
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'vulnerabilities_id_seq_view'
);
ALTER FOREIGN TABLE vulnerabilities_id_seq_view ALTER COLUMN id OPTIONS (
    column_name 'id'
);


--
-- Name: vw_projecturlnameedits; Type: FOREIGN TABLE; Schema: public; Owner: -
--

CREATE FOREIGN TABLE vw_projecturlnameedits (
    project_id integer,
    value text
)
SERVER ohloh
OPTIONS (
    schema_name 'public',
    table_name 'vw_projecturlnameedits'
);
ALTER FOREIGN TABLE vw_projecturlnameedits ALTER COLUMN project_id OPTIONS (
    column_name 'project_id'
);
ALTER FOREIGN TABLE vw_projecturlnameedits ALTER COLUMN value OPTIONS (
    column_name 'value'
);


--
-- Name: analysis_aliases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_aliases ALTER COLUMN id SET DEFAULT nextval('analysis_aliases_id_seq'::regclass);


--
-- Name: analysis_sloc_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_sloc_sets ALTER COLUMN id SET DEFAULT nextval('analysis_sloc_sets_id_seq'::regclass);


--
-- Name: code_location_job_feeders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_location_job_feeders ALTER COLUMN id SET DEFAULT nextval('code_location_job_feeders_id_seq'::regclass);


--
-- Name: code_location_tarballs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_location_tarballs ALTER COLUMN id SET DEFAULT nextval('code_location_tarballs_id_seq'::regclass);


--
-- Name: code_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_sets ALTER COLUMN id SET DEFAULT nextval('code_sets_id_seq'::regclass);


--
-- Name: commit_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY commit_flags ALTER COLUMN id SET DEFAULT nextval('commit_flags_id_seq'::regclass);


--
-- Name: commits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY commits ALTER COLUMN id SET DEFAULT nextval('commits_id_seq'::regclass);


--
-- Name: diffs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY diffs ALTER COLUMN id SET DEFAULT nextval('diffs_id_seq'::regclass);


--
-- Name: email_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_addresses ALTER COLUMN id SET DEFAULT nextval('email_addresses_id_seq'::regclass);


--
-- Name: fisbot_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fisbot_events ALTER COLUMN id SET DEFAULT nextval('fisbot_events_id_seq'::regclass);


--
-- Name: fyles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fyles ALTER COLUMN id SET DEFAULT nextval('fyles_id_seq'::regclass);


--
-- Name: load_averages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY load_averages ALTER COLUMN id SET DEFAULT nextval('load_averages_id_seq'::regclass);


--
-- Name: slave_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY slave_logs ALTER COLUMN id SET DEFAULT nextval('slave_logs_id_seq'::regclass);


--
-- Name: slaves id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY slaves ALTER COLUMN id SET DEFAULT nextval('slave_permissions_id_seq'::regclass);


--
-- Name: sloc_metrics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sloc_metrics ALTER COLUMN id SET DEFAULT nextval('sloc_metrics_id_seq'::regclass);


--
-- Name: sloc_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sloc_sets ALTER COLUMN id SET DEFAULT nextval('sloc_sets_id_seq'::regclass);


--
-- Name: analysis_aliases analysis_aliases_analysis_id_commit_name_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_aliases
    ADD CONSTRAINT analysis_aliases_analysis_id_commit_name_id UNIQUE (analysis_id, commit_name_id);


--
-- Name: analysis_aliases analysis_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_aliases
    ADD CONSTRAINT analysis_aliases_pkey PRIMARY KEY (id);


--
-- Name: analysis_sloc_sets analysis_sloc_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_sloc_sets
    ADD CONSTRAINT analysis_sloc_sets_pkey PRIMARY KEY (id);


--
-- Name: code_location_job_feeders code_location_job_feeders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_location_job_feeders
    ADD CONSTRAINT code_location_job_feeders_pkey PRIMARY KEY (id);


--
-- Name: code_location_tarballs code_location_tarballs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_location_tarballs
    ADD CONSTRAINT code_location_tarballs_pkey PRIMARY KEY (id);


--
-- Name: code_sets code_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_sets
    ADD CONSTRAINT code_sets_pkey PRIMARY KEY (id);


--
-- Name: commit_flags commit_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY commit_flags
    ADD CONSTRAINT commit_flags_pkey PRIMARY KEY (id);


--
-- Name: commits commits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY commits
    ADD CONSTRAINT commits_pkey PRIMARY KEY (id);


--
-- Name: diffs diffs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY diffs
    ADD CONSTRAINT diffs_pkey PRIMARY KEY (id);


--
-- Name: email_addresses email_addresses_address_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_addresses
    ADD CONSTRAINT email_addresses_address_key UNIQUE (address);


--
-- Name: email_addresses email_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_addresses
    ADD CONSTRAINT email_addresses_pkey PRIMARY KEY (id);


--
-- Name: fisbot_events fisbot_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fisbot_events
    ADD CONSTRAINT fisbot_events_pkey PRIMARY KEY (id);


--
-- Name: fyles fyles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fyles
    ADD CONSTRAINT fyles_pkey PRIMARY KEY (id);


--
-- Name: load_averages load_averages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY load_averages
    ADD CONSTRAINT load_averages_pkey PRIMARY KEY (id);


--
-- Name: slave_logs slave_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY slave_logs
    ADD CONSTRAINT slave_logs_pkey PRIMARY KEY (id);


--
-- Name: slaves slave_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY slaves
    ADD CONSTRAINT slave_permissions_pkey PRIMARY KEY (id);


--
-- Name: sloc_sets sloc_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sloc_sets
    ADD CONSTRAINT sloc_sets_pkey PRIMARY KEY (id);


--
-- Name: diffs unique_diffs_on_commit_id_fyle_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY diffs
    ADD CONSTRAINT unique_diffs_on_commit_id_fyle_id UNIQUE (commit_id, fyle_id);


--
-- Name: foo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX foo ON slaves USING btree (clump_status) WHERE (oldest_clump_timestamp IS NOT NULL);


--
-- Name: index_analysis_aliases_on_analysis_id_preferred_name_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_analysis_aliases_on_analysis_id_preferred_name_id ON analysis_aliases USING btree (analysis_id, preferred_name_id);


--
-- Name: index_analysis_sloc_sets_on_analysis_id_sloc_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_analysis_sloc_sets_on_analysis_id_sloc_set_id ON analysis_sloc_sets USING btree (analysis_id, sloc_set_id);


--
-- Name: index_analysis_sloc_sets_on_sloc_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_analysis_sloc_sets_on_sloc_set_id ON analysis_sloc_sets USING btree (sloc_set_id);


--
-- Name: index_code_location_tarballs_on_code_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_location_tarballs_on_code_location_id ON code_location_tarballs USING btree (code_location_id);


--
-- Name: index_code_location_tarballs_on_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_location_tarballs_on_reference ON code_location_tarballs USING btree (reference);


--
-- Name: index_code_sets_on_best_sloc_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_sets_on_best_sloc_set_id ON code_sets USING btree (best_sloc_set_id);


--
-- Name: index_code_sets_on_code_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_sets_on_code_location_id ON code_sets USING btree (code_location_id);


--
-- Name: index_code_sets_on_logged_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_sets_on_logged_at ON code_sets USING btree ((COALESCE(logged_at, '1970-01-01 00:00:00'::timestamp without time zone)));


--
-- Name: index_commit_flags_on_commit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commit_flags_on_commit_id ON commit_flags USING btree (commit_id);


--
-- Name: index_commit_flags_on_sloc_set_id_commit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commit_flags_on_sloc_set_id_commit_id ON commit_flags USING btree (sloc_set_id, commit_id);


--
-- Name: index_commit_flags_on_sloc_set_id_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commit_flags_on_sloc_set_id_time ON commit_flags USING btree (sloc_set_id, "time" DESC);


--
-- Name: index_commits_on_code_set_id_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commits_on_code_set_id_time ON commits USING btree (code_set_id, "time");


--
-- Name: index_commits_on_name_id_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commits_on_name_id_month ON commits USING btree (name_id, date_trunc('month'::text, "time"));


--
-- Name: index_commits_on_sha1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commits_on_sha1 ON commits USING btree (sha1);


--
-- Name: index_diffs_on_commit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_diffs_on_commit_id ON diffs USING btree (commit_id);


--
-- Name: index_diffs_on_fyle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_diffs_on_fyle_id ON diffs USING btree (fyle_id);


--
-- Name: index_fisbot_events_on_code_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fisbot_events_on_code_location_id ON fisbot_events USING btree (code_location_id);


--
-- Name: index_fisbot_events_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fisbot_events_on_repository_id ON fisbot_events USING btree (repository_id);


--
-- Name: index_fyles_on_code_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fyles_on_code_set_id ON fyles USING btree (code_set_id);


--
-- Name: index_fyles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fyles_on_name ON fyles USING btree (name);


--
-- Name: index_on_commits_code_set_id_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_on_commits_code_set_id_position ON commits USING btree (code_set_id, "position");


--
-- Name: index_slave_logs_on_code_sets_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slave_logs_on_code_sets_id ON slave_logs USING btree (code_set_id);


--
-- Name: index_slave_logs_on_created_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slave_logs_on_created_on ON slave_logs USING btree (created_on);


--
-- Name: index_slave_logs_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slave_logs_on_job_id ON slave_logs USING btree (job_id);


--
-- Name: index_slave_logs_on_slave_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_slave_logs_on_slave_id ON slave_logs USING btree (slave_id);


--
-- Name: index_sloc_metrics_on_diff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sloc_metrics_on_diff_id ON sloc_metrics USING btree (diff_id);


--
-- Name: index_sloc_metrics_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sloc_metrics_on_id ON sloc_metrics USING btree (id);


--
-- Name: index_sloc_metrics_on_sloc_set_id_language_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sloc_metrics_on_sloc_set_id_language_id ON sloc_metrics USING btree (sloc_set_id, language_id);


--
-- Name: index_sloc_sets_on_code_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sloc_sets_on_code_set_id ON sloc_sets USING btree (code_set_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: analysis_sloc_sets analysis_sloc_sets_sloc_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_sloc_sets
    ADD CONSTRAINT analysis_sloc_sets_sloc_set_id_fkey FOREIGN KEY (sloc_set_id) REFERENCES sloc_sets(id);


--
-- Name: code_sets code_sets_best_sloc_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_sets
    ADD CONSTRAINT code_sets_best_sloc_set_id_fkey FOREIGN KEY (best_sloc_set_id) REFERENCES sloc_sets(id);


--
-- Name: commit_flags commit_flags_sloc_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY commit_flags
    ADD CONSTRAINT commit_flags_sloc_set_id_fkey FOREIGN KEY (sloc_set_id) REFERENCES sloc_sets(id) ON DELETE CASCADE;


--
-- Name: diffs diffs_commit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY diffs
    ADD CONSTRAINT diffs_commit_id_fkey FOREIGN KEY (commit_id) REFERENCES commits(id) ON DELETE CASCADE;


--
-- Name: diffs diffs_fyle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY diffs
    ADD CONSTRAINT diffs_fyle_id_fkey FOREIGN KEY (fyle_id) REFERENCES fyles(id);


--
-- Name: slave_logs slave_logs_code_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY slave_logs
    ADD CONSTRAINT slave_logs_code_set_id_fkey FOREIGN KEY (code_set_id) REFERENCES code_sets(id) ON DELETE CASCADE;


--
-- Name: slave_logs slave_logs_slave_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY slave_logs
    ADD CONSTRAINT slave_logs_slave_id_fkey FOREIGN KEY (slave_id) REFERENCES slaves(id) ON DELETE CASCADE;


--
-- Name: sloc_metrics sloc_metrics_diff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sloc_metrics
    ADD CONSTRAINT sloc_metrics_diff_id_fkey FOREIGN KEY (diff_id) REFERENCES diffs(id) ON DELETE CASCADE;


--
-- Name: sloc_sets sloc_sets_code_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sloc_sets
    ADD CONSTRAINT sloc_sets_code_set_id_fkey FOREIGN KEY (code_set_id) REFERENCES code_sets(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20170112183242');

INSERT INTO schema_migrations (version) VALUES ('20170615183328');

INSERT INTO schema_migrations (version) VALUES ('20170622141518');

INSERT INTO schema_migrations (version) VALUES ('20170905123152');

INSERT INTO schema_migrations (version) VALUES ('20170911100003');

