require 'spec_helper'

describe "RubberStamp" do

  it 'sets the initial version contributor if one is provided' do
    user = create(:user)
    resource = create(:versionable_resource, user: user)
    expect(resource.initial_version.user).to eq user
  end

  it 'sets the revision contributor if they are provided' do
    user = create(:user)
    resource = create(:versionable_resource)
    revision = resource.submit_revision(r_string: "new string", user: user)
    expect(revision.user).to eq user
  end

  it 'writes initial version notes if they are provided' do
    notes = "These are my notes"
    resource = create(:versionable_resource, notes: notes)
    expect(resource.initial_version.notes).to eq notes
  end

  it 'writes revision notes if they are provided' do
    notes = "These are my notes"
    resource = create(:versionable_resource)
    revision = resource.submit_revision(r_string: "new string", notes: notes)
    expect(revision.notes).to eq notes
  end

  context "#nested_associations" do
    it 'returns a list of nested_associations' do
      expect(ParentResource.nested_associations).to match_array [:child_resources]
    end
  end

  context "#has_nested_associations?" do
    it "returns true if it has nested associations" do
      expect(ParentResource.has_nested_associations?).to be_truthy
    end

    it "returns false if it has no nested associations" do
      expect(VersionableResource.has_nested_associations?).to be_falsey
    end
  end

  context "#is_a_nested_association" do
    it "returns true if acts_as_versionable received the nested_within option" do
      resource = create(:child_resource)
      expect(resource.is_a_nested_association?).to be_truthy
    end

    it "returns false if acts_as_versionable did not receive the nested_within option" do
      resource = create(:versionable_resource)
      expect(resource.is_a_nested_association?).to be_falsey
    end
  end

  context "#new_with_version" do
    before :each do
      @resource = VersionableResource.new_with_version(r_string: "I'm new!")
    end

    it "creates a version" do
      expect(@resource.versions.first.present?).to be_truthy
    end

    it "instantiates the record" do
      expect(@resource.new_record?).to be_truthy
    end
  end

  context "#new_with_version" do
    before :each do
      @resource = VersionableResource.create_with_version(r_string: "I'm new!")
    end

    it "creates a version" do
      expect(@resource.initial_version.present?).to be_truthy
    end

    it "creates the record" do
      expect(@resource.persisted?).to be_truthy
    end
  end

  context "#initial_version" do
    it "returns the initial version" do
      resource = create(:versionable_resource)
      resource.submit_revision(r_string: "new string")
      resource.submit_revision(r_float: 63.5)
      expect(resource.initial_version).to eq(resource.versions.find_by(initial: true))
    end
  end

  context "#versionable_attributes" do
    it 'returns a list of versionable attributes' do
      resource = create(:versionable_resource)
      expect(resource.versionable_attributes).to eq(resource.attributes.except("id", "updated_at", "created_at"))
    end
  end

  context "#submit_revision" do
    before :each do
      @resource = create(:versionable_resource)
    end

    it "rejects revisions that make no changes" do
      version = @resource.submit_revision(@resource.versionable_attributes)
      expect(version.errors.size).to eq(1)
    end

    context "succeeding" do
      before :each do
        @version = @resource.submit_revision(r_string: "new string", r_float: 90.1)
      end

      it 'creates versions with the suggested attributes' do
        r_string = @version.version_attributes.find_by(name: "r_string")
        r_float = @version.version_attributes.find_by(name: "r_float")
        expect(r_string.old_value).to eq("my string")
        expect(r_string.new_value).to eq("new string")
        expect(r_float.old_value).to eq("3.14")
        expect(r_float.new_value).to eq("90.1")
      end

      it "doesn't alter revised attributes on the versionable model" do
        @resource.reload
        expect(@resource.r_string).to eq("my string")
        expect(@resource.r_float).to eq(3.14)
      end

      it "skips non-revised attributes" do
        expect(@version.version_attributes.find_by(name: "r_text")).to be_nil
      end
    end

    # context 'handles revision of texts' do
    #   before :each do
    #     @version = @resource.submit_revision(r_text: "this text is revised")
    #   end

    #   it 'by creating versions with the suggested attributes' do
    #     @resource.reload
    #     version_attribute = @version.version_attributes.find_by(name: "r_text")
    #     expect(version_attribute.diff_attributes.size).to eq(3)
    #   end

    #   it 'by updating model data if its revisions are accepted' do
    #     @version.accept
    #     @resource.reload
    #     expect(@resource.r_text).to eq "this text is revised"
    #   end

    #   it 'by maintaining model data if its revisions are declined' do
    #     @version.decline
    #     @resource.reload
    #     expect(@resource.r_text).to eq "my text"
    #   end
    # end
  end

  context 'with versionable_attributes' do
    it 'returns a list of versionable attributes' do
      resource = create(:partially_inclusive_versionable_resource)
      expect(resource.versionable_attributes).to eq(
        resource.attributes.slice("r_boolean", "r_date"))
    end
  end

  context 'with nonversionable_attributes' do
    it 'returns a list of versionable attributes' do
      resource = create(:partially_exclusive_versionable_resource)
      expect(resource.versionable_attributes).to eq(
        resource.attributes.except("id", "updated_at", "created_at",
          "r_boolean", "r_date"))
    end
  end
end