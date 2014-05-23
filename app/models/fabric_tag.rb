class FabricTag < ActiveRecord::Base
  belongs_to :fabric
  belongs_to :tag

  after_destroy :destroy_empty_tag

private

  def destroy_empty_tag
    tag.destroy_me
  end

end