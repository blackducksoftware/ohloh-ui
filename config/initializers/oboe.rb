# AppNeta TraceView Initializer (the oboe gem)
# http://www.appneta.com/products/traceview/
#
# More information on instrumenting Ruby applications can be found here:
# https://support.appneta.com/cloud/installing-ruby-instrumentation

if defined?(Oboe::Config)
  # Tracing Mode determines when traces should be initiated for incoming requests.  Valid
  # options are always, through (when using an instrumented Apache or Nginx) and never.
  #
  # If you're not using an instrumented Apache or Nginx, set this directive to always in
  # order to initiate tracing from Ruby.
  Oboe::Config[:tracing_mode] = 'through'

  # Verbose output of instrumentation initialization
  # Oboe::Config[:verbose] = false

  # Logging of outgoing HTTP query args
  #
  # This optionally disables the logging of query args of outgoing
  # HTTP clients such as Net::HTTP, excon, typhoeus and others.
  #
  # This flag is global to all HTTP client instrumentation.
  #
  # To configure this on a per instrumentation basis, set this
  # option to true and instead disable the instrumenstation specific
  # option <tt>log_args</tt>:
  #
  #   Oboe::Config[:nethttp][:log_args] = false
  #   Oboe::Config[:excon][:log_args] = false
  #   Oboe::Config[:typhoeus][:log_args] = true
  #
  Oboe::Config[:include_url_query_params] = true

  # Logging of incoming HTTP query args
  #
  # This optionally disables the logging of incoming URL request
  # query args.
  #
  # This flag is global and currently only affects the Rack
  # instrumentation which reports incoming request URLs and
  # query args by default.
  Oboe::Config[:include_remote_url_params] = true

  # The oboe Ruby client has the ability to sanitize query literals
  # from SQL statements.  By default this is disabled.  Enable to
  # avoid collecting and reporting query literals to TraceView.
  # Oboe::Config[:sanitize_sql] = false

  # Do Not Trace
  # These two values allow you to configure specific URL patterns to
  # never be traced.  By default, this is set to common static file
  # extensions but you may want to customize this list for your needs.
  #
  # dnt_regexp and dnt_opts is passed to Regexp.new to create
  # a regular expression object.  That is then used to match against
  # the incoming request path.
  #
  # The path string originates from the rack layer and is retrieved
  # as follows:
  #
  #   req = ::Rack::Request.new(env)
  #   path = URI.unescape(req.path)
  #
  # Usage:
  #   Oboe::Config[:dnt_regexp] = "lobster$"
  #   Oboe::Config[:dnt_opts]   = Regexp::IGNORECASE
  #
  # This will ignore all requests that end with the string lobster
  # regardless of case
  #
  # Requests with positive matches (non nil) will not be traced.
  # See lib/oboe/util.rb: Oboe::Util.static_asset?
  #
  # Oboe::Config[:dnt_regexp] = \
  # "\.(jpg|jpeg|gif|png|ico|css|zip|tgz|gz|rar|bz2|pdf|txt|tar|wav|bmp|rtf|js|flv|swf|ttf|woff|svg|less)$"
  # Oboe::Config[:dnt_opts]   = Regexp::IGNORECASE

  #
  # Rails Exception Logging
  #
  # In Rails, raised exceptions with rescue handlers via
  # <tt>rescue_from</tt> are not reported to the TraceView
  # dashboard by default.  Setting this value to true will
  # report all raised exception regardless.
  #
  # Oboe::Config[:report_rescued_errors] = false
  #

  #
  # Enabling/Disabling Instrumentation
  #
  # If you're having trouble with one of the instrumentation libraries, they
  # can be individually disabled here by setting the :enabled
  # value to false:
  #
  # Oboe::Config[:action_controller][:enabled] = true
  # Oboe::Config[:active_record][:enabled] = true
  # Oboe::Config[:action_view][:enabled] = true
  # Oboe::Config[:cassandra][:enabled] = true
  # Oboe::Config[:dalli][:enabled] = true
  # Oboe::Config[:excon][:enabled] = true
  # Oboe::Config[:em_http_request][:enabled] = true
  # Oboe::Config[:faraday][:enabled] = true
  # Oboe::Config[:httpclient][:enabled] = true
  # Oboe::Config[:memcache][:enabled] = true
  # Oboe::Config[:memcached][:enabled] = true
  # Oboe::Config[:mongo][:enabled] = true
  # Oboe::Config[:moped][:enabled] = true
  # Oboe::Config[:nethttp][:enabled] = true
  # Oboe::Config[:redis][:enabled] = true
  # Oboe::Config[:resque][:enabled] = true
  # Oboe::Config[:rest_client][:enabled] = true
  # Oboe::Config[:sequel][:enabled] = true
  # Oboe::Config[:typhoeus][:enabled] = true
  #

  #
  # Enabling/Disabling Backtrace Collection
  #
  # Instrumentation can optionally collect backtraces as they collect
  # performance metrics.  Note that this has a negative impact on
  # performance but can be useful when trying to locate the source of
  # a certain call or operation.
  #
  # Oboe::Config[:action_controller][:collect_backtraces] = true
  # Oboe::Config[:active_record][:collect_backtraces] = true
  # Oboe::Config[:action_view][:collect_backtraces] = true
  # Oboe::Config[:cassandra][:collect_backtraces] = true
  # Oboe::Config[:dalli][:collect_backtraces] = false
  # Oboe::Config[:excon][:collect_backtraces] = false
  # Oboe::Config[:em_http_request][:collect_backtraces] = true
  # Oboe::Config[:faraday][:collect_backtraces] = false
  # Oboe::Config[:httpclient][:collect_backtraces] = false
  # Oboe::Config[:memcache][:collect_backtraces] = false
  # Oboe::Config[:memcached][:collect_backtraces] = false
  # Oboe::Config[:mongo][:collect_backtraces] = true
  # Oboe::Config[:moped][:collect_backtraces] = true
  # Oboe::Config[:nethttp][:collect_backtraces] = true
  # Oboe::Config[:redis][:collect_backtraces] = false
  # Oboe::Config[:resque][:collect_backtraces] = true
  # Oboe::Config[:rest_client][:collect_backtraces] = true
  # Oboe::Config[:sequel][:collect_backtraces] = true
  # Oboe::Config[:typhoeus][:collect_backtraces] = false
  #

  #
  # Resque Options
  #
  # :link_workers - associates Resque enqueue operations with the jobs they queue by piggybacking
  #                 an additional argument on the Redis queue that is stripped prior to job
  #                 processing
  #                 !!! Note: Make sure both the enqueue side and the Resque workers are instrumented
  #                 before enabling this or jobs will fail !!!
  #                 (Default: false)
  # Oboe::Config[:resque][:link_workers] = false
  #
  # Set to true to disable Resque argument logging (Default: false)
  # Oboe::Config[:resque][:log_args] = false
end
