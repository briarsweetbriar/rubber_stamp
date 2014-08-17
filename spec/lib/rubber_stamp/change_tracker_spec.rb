require 'spec_helper'

describe "ChangeTracker" do

  before :each do
    @versionable = create(:parent_with_children)
    @first_child = @versionable.child_resources[0]
    @second_child = @versionable.child_resources[1]
    @version = @versionable.submit_revision(r_string: "new string",
      child_resources_attributes: [
        { id: @first_child.id, _destroy: true },
        { id: @second_child.id, r_string: "also new string" },
        { r_string: "brand new child" }
      ])
  end

  context "#all" do
    it "returns an array of length equal to the number of changed attributes and children" do
      expect(ChangeTracker.new(@version).all.length).to eq 4
    end

    it "returns an array containing ChangeTracker::Attribute objects" do
      expect(ChangeTracker.new(@version).all.first.class).to eq ChangeTracker::Attribute
    end

    it "returns an array containing ChangeTracker::Child objects" do
      expect(ChangeTracker.new(@version).all.last.class).to eq ChangeTracker::Child
    end
  end

  context "#attributes" do
    it "returns an array of length equal to the number of changed attributes" do
      expect(ChangeTracker.new(@version).attributes.length).to eq 1
    end

    it "returns an array of ChangeTracker::Attribute objects" do
      expect(ChangeTracker.new(@version).attributes.first.class).to eq ChangeTracker::Attribute
    end

    it "returns an array of ChangeTracker::Attribute objects with an appropriately set name attribute" do
      expect(ChangeTracker.new(@version).attributes.first.name).to eq "r_string"
    end

    it "returns an array of ChangeTracker::Attribute objects with an appropriately set old_value attribute" do
      expect(ChangeTracker.new(@version).attributes.first.old_value).to eq "my string"
    end

    it "returns an array of ChangeTracker::Attribute objects with an appropriately set new_value attribute" do
      expect(ChangeTracker.new(@version).attributes.first.new_value).to eq "new string"
    end
  end

  context "#children" do
    it "returns an array of length equal to the number of changed children" do
      expect(ChangeTracker.new(@version).children.length).to eq 3
    end

    it "returns an array of ChangeTracker::Child objects" do
      expect(ChangeTracker.new(@version).children.first.class).to eq ChangeTracker::Child
    end

    it "returns an array of ChangeTracker::Child objects with an appropriately set name attribute" do
      expect(ChangeTracker.new(@version).children.first.name).to eq "child_resources"
    end

    it "returns an array of ChangeTracker::Child objects appropriately marked for removal" do
      expect(ChangeTracker.new(@version).children.first.marked_for_removal?).to be_falsey
      expect(ChangeTracker.new(@version).children.last.marked_for_removal?).to be_truthy
    end

    it "returns an array of ChangeTracker::Child objects appropriately marked as new" do
      expect(ChangeTracker.new(@version).children.first.new?).to be_truthy
      expect(ChangeTracker.new(@version).children.last.new?).to be_falsey
    end
  end

end