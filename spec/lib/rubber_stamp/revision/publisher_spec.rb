require 'spec_helper'

describe "Revision::Publisher" do

  before :each do
    @versionable = create(:parent_with_children)
    @child_1 = @versionable.child_resources[0]
    @child_2 = @versionable.child_resources[1]
    @version = @versionable.submit_revision({r_string: "new string", r_integer: 11, child_resources_attributes: [{ id: @child_1.id, _destroy: true }, { id: @child_2.id, r_string: "new string"}, { r_string: "new child" }]})
  end

  context "#accept_revision" do
    before :each do
      Revision::Publisher.new(@version).accept_revision
    end

    it "updates the versionable" do
      expect(@versionable.r_string).to eq "new string"
      expect(@versionable.r_integer).to eq 11
    end

    it "updates the attributes to altered children" do
      expect(@child_2.r_string).to eq "new string"
    end

    it "destroys unwanted children" do
      expect(@child_1.persisted?).to be_falsey
    end

    it "creates new children" do
      expect(@versionable.child_resources.last.r_string).to eq "new child"
    end
  end

end