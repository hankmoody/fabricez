require 'spec_helper'

describe Fabric do
  
  before (:each) do
    @std_fabric = Factory.create(:fabric)
  end
  
  it "should persist" do
    @std_fabric.should be_persisted
  end
  
  it "should handle associations" do
    f = @std_fabric
    # Yarncount, Reedpick, colors, collections should not be nil
    f.yarn_count.should_not be_nil
    f.reed_pick.should_not be_nil
    f.colors.should_not be_empty
    
    # Add it to a collection
    c = Collection.create(Factory.attributes_for(:collection))
    f.collections.push(c)
    f.save
    f.collections.should_not be_empty
    
    f.destroy
    Fabric.count.should == 0
    
    # Don't destroy collection
    Collection.count.should == 1
    c.reload
    c.fabrics.should be_empty
    
    # Destroy YarnCount, ReedPick and Colors
    YarnCount.count.should == 0
    ReedPick.count.should == 0
    Color.count.should == 0
    
  end
  
end
