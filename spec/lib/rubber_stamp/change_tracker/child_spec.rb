require 'spec_helper'

describe "ChangeTracker::Child" do

  context "#name" do
    it "returns the name of the association" do
      version_child = create(:version_child, association_name: "ChildResource")
      expect(ChangeTracker::Child.new(version_child).name).to eq version_child.association_name
    end
  end

  context "#marked_for_removal?" do
    it "returns true if the child is marked for marked_for_removal" do
      version_child = create(:version_child, marked_for_removal: true)
      expect(ChangeTracker::Child.new(version_child).marked_for_removal?).to be_truthy
    end

    it "returns false if the child is not marked for marked_for_removal" do
      version_child = create(:version_child, marked_for_removal: false)
      expect(ChangeTracker::Child.new(version_child).marked_for_removal?).to be_falsey
    end
  end

  context "#new?" do
    it "returns true if the child is new" do
      version_child = create(:version_child)
      expect(ChangeTracker::Child.new(version_child).new?).to be_truthy
    end

    it "returns false if the child is an edit of a preexisting versionable" do
      version_child = create(:version_child, versionable: create(:versionable_resource))
      expect(ChangeTracker::Child.new(version_child).new?).to be_falsey
    end
  end

end