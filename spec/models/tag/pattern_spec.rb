require 'spec_helper'

describe Pattern do
  before(:each) do 
  end
  
  it "should persist" do
    t = Factory.create(:pattern)
    t.should be_persisted
  end
  
  it "should be of correct type" do
    t = Factory.create(:pattern)
    t.type.eql?("pattern")
  end
  
end
