describe TFLog::Parsers::Basic do
  it "should parse comment" do
    line = "* this is a comment\n"

    parser = described_class.new(line).parse!
    parser.data[:type].should be(:comment)
  end

  it "should parse the date" do
    line = "L 02/09/2013 - 01:19:03: log"
    time = Time.utc(2013, 2, 9, 1, 19, 3)
    parser = described_class.new(line).parse!
    parser.data[:time].should eq(time)
  end

end