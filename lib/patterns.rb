module Patterns
  DEFAULT_PARAM_FORMAT = /\A[[:alpha:]][[:alnum:]_-]*\Z/
  RC_ALPHA_BETA_CHECK = /#{%w(alpha beta rc RC).join('|')}/
end
