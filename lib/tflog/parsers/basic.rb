module TFLog::Parsers
  class Basic < TFLog::LineParser

    build do
      # This is a line comment.  We can ignore this.
      on %r{\A\*} do
        set :type => :comment
        stop
      end

      line_regex = /
        \AL\s # I'm not sure why, but the line has to start with an L
              # from what I've seen.
        (?<datetime>
          [0-9]{2}\/[0-9]{2}\/[0-9]{4}\s\-\s # The date
          [0-9]{2}\:[0-9]{2}\:[0-9]{2}       # the time
        )\:\s
        (?<data>
          .+\Z
        )
      /x

      time_format = "%m/%d/%Y - %H:%M:%S"

      on line_regex do |m|
        set :time => DateTime.strptime(m.datetime, time_format).to_time.utc
      end
    end
  end
end