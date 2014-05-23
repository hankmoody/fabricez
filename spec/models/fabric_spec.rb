require 'spec_helper'

describe Fabric do

  it "can replace tags with supplied values and destroy empty mutable tags" do
    f = create(:fabric, tag_code: 'o-blah')
    expect(f.tags.first.name).to eql('Blah')

    t1 = Tag.where(name: 'Blah').first
    t3 = create(:other, name: 'Blah3')
    f.tags = [ t1, t3 ]
    expect(Other.where(name: 'Blah')).to exist
    expect(Other.where(name: 'Blah3')).to exist
    expect(f.tags.count).to eql(2)

    t2 = create(:other, name:'Blah2')
    f.tags = [ t2, t3 ]
    expect(f.tags.count).to eql(2)
    expect(f.tags).to include(t2)
    expect(f.tags).to include(t3)
    expect(Other.where(name: 'Blah2')).to exist
    expect(Other.where(name: 'Blah3')).to exist
    expect(Other.where(name: 'Blah')).not_to exist
  end

  it "update tags using string list" do
    f = create(:fabric)
    f.other_tag_list = 'Coconut, Mango, Pineapple'
    f.pattern_tag_list = 'Checks, Stripes, Voile'
    validate_fabric_tags(f, 'Pattern', 'Checks, Stripes, Voile')
    validate_fabric_tags(f, 'Other', 'Coconut, Mango, Pineapple')
    expect(f.pattern_tag_list).to eql('Checks, Stripes, Voile')
    expect(f.other_tag_list).to eql('Coconut, Mango, Pineapple')

    f.pattern_tag_list = ''
    f.other_tag_list = 'Mango'
    validate_fabric_tags(f, 'Pattern', '')
    validate_fabric_tags(f, 'Other', 'Mango')
    expect(f.pattern_tag_list).to eql('')
    expect(f.other_tag_list).to eql('Mango')
    
    expect(Other.where(name:'Coconut')).not_to exist
    expect(Other.where(name:'Pineapple')).not_to exist
  end  

  it "updates all tag types using string list" do
    f = create(:fabric, tag_code: '')
    Tag.get_default_type_list.each do |type|
      expect(f.send("#{type.underscore}_tag_list")).to eql('')
      random_tags = rand(1..1000).to_s + ', ' + rand(1..1000).to_s
      f.send("#{type.underscore}_tag_list=", random_tags)
      validate_fabric_tags(f, type, random_tags)
      expect(f.send("#{type.underscore}_tag_list")).to eql(random_tags)
    end

    expect(f.tags.count).to eql(2 * Tag.get_default_type_list.count)
    f.tags = []
    expect(f.tags.count).to eql(0)
  end

  describe ".filter" do 
    before(:all) do
      @f1 = create(:fabric, width: 20)
      @f2 = create(:fabric, width: 30)
      @f3 = create(:fabric, width: 20)
    end

    after(:all) do
      @f1.destroy
      @f2.destroy
      @f3.destroy
      Tag.delete_all
    end    

    it "shows all fabrics with no filter" do
      result = Fabric.filter({})
      expect(result).to eq([@f1,@f2,@f3])
    end

    it "filters correctly filters fabrics with single width" do
      result = Fabric.filter({'width' => '20'})
      expect(result).to eq([@f1,@f3])

      result = Fabric.filter({'width' => '30'})
      expect(result).to eq([@f2])

      result = Fabric.filter({'width' => '50'})
      expect(result).to eq([])
    end

    it "filters correctly filters fabrics with multiple width" do
      result = Fabric.filter({'width' => '20,30'})
      expect(result).to eq([@f1,@f2,@f3])

      result = Fabric.filter({'width' => '30,60'})
      expect(result).to eq([@f2])

      result = Fabric.filter({'width' => '60,70'})
      expect(result).to eq([])
    end

  end  

end

