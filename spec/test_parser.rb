class TestParser < Delog::LineParser

  build do
    # This is a line comment.  We can ignore this.
    on %r{\A\*} do
      type :comment
      stop
    end

    # Sets the data `time_format` - should be accessible using `get` or `data`.
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
    on %r{\A\s*\*(?<comment_data>.*)\z} => get(:log), :type => :comment,
      :cdata => d(:comment_data), :stop => true


    # When a cvar changes, it's logged to the file; this pulls that out.
    on %r{\Aserver_cvar\: "(?<cvar>.*)" "(?<value>.*)"\z} => get(:log),
      :type => :cvar_set, :cvar => d(:cvar), :value => d(:value),
      :stop => true

    on %r{\AB (?<foo>.*?)\n}, :test_method

    on %r{\AW (?<foo>.*?)\n} do
      whitelisted_method
    end

    on %r{\ANW (?<foo>.*?)\n} do
      not_whitelisted_method
    end

    set :didnt_stop => false

    on %r{\ASTOP (?<md>.*?)\n\z}, :m => d(:md), :stop => true

    set :didnt_stop => true

    on %r{\Anil\n} do
      set :something => nil
      something
    end

  end

  def test_method(m)
    set :hello => :world
    m.foo.should == "bar"
  end

  def whitelisted_method
    true.should == true
  end

  def not_whitelisted_method
    false.should == true
  end

  def_whitelist :test_method, :whitelisted_method
end
