require 'spec_helper'

describe ReedPick do

  it "should destroy itself if parent fabric destroyed" do
    f1 = create(:fabric, reed_pick: '45/65')
    f2 = create(:fabric, reed_pick: '45/65')
    expect(ReedPick.count).to eq(2)
    f1.destroy
    f2.reload
    expect(ReedPick.count).to eq(1)
    expect(f2.reed_pick).to eq(ReedPick.first)
    f2.destroy
    expect(ReedPick.count).to eq(0)
  end

  it "should allow setting/getting string values" do
    rp = create(:reed_pick, reed: 24, pick: 32)
    expect(rp.full_reed_pick).to eq('24/32')

    rp = create(:reed_pick_string, full_reed_pick: '54/67')
    expect(rp.reed).to eq(54)
    expect(rp.pick).to eq(67)
  end

  it "should not allow setting of invalid reed pick" do
    expect(build(:reed_pick_string, full_reed_pick: '34\56')).not_to be_valid
    expect(build(:reed_pick_string, full_reed_pick: 'a/45')).not_to be_valid
    expect(build(:reed_pick_string, full_reed_pick: '56/b')).not_to be_valid
  end

  it "should not allow nil reed or pick" do
    expect(build(:reed_pick, reed: nil, pick: 24)).not_to be_valid
    expect(build(:reed_pick, reed: 45, pick: nil)).not_to be_valid
    expect(build(:reed_pick, reed: nil, pick: nil)).not_to be_valid
  end
end

describe Fabric do
  describe ".filter" do
    before(:all) do
      @f1 = create(:fabric, reed_pick: '45/65')
      @f2 = create(:fabric, reed_pick: '35/68')
      @f3 = create(:fabric, reed_pick: '45/65')
      @f4 = create(:fabric, reed_pick: '25/65')
    end

    after(:all) do
      @f1.destroy
      @f2.destroy
      @f3.destroy
      @f4.destroy
      Tag.delete_all
    end    

    it "should correctly filter reed picks" do
      result = Fabric.filter({ 'reed_pick' => '35/68' })
      expect(result).to eq([@f2])

      result = Fabric.filter({ 'reed_pick' => '45/65' })
      expect(result).to eq([@f1,@f3])

      result = Fabric.filter({ 'reed_pick' => '45/60' })
      expect(result).to eq([])
    end

    it "should correctly filter multiple reed pick selection" do
      result = Fabric.filter({ 'reed_pick' => '35/68, 25/65' })
      expect(result).to eq([@f2,@f4])
    end

  end
end

