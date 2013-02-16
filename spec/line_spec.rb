require 'test_parser'

describe Delog::Line do

  before :each do
    @lines = Delog::Log.new("spec/test.log", :parser => TestParser).to_a
  end

  # Notice how the second line is dated one second earlier than the first line.
  # Even though this is true, we still compare by the line number because that's
  # the order they were found in the log.
  it "should compare nicely" do
    line1 = described_class.new("L 02/09/2013 - 01:19:03: line1", 1,
      :parser => TestParser)
    line2 = described_class.new("L 02/09/2013 - 01:19:02: line2", 2,
      :parser => TestParser)

    line1.should be < line2
    line1.should be > 0
  end

  it "should give the time of the log" do
    @lines.first[:time].should be_instance_of Time
  end

  it "should set a key-value pair on undefined method call" do
    @lines.first[:time_format].should == "%m/%d/%Y - %H:%M:%S"
  end

  it "should be in order" do
    @lines.first[:type].should be :cvar_set
    @lines.last[:type ].should be :comment
  end

end
