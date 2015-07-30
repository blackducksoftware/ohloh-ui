# AppNeta TraceView Initializer (the oboe gem)
# http://www.appneta.com/products/traceview/
#
# More information on instrumenting Ruby applications can be found here:
# https://support.appneta.com/cloud/installing-ruby-instrumentation

if defined?(TraceView::Config)
  # Tracing Mode determines when traces should be initiated for incoming requests.  Valid
  # options are always, through (when using an instrumented Apache or Nginx) and never.
  #
  # If you're not using an instrumented Apache or Nginx, set this directive to always in
  # order to initiate tracing from Ruby.
  TraceView::Config[:tracing_mode] = 'through'

  # Verbose output of instrumentation initialization
  # TraceView::Config[:verbose] = false

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
  #   TraceView::Config[:nethttp][:log_args] = false
  #   TraceView::Config[:excon][:log_args] = false
  #   TraceView::Config[:typhoeus][:log_args] = true
  #
  TraceView::Config[:include_url_query_params] = true

  # Logging of incoming HTTP query args
  #
  # This optionally disables the logging of incoming URL request
  # query args.
  #
  # This flag is global and currently only affects the Rack
  # instrumentation which reports incoming request URLs and
  # query args by default.
  TraceView::Config[:include_remote_url_params] = true

  # The oboe Ruby client has the ability to sanitize query literals
  # from SQL statements.  By default this is disabled.  Enable to
  # avoid collecting and reporting query literals to TraceView.
  # TraceView::Config[:sanitize_sql] = false

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
  #   TraceView::Config[:dnt_regexp] = "lobster$"
  #   TraceView::Config[:dnt_opts]   = Regexp::IGNORECASE
  #
  # This will ignore all requests that end with the string lobster
  # regardless of case
  #
  # Requests with positive matches (non nil) will not be traced.
  # See lib/oboe/util.rb: TraceView::Util.static_asset?
  #
  # TraceView::Config[:dnt_regexp] = \
  # "\.(jpg|jpeg|gif|png|ico|css|zip|tgz|gz|rar|bz2|pdf|txt|tar|wav|bmp|rtf|js|flv|swf|ttf|woff|svg|less)$"
  # TraceView::Config[:dnt_opts]   = Regexp::IGNORECASE

  #
  # Rails Exception Logging
  #
  # In Rails, raised exceptions with rescue handlers via
  # <tt>rescue_from</tt> are not reported to the TraceView
  # dashboard by default.  Setting this value to true will
  # report all raised exception regardless.
  #
  # TraceView::Config[:report_rescued_errors] = false
  #

  #
  # Enabling/Disabling Instrumentation
  #
  # If you're having trouble with one of the instrumentation libraries, they
  # can be individually disabled here by setting the :enabled
  # value to false:
  #
  # TraceView::Config[:action_controller][:enabled] = true
  # TraceView::Config[:active_record][:enabled] = true
  # TraceView::Config[:action_view][:enabled] = true
  # TraceView::Config[:cassandra][:enabled] = true
  # TraceView::Config[:dalli][:enabled] = true
  # TraceView::Config[:excon][:enabled] = true
  # TraceView::Config[:em_http_request][:enabled] = true
  # TraceView::Config[:faraday][:enabled] = true
  # TraceView::Config[:httpclient][:enabled] = true
  # TraceView::Config[:memcache][:enabled] = true
  # TraceView::Config[:memcached][:enabled] = true
  # TraceView::Config[:mongo][:enabled] = true
  # TraceView::Config[:moped][:enabled] = true
  # TraceView::Config[:nethttp][:enabled] = true
  # TraceView::Config[:redis][:enabled] = true
  # TraceView::Config[:resque][:enabled] = true
  # TraceView::Config[:rest_client][:enabled] = true
  # TraceView::Config[:sequel][:enabled] = true
  # TraceView::Config[:typhoeus][:enabled] = true
  #

  #
  # Enabling/Disabling Backtrace Collection
  #
  # Instrumentation can optionally collect backtraces as they collect
  # performance metrics.  Note that this has a negative impact on
  # performance but can be useful when trying to locate the source of
  # a certain call or operation.
  #
  # TraceView::Config[:action_controller][:collect_backtraces] = true
  # TraceView::Config[:active_record][:collect_backtraces] = true
  # TraceView::Config[:action_view][:collect_backtraces] = true
  # TraceView::Config[:cassandra][:collect_backtraces] = true
  # TraceView::Config[:dalli][:collect_backtraces] = false
  # TraceView::Config[:excon][:collect_backtraces] = false
  # TraceView::Config[:em_http_request][:collect_backtraces] = true
  # TraceView::Config[:faraday][:collect_backtraces] = false
  # TraceView::Config[:httpclient][:collect_backtraces] = false
  # TraceView::Config[:memcache][:collect_backtraces] = false
  # TraceView::Config[:memcached][:collect_backtraces] = false
  # TraceView::Config[:mongo][:collect_backtraces] = true
  # TraceView::Config[:moped][:collect_backtraces] = true
  # TraceView::Config[:nethttp][:collect_backtraces] = true
  # TraceView::Config[:redis][:collect_backtraces] = false
  # TraceView::Config[:resque][:collect_backtraces] = true
  # TraceView::Config[:rest_client][:collect_backtraces] = true
  # TraceView::Config[:sequel][:collect_backtraces] = true
  # TraceView::Config[:typhoeus][:collect_backtraces] = false
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
  # TraceView::Config[:resque][:link_workers] = false
  #
  # Set to true to disable Resque argument logging (Default: false)
  # TraceView::Config[:resque][:log_args] = false
end
