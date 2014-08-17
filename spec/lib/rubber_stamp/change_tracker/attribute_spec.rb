require 'spec_helper'

describe "ChangeTracker::Attribute" do

  before :each do
    @version_attribute = create(:version_attribute)
  end

  context "#name" do
    it "returns the name of the version attribute" do
      expect(ChangeTracker::Attribute.new(@version_attribute).name).to eq @version_attribute.name
    end
  end

  context "#old_value" do
    it "returns the old_value of the version attribute" do
      expect(ChangeTracker::Attribute.new(@version_attribute).old_value).to eq @version_attribute.old_value
    end
  end

  context "#new_value" do
    it "returns the new_value of the version attribute" do
      expect(ChangeTracker::Attribute.new(@version_attribute).new_value).to eq @version_attribute.new_value
    end
  end

end