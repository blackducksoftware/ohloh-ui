# frozen_string_literal: true

# e.g. in config/initializers/better_errors.rb
# Other preset values are [:mvim, :macvim, :textmate, :txmt, :tm, :sublime, :subl, :st]
# Specify text editor in ENV[EDITOR] in env.local
BetterErrors.editor = :subl if defined? BetterErrors
