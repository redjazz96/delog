require 'test_parser'

describe Tflog::LineParser do

  before do
    @parser_class = TestParser
  end

  it "should parse comment" do
    line = "* this is a comment\n"

    parser = @parser_class.new(line).parse!
    parser[:type].should be :comment
  end

  it "should parse the date" do
    line = "L 02/09/2013 - 01:19:03: log\n"
    time = Time.utc(2013, 2, 9, 1, 19, 3)
    parser = @parser_class.new(line).parse!
    parser[:time].should == time
  end

  # shorthand is calling `on` without a block.
  it "should handle shorthand" do
    line = "L 02/09/2013 - 01:19:03: server_cvar: \"sv_pure\" \"0\"\n"
    parser = @parser_class.new(line).parse!
    
    { :type => :cvar_set, 
      :cvar => "sv_pure", 
      :value => "0" }.each_pair do |k, v|
      parser.get(k).should == v
    end
  end

  it "stops in shorthand" do
    line = "L 02/09/2013 - 01:19:03: match: foo bar\n"
    parser = @parser_class.new(line).parse!

    parser[:didnt_stop].should be false
    parser[:m].should == "foo bar"
  end

end