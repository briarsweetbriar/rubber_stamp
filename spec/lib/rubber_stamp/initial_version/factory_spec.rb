require 'spec_helper'

describe "InitialVersion::Factory" do

  before :each do
    @child_1 = build(:child_resource)
    @child_2 = build(:child_resource)
    @child_3 = build(:child_resource)
    @versionable = build(:parent_resource, child_resources: [@child_1, @child_2, @child_3])
    @version = @versionable.versions.build(initial: true)
  end

  context "#build" do
    before :each do
      InitialVersion::Factory.new(versionable: @versionable, version: @version).build
    end

    it "appends version_attributes onto the version for every attribute" do
      expect(@version.version_attributes.map{ |va| va.name }).to match_array ["r_boolean", "r_date", "r_datetime", "r_decimal", "r_float", "r_integer", "r_string", "r_text", "r_time"]
    end

    it "appends version_attributes onto the version for every child" do
      expect(@version.version_children.map{ |vc| vc.versionable }).to match_array [@child_1, @child_2, @child_3]
    end
  end

end