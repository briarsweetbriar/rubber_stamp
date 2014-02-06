require 'spec_helper'

describe "ControlledVersioning" do

  it 'sets the initial version contributor if one is provided' do
    user = create(:user)
    resource = create(:versionable_resource, user: user)
    expect(resource.initial_version.user).to eq user
  end

  it 'does not set the initial version contributor if one is not provided' do
    resource = create(:versionable_resource)
    expect(resource.initial_version.user).to be_nil
  end

  it 'sets the revision contributor if they are provided' do
    user = create(:user)
    resource = create(:versionable_resource)
    revision = resource.submit_revision(r_string: "new string",
          r_float: 90.1, user: user)
    expect(revision.user).to eq user
  end

  it 'does not set the revision contributor if they are not provided' do
    resource = create(:versionable_resource)
    revision = resource.submit_revision(r_string: "new string",
          r_float: 90.1)
    expect(revision.user).to be_nil
  end

  it 'writes initial version notes if they are provided' do
    notes = "These are my notes"
    resource = create(:versionable_resource, notes: notes)
    expect(resource.initial_version.notes).to eq notes
  end

  it 'does not write initial version notes if they are not provided' do
    resource = create(:versionable_resource)
    expect(resource.initial_version.notes).to be_nil
  end

  it 'writes revision notes if they are provided' do
    notes = "These are my notes"
    resource = create(:versionable_resource)
    revision = resource.submit_revision(r_string: "new string",
          r_float: 90.1, notes: notes)
    expect(revision.notes).to eq notes
  end

  it 'does not write revision notes if they are not provided' do
    resource = create(:versionable_resource)
    revision = resource.submit_revision(r_string: "new string",
          r_float: 90.1)
    expect(revision.notes).to be_nil
  end

  context 'by default' do
    before :each do
      @resource = create(:versionable_resource)
    end

    it 'returns a list of versionable attributes' do
      expect(@resource.versionable_attributes).to eq(
        @resource.attributes.except("id", "updated_at", "created_at"))
    end

    it 'returns the initial version' do
      @resource.versions.create
      @resource.versions.create
      expect(@resource.initial_version).to eq(
        @resource.versions.find_by(initial: true))
    end

    it "rejects revisions with invalid changes" do
      version = @resource.submit_revision(r_string: "new string",
        r_float: 9000000.1)
      expect(version).to have(1).error_on(:r_float)
    end

    it "rejects revisions that make no changes" do
      version = @resource.submit_revision(@resource.versionable_attributes)
      expect(version).to have(1).error
    end

    context 'handles revision' do
      before :each do
        @version = @resource.submit_revision(r_string: "new string",
          r_float: 90.1)
      end

      it 'by creating versions with the suggested attributes' do
        @resource.reload
        r_string = @version.version_attributes.find_by(name: "r_string")
        r_float = @version.version_attributes.find_by(name: "r_float")
        expect(r_string.old_value).to eq("my string")
        expect(r_string.new_value).to eq("new string")
        expect(r_float.old_value).to eq("3.14")
        expect(r_float.new_value).to eq("90.1")
        expect(@resource.r_string).to eq("my string")
        expect(@resource.r_float).to eq(3.14)
      end

      it "by skipping non-revised attributes" do
        expect(@version.version_attributes.find_by(name: "r_text")).to be_nil
      end

      it 'by updating model data if its revisions are accepted' do
        @version.accept
        @resource.reload
        @version.reload
        expect(@resource.r_string).to eq "new string"
        expect(@resource.r_float).to eq 90.1
        expect(@version.pending).to eq false
        expect(@version.declined).to eq false
        expect(@version.accepted).to eq true
      end

      it 'by maintaining model data if its revisions are declined' do
        @version.decline
        @resource.reload
        @version.reload
        expect(@resource.r_string).to eq "my string"
        expect(@resource.r_float).to eq 3.14
        expect(@version.pending).to eq false
        expect(@version.declined).to eq true
        expect(@version.accepted).to eq false
      end

      it 'by not updating model data if the initial version is accepted' do
        @version.accept
        @resource.initial_version.accept
        @resource.reload
        expect(@resource.r_string).to eq "new string"
        expect(@resource.r_float).to eq 90.1
      end
    end
  end

  context 'with nested attributes' do
    before :each do
      @resource = create(:parent_with_grand_children)
    end

    it 'creates version children' do
      expect(@resource.initial_version.version_children.length).to eq 3
      expect(@resource.initial_version.version_children.last.version_children.
        length).to eq 3
    end

    it 'rejects invalid children' do
      first_child_resource = @resource.child_resources.first
      version = @resource.submit_revision(child_resources_attributes: [
        {id: first_child_resource.id, r_float: 90000000000.6}
      ])
      expect(version).to have(1).error
    end

    context 'handles revision' do
      before :each do
        @first_child_resource = @resource.child_resources[0]
        @version = @resource.submit_revision(child_resources_attributes: [
          {id: @first_child_resource.id, r_string: "new string"}
        ])
      end

      it 'by creating versions for its children' do
        expect(@version.version_children.length).to eq 1
        changed_attribute = @version.version_children.
                            find_by(versionable: @first_child_resource).
                            version_attributes.find_by(name: "r_string")
        expect(changed_attribute.new_value).to eq "new string"
        expect(changed_attribute.old_value).to eq "my string"
      end

      it 'by updating its children data if its revisions are approved' do
        @version.accept
        @first_child_resource.reload
        expect(@first_child_resource.r_string).to eq "new string"
      end
    end

    context 'handles revision for deeply nested children' do
      before :each do
        @first_child_resource = @resource.child_resources[0]
        @first_grand_child_resource = @first_child_resource.
                                      grand_child_resources.first
        @version = @resource.submit_revision(child_resources_attributes: [
          {id: @first_child_resource.id, grand_child_resources_attributes: [
            {id: @first_grand_child_resource.id, r_string: "new string"}
          ]}
        ])
        @child_version = @version.version_children.
                         find_by(versionable_id: @first_child_resource.id)
      end

      it 'by creating versions for the full family' do
        expect(@child_version.version_children.length).to eq 1
        changed_attribute = @child_version.version_children.
                            find_by(versionable: @first_grand_child_resource).
                            version_attributes.find_by(name: "r_string")
        expect(changed_attribute.new_value).to eq "new string"
        expect(changed_attribute.old_value).to eq "my string"
      end

      it 'by updating its deeply nested data if its revisions are approved' do
        @version.accept
        @first_grand_child_resource.reload
        expect(@first_grand_child_resource.r_string).to eq "new string"
      end
    end

    context 'handles new children' do
      before :each do
        @version = @resource.submit_revision(child_resources_attributes: [
          {r_float: 14.0}
        ])
        @child_version = @version.version_children.first
      end

      it 'by creating version for new children' do
        expect(@version.version_children.length).to eq 1
      end

      it 'by creating attributes for new children' do
        changed_attribute = @child_version.version_attributes.
                            find_by(name: "r_float")
        expect(changed_attribute.new_value).to eq "14.0"
        expect(changed_attribute.old_value).to be_nil
      end

      it 'by creating new children when approved' do
        @version.accept
        @resource.reload
        expect(@resource.child_resources.find_by(r_float: 14.0)).to_not be_nil
      end
    end

    context 'handles child destruction' do
      before :each do
        @first_child_resource = @resource.child_resources[0]
        @version = @resource.submit_revision(child_resources_attributes: [
          {id: @first_child_resource.id, _destroy: "1"}
        ])
        @child_version = @version.version_children.find_by(versionable_id:
                         @first_child_resource.id)
      end

      it 'by creating a version for the marked child' do
        expect(@version.version_children.length).to eq 1
      end

      it 'by marking a resource for removal if _destroy is sent' do
        expect(@child_version.marked_for_removal).to be true
      end

      it 'by preserving a resource until its mark is approved' do
        @first_child_resource.reload
        expect(@first_child_resource).to be_an_instance_of(ChildResource)
      end

      it 'by removing a resource if its mark was approved' do
        @version.accept
        @resource.reload
        expect(@resource.child_resources.length).to eq 2
      end
    end
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