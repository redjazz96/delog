describe Delog::LineParser::Context do
  before :each do 
    @context = described_class.new
    @method_object = Object.new
  end

  it "should accept a new method" do

    def @method_object.some_method
      true.should == true
    end

    @context.add_method :some_method, @method_object
  end

  it "should run a block with methods" do
    rvalue = double(:return_value)

    @method_object.send(:define_singleton_method, :some_method) do
      rvalue
    end

    @context.add_method :some_method, @method_object

    @context.run do
      some_method.should.equal? rvalue
    end
  end

  it "should include a module" do
    @context.run_with TestInclude do
      some_method.should == "foobar"
    end
  end

  it "can raise errors" do
    expect {
      @context.run do
        raise StandardError
      end
    }.to raise_error StandardError
  end
end

module TestInclude
  def some_method
    "foobar"
  end
end