module TFLog::Parsers
  class Basic < TFLog::LineParser

    build do

      # This is a line comment.  We can ignore this.
      on %r{\A\*}, :type => :comment, :stop => true

      # This sets the format of the time that the date is in.
      time_format "%m/%d/%Y - %H:%M:%S"

      # This pulls the log data out of the log as well as pulls out the time.
      on %r{
        \AL\s # I'm not sure why, but the line has to start with an L
              # from what I've seen.
        (?<datetime>
          [0-9]{2}\/[0-9]{2}\/[0-9]{4}\s\-\s # The date
          [0-9]{2}\:[0-9]{2}\:[0-9]{2}       # the time
        )\:\s
        (?<data>
          .+\Z
        )\n?
      }x do |m|
        set :time => DateTime.strptime(m.datetime, time_format).to_time.utc,
            :log => m.data
      end

      # Logged comments, mainly used by the reply system.
      on %r{\A\s*\*(?<comment_data>.*)\z} => log, :type => :comment, 
        :cdata => d(:comment_data), :stop => true


      # When a cvar changes, it's logged to the file; this pulls that out.
      on %r{\Aserver_cvar\: "(?<cvar>.*)" "(?<value>.*)"\z} => log, 
        :type => :cvar_set, :cvar => d(:cvar), :value => d(:value), 
        :stop => true

    end
  end
end