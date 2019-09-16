# frozen_string_literal: true

prefs = {}
prefs[:title] = @widget.title
prefs[:title_url] = root_url
prefs[:author] = 'Open Hub'
prefs[:author_email] = 'info@openhub.net'
prefs[:author_link] = root_url
prefs[:description] = @widget.description
prefs[:width] = @widget.width + 10
prefs[:height] = @widget.height + 14

content = { type: 'url', href: widget_url(@widget, @type) }

xml.instruct!
xml.Module do
  xml.ModulePrefs '', prefs
  xml.Content '', content
end
