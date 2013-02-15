# Delog 

[![Build Status](https://travis-ci.org/redjazz96/delog.png?branch=master)](https://travis-ci.org/redjazz96/delog) [![Code Climate](https://codeclimate.com/github/redjazz96/delog.png)](https://codeclimate.com/github/redjazz96/delog)

`Delog` is a log file library.  It takes generic load files and using defined parser rules creates a reconstruction of the log in an accessible manner.  Have some code examples:

```Ruby
log = Delog::Log.new("path/to/logfile") # or, Delog::Log.new(some_io_object)
log.lines.each do |line|
  line.class # => Delog::Line
end

log.lines.first.type # => :comment (or some other value)
```

You can also define your own parsers for the log files:

```Ruby

    class MyParser < Delog::LineParser
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

        # Here, if you've previously set :log to have a value, you can use it
        # in a match.  But if you're not careful, you can accidentally cause
        # name errors because +log+ isn't (and hasn't) been defined.  So use
        # +get(:log)+ unless you're absolutely sure that +log+ always has a
        # value.
        on %r{\AW (?<something>.*?)} => log, :thing => d(:something)
        
        set :hello => :world, :foo => :bar
        get(:hello)  # => :world
        do_something # This calls the method we defined below.  Cool, eh?  This
                     # means we can extract `on` calls to another method,
                     # cleaning it up; or, you could set it up for another 
                     # (child) class to use.

        # This calls the method #on_match defined below, outside of the block.
        on %r{someone: (?<somebody>.*?);}, :on_match

        get(:parsetime) # => about Time.now.utc
        
        stop # Completely optional.  This means that `on` blocks are ignored,
             # and `set` calls are ignored.
        stopped? # => true
      end

      def do_something
        set :parsetime => Time.now.utc
      end

      def on_match(match)
        set :something => match.somebody
      end

      # You have to add your methods to the whitelist that way only some methods
      # are exposed to the parser.  This helps keep the namespace clean.
      def_whitelist :do_something, :on_match
    end

    log = Delog::Log.new("path/to/log", :parser => MyParser)
    # assuming the first line is `* this is a comment`
    log.lines.first.type # => :comment
    log.lines.first[:parsetime] # => nil (`set` in do_something did nothing!)

    log.lines.map do |line|
      line.parsetime.class
    end # => [NilClass, Time, ...]

```
