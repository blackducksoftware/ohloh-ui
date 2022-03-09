#! /usr/bin/env ruby
# frozen_string_literal: true

raise 'RAILS_ENV is undefined' unless ENV['RAILS_ENV']

require_relative '../config/environment'

# rubocop:disable Layout/LineLength
ActiveRecord::Base.connection.execute("

INSERT INTO failure_groups(
	name, pattern, priority, auto_reschedule)
	VALUES
    ('Investigate: SVN path not found', '%svn%path not found%', 0, false),
    ('Investigate: Invalid revision range', '%fatal: Invalid revision range%', 0, false),
    ('Investigate: Name/service not known', '%Name or service not known%', 0, false),
    ('Investigate: Invalid URL', '%Unable to connect to a repository at URL%', 0, false),
    ('Investigate: No common commits', '%no common commits%', 0, false),
    ('Investigate: Unknown revision default', '%abort: unknown revision%', 0, false),
    ('Investigate: conversion of nil into string', '%no implicit conversion of nil into String%', 0, false),
    ('Investigate: sha1 already taken', '%Validation failed: Commit sha1 has already been taken%', 0, false),
    ('Investigate: Not a tar archive', '%This does not look like a tar archive%', 0, false),
    ('Investigate: Parse error - missing argument', '%hg: parse error: missing argument%', 0, false),
    ('Investigate: allow unknown type', '%usage: git cat-file (-t [--allow-unknown-type]%', 0, false),
    ('Investigate: tarball - Syntax error', '%Syntax error:%', 0, false),
    ('Investigate: not a git repository', '%does not appear to be a git repository%', 0, false),
    ('Investigate: Unknown device/address','%fatal: could not read Username for%No such device or address%', 0, false),
    ('Investigate: Ambiguous argument - unknown revision', '%fatal: ambiguous argument%unknown revision or path not in the working tree%', 0, false),
    ('Investigate: Non fast-forward', '%(non-fast-forward)%', 0, false) ;")

# rubocop:enable Layout/LineLength
FailureGroup.categorize
