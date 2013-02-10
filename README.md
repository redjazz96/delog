# TFLog
`TFLog` is a Team Fortress 2 log file library.  It takes Team Fortress 2 logs and provides an interface to the contents of the file, giving information about each line along the way.  Have some code examples:

```Ruby
log = TFLog::Log.new("path/to/logfile") # or, TFLog::Log.new(some_io_object)
log.each do |line|
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
        
        on %{\AL} do
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
        
        set :hello => :world, :foo => :bar
        get(:hello) # => :world
        
        stop # Completely optional.  This means that `on` blocks are ignored,
        	 # and `set` calls are ignored.  This basically means that the line
             # is done.
        stopped? # => true
    end
end
```