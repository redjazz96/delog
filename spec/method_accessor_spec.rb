describe Delog::MethodAccessor do
  before :each do
    @accessor = described_class.new(:hello => "world", :foo => "bar")
  end

  it "should provide access to attributes" do
    @accessor.hello.should   eq "world"
    @accessor[:hello].should eq "world"
    @accessor.hello.should   be @accessor[:hello]
  end

  it "should allow question methods" do
    @accessor.foo?("bar").should   be true
    @accessor.foo?("world").should be false
  end

  it "should set the value of attribute" do
    @accessor.something "other"
    @accessor.something.should eq "other"
  end

  it "should return nil on empty attribute" do
    @accessor.empty_attribute.should be nil
  end

  it "should return right values for has_key?" do
    @accessor.has_key?(:hello).should be true
    @accessor.has_key?(:key).should   be false
  end
end