# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # From http://www.bigbold.com/snippets/posts/show/592
  def text_list(listtext,sep1=", ", sep2=", and ")
    n=listtext.size
    if n>1 : (listtext.first(n-1)).join(sep1) + sep2 +listtext.last 
    else listtext.first end
  end

  def linkify( text )
    # Escape the text for html display and convert any url-type strings into active links
    if text != nil
      h( text )
      text = text.gsub( /\n/, '<br/>' )

      # auto_link is the default helper built into rails, but there are a few problems with it recognising urls.
      # We're using part of a patch file for auto_link here since I can't edit the Textdrive rails installation directly.
      # See this for more info - http://dev.rubyonrails.org/attachment/ticket/1043/auto-link.patch
      text.gsub(/(<\w+.*?>|[^=!:'"\/]|^)((?:http[s]?:\/\/)|(?:www\.))([^\s<]+\/?)([[:punct:]]|\s|<|$)/) do
        all, a, b, c, d = $&, $1, $2, $3, $4
        if a =~ /<a\s/i # don't replace URL's that are already linked
          all     
        else    
          #%(#{a}<a href="#{b=="www."?"http://www.":b}#{c}">#{b}#{c}</a>#{d})
          %(#{a}<a href="#{b=="www."?"http://www.":b}#{c}">#{b}#{c}</a>#{d})
          %(#{a}<a href="#{b=="www."?"http://www.":b}#{c}">) + truncate( (b + c), 50 ) + %(</a>#{d})
        end
      end
    end
  end

  def urlnameify(text)
    # From http://textsnippets.com/posts/show/485
    t = Iconv.new('ASCII//TRANSLIT', 'utf-8').iconv(text)
    t = t.downcase.strip.gsub(/[^-_\s[:alnum:]]/, '').squeeze(' ').tr(' ', '-')
    (t.blank?) ? '-' : t 
  end

  def list_years( year = Date.today.year, limit = 10 )
    Memory.list_years(year, limit)
  end
end
