require 'test_parser'

describe Delog::LineParser do

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
    line = "STOP foo bar\n"
    parser = @parser_class.new(line).parse!

    parser[:didnt_stop].should be false
    parser[:m].should == "foo bar"
  end

  # this is for `on /regexp/, :some_method` syntax
  it "should use a method when using a symbol" do
    line = "B bar\n"
    parser = @parser_class.new(line).parse!

    parser[:hello].should be :world
  end

  it "should be able to call a whitelisted method" do
    line = "W bar\n"
    parser = @parser_class.new(line).parse!
  end

  it "should not be able to call a nonwhitelisted method" do
    line = "NW bar\n"
    expect {
      @parser_class.new(line).parse!
    }.to raise_error NameError
  end

  it "should not raise when data has nil value" do
    line = "nil\n"
    parser = @parser_class.new(line).parse!
    parser.data[:something].should be nil
  end

end
