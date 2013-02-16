describe Delog::Parsers::Addins do

  before :each do
    @parser = AddinTestParser.new("hello world").handle_addins
  end

  it "should include the methods" do
    @parser.context.run_with_current! do
      some_method.should == "some value"
    end
  end


end

module TestAddin

  def some_method
    "some value"
  end

  def self.whitelist
    [:some_method]
  end

end

class AddinTestParser < Delog::LineParser
  addin TestAddin

  build do
    puts "BUILD CALLED"
  end
end
