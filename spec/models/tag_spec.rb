require 'spec_helper'

shared_examples "a tag" do |type, locked|

  it "has a valid factory" do
    expect(create(described_class)).to be_valid
  end

  it "is invalid without a name" do
    expect(build(described_class, name: nil)).not_to be_valid
  end

  it "has a unique name" do
    create(described_class, name: 'Coconut')
    expect(build(described_class, name: 'Coconut')).not_to be_valid
  end

  it "is always of type #{type} " do
    expect(build(described_class).type).to eql(type)
  end

  context "class" do
    _not = (locked) ? "" : "not"
    it "is #{_not} locked for external modification" do
      expect(described_class.block_user_input?).to eql(locked)
    end
  end  

end

describe Pattern do
  it_behaves_like "a tag", "Pattern", true
end

describe Other do
  it_behaves_like "a tag", "Other", false
end

describe Content do
  it_behaves_like "a tag", "Content", false
end

describe Season do
  it_behaves_like "a tag", "Season", true
end
describe Weave do
  it_behaves_like "a tag", "Weave", true
end

describe BestFor do
  it_behaves_like "a tag", "BestFor", true
end

describe Tag do
  it "cannot create a null type object" do
    expect(Tag.new(name: 'blah', type: nil)).not_to be_valid
  end

  it "returns tag type list" do
    $tag_types.each do |t|
      create(t.underscore.to_sym)
    end
    create(:best_for)
    expect(Tag.get_type_list) =~ $tag_types
    expect(Tag.get_type_list).to include("BestFor")
  end

  it "returns array of names ordered by fabric count" do
    create(:fabric, tag_code: 'p-c-s-v')
    create(:fabric, tag_code: 'p-s-v')
    create(:fabric, tag_code: 'p-s')
    expect(Pattern.get_name_list) == ['Stripes', 'Voile', 'Checks']
    expect(Tag.get_name_list) == ['Stripes', 'Voile', 'Checks']
    expect(Tag.get_name_list) != ['Checks', 'Voile', 'Stripes']
  end

  it "destroys mutable and preserves immutable tag when fabric count reaches 0" do
    create(:pattern, name: 'Checks')
    f1 = create(:fabric, tag_code: 'p-c_o-blah')
    f2 = create(:fabric, tag_code: 'p-c_o-blah')
    expect(Pattern.where(name: 'Checks')).to exist
    expect(Other.where(name: 'Blah')).to exist
    
    expect(f1.destroy).to be_true
    expect(Pattern.where(name: 'Checks')).to exist
    expect(Other.where(name: 'Blah')).to exist

    expect(f2.destroy).to be_true
    expect(Pattern.where(name: 'Checks')).to exist
    expect(Other.where(name: 'Blah')).not_to exist
  end

end

describe Fabric do
  describe ".filter" do 
    before(:all) do
      @f1 = create(:fabric, tag_code: 'p-c-s-v_o-blah')
      @f2 = create(:fabric, tag_code: 'p-s-v')
      @f3 = create(:fabric, tag_code: 'p-s')
    end

    after(:all) do
      @f1.destroy
      @f2.destroy
      @f3.destroy
      Tag.delete_all
    end    

    it "filters for tags with one pattern type and one name" do
      result = Fabric.filter({ 'Pattern' => ['Checks']})
      expect(result).to eq([@f1])
    end

    it "filters for tags with multiple names from the same type" do 
      # Use OR within the same type
      result = Fabric.filter({'Pattern' => ['Checks', 'Voile']})
      expect(result).to eq([@f1,@f2])      
    end

    it "filters for tags with multiple names from multiple types" do
      result = Fabric.filter({'Pattern' => 'Voile', 'Other' => 'Blah'})
      expect(result).to eq([@f1])

      result = Fabric.filter({'Pattern' => 'Voile', 'Other' => 'Coconut'})
      expect(result).to eq([])
    end
  end
end