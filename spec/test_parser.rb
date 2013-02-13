class TestParser < TFLog::LineParser

  build do
    # This is a line comment.  We can ignore this.
    on /\A\*/ do
      type :comment
      stop
    end

    # Sets the data `time_format` - should be accessible using `get` or `data`.
    time_format "%m/%d/%Y - %H:%M:%S"

    on %r{
      # sublime doesnt like comments in regular expressions with
      # quotes in them, so I wont use them here.
      \AL\s # Im not sure why, but the line has to start with an L
            # from what Ive seen.
      (?<datetime>
        [0-9]{2}\/[0-9]{2}\/[0-9]{4}\s\-\s # The date
        [0-9]{2}\:[0-9]{2}\:[0-9]{2}       # the time
      )\:\s
      (?<data>
        .+\Z
      )\n?
    }x do |m|
      set :time => DateTime.strptime(m.datetime, time_format).to_time.utc,
          :data => m.data
    end

    on %r{\Aserver_cvar\: "(?<cvar>.*)" "(?<value>.*)"\z} => get(:data), 
      :type => :cvar_set, :cvar => d(:cvar), :value => d(:value)

    set :didnt_stop => false

    on %r{\Amatch: (?<md>.*?)\z} => get(:data), :m => d(:md), :stop => true

    set :didnt_stop => true
  end
end