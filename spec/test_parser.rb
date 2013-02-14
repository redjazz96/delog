class TestParser < Delog::LineParser

  build do
    # This is a line comment.  We can ignore this.
    on %r{\A\*} do
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

    on %r{\AB (?<foo>.*?)\n}, :test_method

    on %r{\AW (?<foo>.*?)\n} do
      whitelisted_method
    end

    on %r{\ANW (?<foo>.*?)\n} do
      not_whitelisted_method
    end

    on %r{\Aserver_cvar\: "(?<cvar>.*)" "(?<value>.*)"\z} => get(:data), 
      :type => :cvar_set, :cvar => d(:cvar), :value => d(:value)

    set :didnt_stop => false

    on %r{\Amatch: (?<md>.*?)\z} => get(:data), :m => d(:md), :stop => true

    on %r{\Anil\n} do
      set :something => nil
      something
    end

    set :didnt_stop => true
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