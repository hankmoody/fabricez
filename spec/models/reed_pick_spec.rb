require 'spec_helper'

describe ReedPick do
  before (:each) do
    @rp = Factory.create(:reed_pick)
  end
  
  it "should persist" do
    @rp.should be_persisted
  end
  
  it "should handle virtual attribute full_count" do
    @rp.full_reed_pick.should == "24/32"
    
    @rp.full_reed_pick = "54/67"
    @rp.save
    @rp.reed.should == 54
    @rp.pick.should == 67
    
  end
end
