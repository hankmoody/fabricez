require 'spec_helper'

describe Tag do
  before(:each) do 
    
  end
  
  it "should persist" do
    t = Factory.create(:tag)
    t.should be_persisted
  end
  
  it "should return correct tag type list" do
    t = Factory.create(:tag)
    Tag.get_tagtype_list.first.should include("pattern")
  end
  
end
