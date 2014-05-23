require 'factory_girl'
require_relative 'tag_helpers'

$tag_types = [ "Pattern", "Other", "Content", "Season", "Weave" ]

FactoryGirl.define do

  sequence :number do |n|
    n
  end

  sequence :name do |n|
    "Coconut#{n}"
  end

  $tag_types.each do |t|
    factory t.underscore.to_sym, class: t do
      name
    end
  end

  factory :best_for do
    name
  end

  factory :reed_pick_string, class: 'ReedPick' do
    full_reed_pick '45/45'
  end

  factory :reed_pick do
    sequence(:reed) { |n| n }
    sequence(:pick) { |n| n }
  end

  factory :yarn_count_string, class: 'YarnCount' do
    full_count '2/30s x 2/60s'
  end

  factory :yarn_count do
    sequence(:weft_ply_count) { |n| n }
    sequence(:weft_yarn_thickness) { |n| n + 20 }
    sequence(:warp_ply_count) { |n| n }
    sequence(:warp_yarn_thickness) { |n| n + 20 }
  end

  factory :fabric do
    sequence(:code) { |n| "Code#{n}" }
    width 44
    price 55.49
    quantity 100.30

    ignore do 
      tag_code 'p-c-s_w-d'
      reed_pick '24/32'
      yarn_count '2/30s x 2/60s'
    end

    after(:create) do |fabric, evaluator|
      create(:reed_pick_string, full_reed_pick: evaluator.reed_pick, fabric: fabric)
      create(:yarn_count_string, full_count: evaluator.yarn_count, fabric: fabric)
      tm = TagSpecHelpers::TestTagsMaker.new
      tm.make_tags_and_associate(evaluator.tag_code, fabric)
    end  
  end

end