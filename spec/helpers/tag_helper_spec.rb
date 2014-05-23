
require 'spec_helper'

def create_all_tags
   create(:pattern)
   create(:other)
   create(:content)
   create(:season)
   create(:weave)
   create(:best_for)
end

def verify_tag_type_list (list)
  list.size.should == 6
  list.should include("Pattern")
  list.should include("Other")
  list.should include("Content")
  list.should include("Season")
  list.should include("Weave")
  list.should include("BestFor")
end