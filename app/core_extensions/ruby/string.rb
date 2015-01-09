class String
  def strip_tags
    gsub(/<.*?>/, '')
  end

  def strip_tags_preserve_line_breaks
    html = CGI.unescapeHTML(self).gsub(/\r/, '')

    # Preserve line-breaking tags by converting them to carriage returns
    html.gsub!(/<br\s*\/?>\s*\n?/, "\n")
    html.gsub!(/<\/p>\s*\n?/, "\n\n")
    html.gsub!(/<p\s*\/>\s*\n?/, "\n\n")

    text = html.strip_tags

    # Restore line-breaking tags
    text.gsub!(/\n(\s*\n)+/, '<br/><br/>')
    text.gsub!(/\n/, '<br/>')

    # Strip leading and trailing breaks
    text.gsub!(/^(<br\/>)+/, '')
    text.gsub!(/(<br\/>)+$/, '')

    text
  end

  def fix_encoding_if_invalid!
    unless valid_encoding?
      encode!('utf-8', 'binary', invalid: :replace, undef: :replace)
    end
    force_encoding('utf-8')
    self
  end
  # TODO: Rewrite and shorten this method.
  # converts hyperlinks into markdown encoded hyperlinks
  def encode_hyperlinks_in_markdown
    text = self
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
