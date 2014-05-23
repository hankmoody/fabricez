class Tag < ActiveRecord::Base
  
  has_many :fabric_tags, dependent: :destroy, foreign_key: 'tag_id'
  has_many :fabrics, through: :fabric_tags, after_remove: :destroy_me
  
  validates_presence_of :name
  validates_presence_of :type
  validates_uniqueness_of :name, :case_sensitive => false
  validates_length_of :name, :maximum => 20

  scope :patterns, -> { where(type: 'Pattern') }
  scope :weaves, -> { where(type: 'Weave') }
  scope :others, -> { where(type: 'Other') }
  scope :best_fors, -> { where(type: 'BestFor') }
  scope :seasons, -> { where(type: 'Season') }
  scope :contents, -> { where(type: 'Content') }
  scope :materials, -> { where(type: 'Material') }

  def destroy_me
    destroy if ! self.class.block_user_input? and fabrics.count == 0
  end

  class << self

    def get_default_type_symbol_list
      get_default_type_list.map { |t| t.underscore }
    end

    def get_default_type_list
      ["Content", "BestFor", "Weave", "Pattern", "Season", "Material", "Other"]
    end

    def get_type_list
      select(:type).distinct.pluck(:type)
    end

    def get_names
      nl = get_name_list
      nl.join(", ") unless nl.empty?
    end

    def get_name_list
      get_name_records_for(model_name.to_s).sort_by{|r| -r.fabrics.count}.map {|n| n.name}
    end

  private

    def get_name_records_for (type)
      type == 'Tag' ? select(:name) : select(:name).where(type: type)
    end

  end

end
