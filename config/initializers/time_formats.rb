# frozen_string_literal: true

# Custom Date or Time formats
new_formats = {
  dmy: '%d-%b-%Y',
  mdy: '%b %d, %Y',
  by: '%b %Y'
}
Time::DATE_FORMATS.update(new_formats)
Date::DATE_FORMATS.update(new_formats)

# Formats specific to Time or DateTime.
new_time_formats = { full: '%A, %B %d, %Y @ %T%p %Z' }
Time::DATE_FORMATS.update(new_time_formats)
