# TFLog 

[![Build Status](https://travis-ci.org/redjazz96/tflog.png?branch=master)](https://travis-ci.org/redjazz96/tflog)

`TFLog` is a Team Fortress 2 log file library.  It takes Team Fortress 2 logs and provides an interface to the contents of the file, giving information about each line along the way.  Have some code examples:

```Ruby
log = TFLog::Log.new("path/to/logfile") # or, TFLog::Log.new(some_io_object)
log.lines.each do |line|
  line.class # => TFLog::Line
end

log.lines.first.type # => :comment (or some other value)
```

You can also define your own parsers for the log files:

```Ruby

    class MyParser < TFLog::LineParser
      build do
        on %r{\A\*} do
          set :type => :comment
          stop
        end
        
        on %r{\AL} do
          set :type => :log
        end
        
        on %r{
          \AL\s                   # The line starts with "L".  No idea why.
          (?<datetime>
            [0-9]{2}\/[0-9]{2}\/[0-9]{4}\s\-\s  # the date
            [0-9]{2}\:[0-9]{2}\:[0-9]{2}        # the time
          )
        }x do |m|
          set :time => m.datetime
        end

        # These two `on` calls do exactly the same thing.  I call the second one
        # "shorthand."  the `:stop => true` is the same as calling #stop, while
        # any other key-value pair is sent to #set.
        on %r{\AW} do
          set :type => :warning
          stop
        end

        # _PLEASE_ note that the position of :stop => true in the hash matters.
        # Any key-value pairs after :stop => true are ignored.
        on %r{\AW}, :type => :warning, :stop => true

        # This one matches it to something other than the actual line.  This can
        # be anything that responds to #match, but it's normally a string 
        # anyway.
        on %r{\AW} => something_predefined, :do => :something
        
        set :hello => :world, :foo => :bar
        get(:hello)  # => :world
        do_something # This calls the method we defined below.  Cool, eh?  This
                     # means we can extract `on` calls to another method,
                     # cleaning it up; or, you could set it up for another 
                     # (child) class to use.

        get(:parsetime) # => about Time.now.utc
        
        stop # Completely optional.  This means that `on` blocks are ignored,
             # and `set` calls are ignored.
        stopped? # => true
      end

      def do_something
        set :parsetime => Time.now.utc
      end
    end

    log = TFLog::Log.new("path/to/log", :parser => MyParser)
    # assuming the first line is `* this is a comment`
    log.lines.first.type # => :comment
    log.lines.first.parsetime # => nil (`set` in do_something did nothing!)

    log.lines.map do |line|
      line.parsetime.class
    end # => [NilClass, Time, ...]

```