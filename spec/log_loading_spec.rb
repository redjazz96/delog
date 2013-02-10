describe TFLog::Log do

  it "should load the file" do
    log = TFLog::Log.new("spec/test.log")
    log.lines.first.data[:data].should eq("server_cvar: \"mp_winlimit\" \"4\"")
  end

end