# require 'spec_helper'
# require 'ruby-debug'

# describe Color do
#   before (:each) do
#     @color = Factory.create(:color1)
#   end
  
#   it "should persist" do
#     @color.should be_persisted
#   end
  
#   it "should handle virtual attribute full_count" do
#     c = Color.create(:red => 255, :green => 255, :blue=> 255)
#     c.hexvalue.should == "#ffffff"
#     c[:ciel_L].should_not be_nil
#     c[:ciel_a].should_not be_nil
#     c[:ciel_b].should_not be_nil
#   end
# end
