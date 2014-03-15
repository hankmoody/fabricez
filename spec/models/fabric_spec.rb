# require 'spec_helper'

# describe Fabric do
  
#   before (:all) do
#   end
  
#   after (:all) do
#     Tag.all.each { |t| t.delete }
#   end
  
#   before (:each) do
#     @std_fabric = Factory.create(:fabric)
#   end
  
#   it "should persist" do
#     @std_fabric.should be_persisted
#   end
  
#   it "should handle associations" do
#     f = @std_fabric
#     # Yarncount, Reedpick, colors, collections should not be nil
#     f.yarn_count.should_not be_nil
#     f.reed_pick.should_not be_nil
#     f.colors.should_not be_empty
    
#     # Add it to a collection
#     c = Collection.create(Factory.attributes_for(:collection))
#     f.collections.push(c)
#     f.save
#     f.collections.should_not be_empty
    
#     f.destroy
#     Fabric.count.should == 0
    
#     # Don't destroy collection
#     Collection.count.should == 1
#     c.reload
#     c.fabrics.should be_empty
    
#     # Destroy YarnCount, ReedPick and Colors
#     YarnCount.count.should == 0
#     ReedPick.count.should == 0
#     Color.count.should == 0
    
#   end
  
#   it "should handle tags" do
#     @t1 = Factory.create(:tag)
#     @t2 = Factory.create(:tag, :name => "100% Cotton", :tagtype => "contents")
#     load 'fabric.rb' # Reloading since the methods can change
#     f = @std_fabric
#     f.tags.push(@t1)
#     f.tags.push(@t2)
#     f.save
#     f.pattern_list.should == "Check"
#     f.contents_list.should == "100% Cotton"
    
#     f.pattern_list = ""
#     f.save
#     f.pattern_list.should be_nil
#     Tag.where(tagtype: "pattern").count.should == 1
    
#     f.contents_list = ""
#     f.save
#     f.contents_list.should be_nil
#     Tag.where(tagtype: "contents").count.should == 0
    
#     f.contents_list = "100% Cotton"
#     f.save
#     f.contents_list.should == "100% Cotton"
    
#     f.pattern_list = "Check"
#     f.save
#     f.pattern_list.should == "Check"
#   end
  
# end
