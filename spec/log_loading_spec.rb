describe TFLog::Log do
    
  before :each do
    @log = TFLog::Log.new("spec/test.log")
  end

  it "should load the file" do
    @log.lines.first.log.should eq "server_cvar: \"mp_winlimit\" \"4\""
  end

  it "should yield in order" do
    last_time = Time.utc(0)
    last_line = -1

    @log.lines.each do |line|
      unless line.type? :comment
        # The reason why this works is because I set each successive line's time
        # to be greater than the last time.  It is extremely possible for two or
        # more lines to have the same time.
        line.time.should be > last_time
        last_time = line.time
      end

      # This one is more accurate.
      line.number.should be > last_line
      last_line = line.number
    end
  end

end