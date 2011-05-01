require 'digest/md5'

def h(line)
  RackUtils.html_escape(line)
end

# Convert a line from a text log into html
def log_line_parse(line, options={})
  options={
    :link_to_url => nil, #url /browse/server/#chatroom/00000000
  }.update options
  if line =~ /^---/
    "" #strip log open/close stuff. 
  else
    date = line[0..7] #ignore 00:00:00
    hx = Digest::MD5.hexdigest(date)
    line = line[8..-1]
    type = case line
    when /^ * [^ ]+ /
      :action_line
    when /^<.[^>]+>/
      :message_line
    when /^-!-/
      case line
      when /now known as/
        :nick_change_line
      when /has (joined|left|quit)/
        :join_part_quit_line
      when /^-!- mode\//
        :mode_change_line
      end
    end
    type = :unknown_line unless type
    date_line = '<span class="line-date">'
    date_line << "<a href=\"#{options[:link_to_url]}##{hx}\">" if options[:link_to_url]
    date_line << date
    date_line << '</a>' if options[:link_to_url]
    date_line << '</span>'
%s{<span class="line-date">#{date}</span>}
<<-END
  <div class="#{type}"><a name="#{hx}">
    #{date_line}
    <span class="line-body">
    #{send(type, line)}
    </span>
  </a></div>
END
  end
end

#14:53:11<+epochwolf> okay... 1) bigness includes guns.
#14:25:02< soulresin> which is why gz came around.
def message_line(line)
  nick, message = /^(<.[^>]+>) (.*)$/.match(line).captures
<<-END
  <span class="line-nick">#{nick}</span>
  <span class="line-message">
  #{h message}
  </span>
END
end

#15:08:31 * epochwolf pokes soulresin to see if he jiggles
def action_line(line)
  nick, message = /^ \* ([^ ]+) (.*)$/.match(line).captures
<<-END
  <span class="line-nick">#{nick}</span>
  <span class="line-message">
  #{h message}
  </span>
END
end

#10:41:45-!- back is now known as lazzareth
#03:35:44-!- You're now known as epochwolf
def nick_change_line(line)
  other_person = /-!- ([^ ]+) is now known as ([^ ]+)/.match(line)
  you_person = /-!-  You're now known as ([^ ]+)/.match(line)
  if other_person
    old_nick, new_nick = other_person.captures
<<-END
<span class="old_nick">#{old_nick}</span> is now known as <span class="new_nick">#{new_nick}</span>
END
  elsif you_person
    new_nick = other_person.captures.first
<<-END
You're now known as <span class="new_nick">#{new_nick}</span>
END
  end
end

def join_part_quit_line(line)
  h line
end

def mode_change_line(line)
  h line
end

def unknown_line(line)
  h line
end