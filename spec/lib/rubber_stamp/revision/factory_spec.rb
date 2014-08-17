require 'spec_helper'

describe "Revision::Factory" do

  before :each do
    @versionable = create(:parent_with_children)
    @child_1 = @versionable.child_resources[0]
    @child_2 = @versionable.child_resources[1]
  end

  context "#build" do
    before :each do
      suggested_attributes = {r_string: "new string", r_integer: 11, child_resources_attributes: [{ id: @child_1.id, _destroy: true }, { id: @child_2.id, r_string: "new string"}, { r_string: "new child" }]}
      Revision::Factory.new(versionable: @versionable, suggested_attributes: suggested_attributes).build
      @version = @versionable.versions.last
    end

    it "appends version_attributes onto the version for every attribute" do
      expect(@version.version_attributes.map{ |va| va.name }).to match_array ["r_string", "r_integer"]
    end

    it "appends version_children onto the version for every child" do
      expect(@version.version_children.map{ |vc| vc.versionable }).to match_array [@child_1, @child_2, nil]
    end

    it "marks deleted children" do
      expect(@version.version_children.first.marked_for_removal?).to be_truthy
      expect(@version.version_children.last.marked_for_removal?).to be_falsey
    end
  end

  it "#build rejects revisions with invalid changes" do
    resource = create(:validating_resource)
    version = resource.submit_revision(r_string: "new string",
      r_float: 9000000.1)
    expect(version.errors.size).to eq(1)
  end

end