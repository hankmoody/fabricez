require 'spec_helper'

describe User do
  
  before (:all) do
    @admin = Factory.create(:role)
    @free = Factory.create(:role, :category => 'free')
  end

  before (:each) do
    @std_user = Factory.create(:user)
  end
  
  it "should persist" do
    @std_user.should be_persisted
  end
  
  it "should set the right defaults" do
    u = @std_user
    u.role.category.should == 'free'
    u.role = nil
    u.save
    u.role.category.should == 'free'
    u.usertype.should == 'consumer'
    u.detail.should_not be_nil
  end
  
  it "should handle associations appropriately" do
    @std_user.collections.should_not be_nil
    @std_user.fabrics.should_not be_nil
  end
  
  it "should destroy associations appropriately" do
    u = @std_user
    Detail.count.should == 1
    Role.where(category: 'free').first.users.count.should == 1
    
    u.destroy
    
    Detail.count.should == 0
    Role.where(category: 'free').first.users.count.should == 0
    Fabric.count.should == 0
    Collection.count.should == 0
  end
  
end
