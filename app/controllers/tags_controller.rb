class TagsController < ApplicationController
  autocomplete :tag, :tag_name
      
end
