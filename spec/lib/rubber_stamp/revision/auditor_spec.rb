require 'spec_helper'

describe "Revision::Auditor" do

  before :each do
    @versionable = create(:parent_with_children)
    @child_1 = @versionable.child_resources[0]
  end

  context "#changes_original?" do
    it "returns true if an attribute has changed" do
      @versionable.assign_attributes(r_string: "new string")
      expect(Revision::Auditor.new(@versionable).changes_original?).to be_truthy
    end

    it "returns true if a child resource's attribute has changed" do
      @versionable.assign_attributes(child_resources_attributes: [{ id: @child_1.id, r_string: "new string" }])
      expect(Revision::Auditor.new(@versionable).changes_original?).to be_truthy
    end

    it "returns true if a child resource is marked_for_destruction" do
      @versionable.assign_attributes(child_resources_attributes: [{ id: @child_1.id, _destroy: true }])
      expect(Revision::Auditor.new(@versionable).changes_original?).to be_truthy
    end

    it "returns false if neither it nor its children have changed" do
      @versionable.assign_attributes(r_string: "my string")
      expect(Revision::Auditor.new(@versionable).changes_original?).to be_falsey
    end
  end

end