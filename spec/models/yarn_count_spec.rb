require 'spec_helper'

describe YarnCount do

  it "should allow setting/getting string values" do
    yc = create(:yarn_count, 
                  warp_ply_count: 2,
                  warp_yarn_thickness: 40,
                  weft_ply_count: 4,
                  weft_yarn_thickness: 60)

    expect(yc.full_count).to eq('2/40s x 4/60s')

    yc = create(:yarn_count_string, full_count: '4/60s x 3/30s')
    expect(yc.weft_ply_count).to eq(3)
    expect(yc.weft_yarn_thickness).to eq(30)
    expect(yc.warp_ply_count).to eq(4)
    expect(yc.warp_yarn_thickness).to eq(60)
  end  

  it "should handle various string cases" do
    yc = create(:yarn_count_string, full_count: '4/60x3/30')
    expect(yc.full_count).to eq('4/60s x 3/30s')

    yc = create(:yarn_count_string, full_count: ' 4/60s x3/30 ')
    expect(yc.full_count).to eq('4/60s x 3/30s')

    yc = create(:yarn_count_string, full_count: '4/60 x   3/30s')
    expect(yc.full_count).to eq('4/60s x 3/30s')

    yc = create(:yarn_count_string, full_count: '40x60')
    expect(yc.full_count).to eq('40s x 60s')
  end

  it "should handle invalid values" do
    # expect(build(:yarn_count, 
    #               warp_ply_count: 0,
    #               warp_yarn_thickness: 0,
    #               weft_ply_count: 0,
    #               weft_yarn_thickness: 0)).not_to be_valid
  end

  it "should handle invalid string cases" do
    # expect(build(:yarn_count_string, full_count: '')).not_to be_valid
    # expect(build(:yarn_count_string, full_count: '50')).not_to be_valid
    # expect(build(:yarn_count_string, full_count: 'ax60')).not_to be_valid
    # expect(build(:yarn_count_string, full_count: '40xx60')).not_to be_valid
    # expect(build(:yarn_count_string, full_count: 'a/60x35')).not_to be_valid
    # expect(build(:yarn_count_string, full_count: 'a/bs x c/ds')).not_to be_valid
  end
  
end

describe Fabric do
  describe ".filter" do
    it "should correctly filter yarn counts" do
      f1 = create(:fabric, yarn_count: '4/60s x 3/30s')
      f2 = create(:fabric, yarn_count: '20s x 20s')
      f3 = create(:fabric, yarn_count: '4/60s x 3/30s')

      result = Fabric.filter({ 'yarn_count' => '20x20s' })
      expect(result).to eq([f2])

      result = Fabric.filter({ 'yarn_count' => '4/60x3/30' })
      expect(result).to eq([f1,f3])

      result = Fabric.filter({ 'yarn_count' => '60x30' })
      expect(result).to eq([])
    end    
  end

  it "should correctly filter multiple yarn count selection" do
  end

end