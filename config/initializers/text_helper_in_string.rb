
# ActionView Text Helpers are great!
# Let's extend the String class to allow us to call
# some of these methods directly on a String.
# Note:
#  - cycle-related methods are not included
#  - concat is not included
#  - pluralize is not included because it is in
#       ActiveSupport String extensions already
#       (though they differ).
#  - markdown requires BlueCloth
#  - textilize methods require RedCloth
# Example:
# "<b>coolness</b>".strip_tags -> "coolness"

require 'singleton'

# Singleton to be called in wrapper module
class TextHelperSingleton
  include Singleton
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper #tag_options needed by auto_link
  include ActionView::Helpers::SanitizeHelper

  def self.full_sanitizer
    @full_sanitizer ||= HTML::FullSanitizer.new
  end

  def self.link_sanitizer
    @link_sanitizer ||= HTML::LinkSanitizer.new
  end

  def self.white_list_sanitizer
    @white_list_sanitizer ||= HTML::WhiteListSanitizer.new
  end

  def self.sanitized_uri_attributes=(attributes)
    HTML::WhiteListSanitizer.uri_attributes.merge(attributes)
  end

end

# Wrapper module
module MyExtensions #:nodoc:
  module CoreExtensions #:nodoc:
    module String #:nodoc:
      module TextHelper

        def auto_link(link = :all, href_options = {}, &block)
          TextHelperSingleton.instance.auto_link(self, link, href_options, &block)
        end

        def excerpt(phrase, radius = 100, excerpt_string = "...")
          TextHelperSingleton.instance.excerpt(self, phrase, radius, excerpt_string)
        end

        def highlight(phrase, highlighter = '<strong class="highlight">\1</strong>')
          TextHelperSingleton.instance.highlight(self, phrase, highlighter)
        end

        def markdown
          TextHelperSingleton.instance.markdown(self)
        end

        def sanitize
          TextHelperSingleton.instance.sanitize(self)
        end

        def simple_format
          TextHelperSingleton.instance.simple_format(self)
        end

        def strip_tags
          TextHelperSingleton.instance.strip_tags(self)
        end

        def strip_tags_and_escaped_html
          c = HTMLEntities.new
          c.encode(c.decode(self).strip_tags, :decimal)
        end

				def strip_tags_preserve_line_breaks(want_newlines = false)
					html = self
					#sanitize(CGI.unescapeHTML(html.to_s))
					html = CGI.unescapeHTML(html.to_s)

					html.gsub!(/\r/,'')

					# Preserve line-breaking tags by converting them to carriage returns
					html.gsub!(/<br\s*\/?>\s*\n?/,"\n")
					html.gsub!(/<\/p>\s*\n?/,"\n\n")
					html.gsub!(/<p\s*\/>\s*\n?/,"\n\n")

					text = html.strip_tags

          # support simple txt
          return text if want_newlines

					# Restore line-breaking tags
					text.gsub!(/\n(\s*\n)+/,"<br/><br/>")
					text.gsub!(/\n/,"<br/>")

					# Strip leading and trailing breaks
					text.gsub!(/^(<br\/>)+/,'')
					text.gsub!(/(<br\/>)+$/,'')

					text
				end

      #  begin
      #    require_library_or_gem 'redcloth'

      #    def textilize
      #      TextHelperSingleton.instance.textilize(self)
      #    end

      #    def textilize_without_paragraph
      #      TextHelperSingleton.instance.textilize_without_paragraph(self)
      #    end
      #  rescue LoadError
          # do nothing.  methods will be undefined
      #  end

        def truncate(options={})
          TextHelperSingleton.instance.truncate(self, options)
        end

        def word_wrap(line_width = 80)
          TextHelperSingleton.instance.word_wrap(self, line_width)
        end

        # as specified, will truncate on word boundaries
        def truncate_on_words(char_length = 30)
          answer = ''
          self.split.each do |w|
            new_answer = answer
            new_answer += ' ' unless answer.blank?
            new_answer += w
            if new_answer.length > char_length
              return answer
            end
            answer = new_answer
          end
          answer
        end

        # converts hyperlinks into markdown encoded hyperlinks
        def encode_hyperlinks_in_markdown
          text = self
          
          # Note that Ruby 1.8 does not support negative look behind
          # So this function is a lot more complicated due to that
          
          # Grab URL's from the text
          urls = text.scan(/(?:http|https):\/\/[a-z0-9]+(?:[\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(?:(?::[0-9]{1,5})?\/[^\])\s]*)?/ix) 
          
          # Remove duplicates
          urls = urls & urls  
          
          # This loop does the actual replacing, but only if it's not already a markdown url
          # Again, this could be eliminated if we were using ruby 1.9
          urls.each do |url|
            loc = text.index(url) 
            while loc != nil
              #if loc<1 || text[(loc-2), 1]!=']' || text[(loc-1), 1]!='('
              if (text[(loc-1), 1]=="[" && (loc+url.length+1)<text.length && text[(loc+url.length), 1]=="]" && text[(loc+url.length+1), 1]=="(") || (loc>1 && text[(loc-2), 1]==']' && text[(loc-1), 1]=='(')
                loc = text.index(url, loc+1)
              else
                text[loc...(loc+url.length)] = "[" + url + "](" + url + ")"
                if loc+((url.length*2)+4) > text.length
                  break
                end
                loc = text.index(url, loc+((url.length*2)+4)) 
              end
            end
          end
          
          text
        end
      end
    end
  end
end

# extend String with the TextHelper functions
class String #:nodoc:
  include MyExtensions::CoreExtensions::String::TextHelper
end

