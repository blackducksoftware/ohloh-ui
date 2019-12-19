# frozen_string_literal: true

#  Enabling the GC profile so that New Relic can get this information
#  https://docs.newrelic.com/docs/agents/ruby-agent/features/garbage-collection#gc_setup

GC::Profiler.enable
