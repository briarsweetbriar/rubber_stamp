require 'spec_helper'

describe ControlledVersioning::Version do

  context 'returns a hash of' do
    before :each do
      @resource = ParentResource.create_with_version({ r_string: "my string",
        r_float: 3.14, child_resources_attributes: [
          { r_string: "my string", r_float: 3.14,
            grand_child_resources_attributes: [
              { r_string: "my string", r_float: 3.14 },
              { r_string: "my string", r_float: 3.14 },
              { r_string: "my string", r_float: 3.14 }
            ] },
          { r_string: "my string", r_float: 3.14,
            grand_child_resources_attributes: [
              { r_string: "my string", r_float: 3.14 },
              { r_string: "my string", r_float: 3.14 },
              { r_string: "my string", r_float: 3.14 }
            ] },
          { r_string: "my string", r_float: 3.14,
            grand_child_resources_attributes: [
              { r_string: "my string", r_float: 3.14 },
              { r_string: "my string", r_float: 3.14 },
              { r_string: "my string", r_float: 3.14 }
            ] }
        ] })
    end

    it 'changed attributes' do
      version = @resource.submit_revision(r_string: "new string")
      changed_attribute = version.versionable_changes.attributes.first
      expect(changed_attribute.name).to eq "r_string"
      expect(changed_attribute.old_value).to eq "my string"
      expect(changed_attribute.new_value).to eq "new string"
    end

    it 'changed children' do
      first_child_resource = @resource.child_resources[0]
      version = @resource.submit_revision(child_resources_attributes: [
        {id: first_child_resource.id, r_string: "new string"}
      ])
      changed_child = version.versionable_changes.children.first
      changed_attribute = changed_child.attributes.first
      expect(changed_child.name).to eq "child_resources"
      expect(changed_attribute.name).to eq "r_string"
      expect(changed_attribute.old_value).to eq "my string"
      expect(changed_attribute.new_value).to eq "new string"
    end

    it 'changed deeply nested children' do
      first_child_resource = @resource.child_resources[0]
      first_grand_child_resource = first_child_resource.
                                    grand_child_resources.first
      version = @resource.submit_revision(child_resources_attributes: [
        {id: first_child_resource.id, grand_child_resources_attributes: [
          {id: first_grand_child_resource.id, r_string: "new string"}
        ]}
      ])
      changed_child = version.versionable_changes.children.first
      changed_grand_child = changed_child.children.first
      changed_attribute = changed_grand_child.attributes.first
      expect(changed_grand_child.name).to eq "grand_child_resources"
      expect(changed_attribute.name).to eq "r_string"
      expect(changed_attribute.old_value).to eq "my string"
      expect(changed_attribute.new_value).to eq "new string"
    end

    it 'new children' do
      version = @resource.submit_revision(child_resources_attributes: [
        {r_float: 3.14}
      ])
      changed_child = version.versionable_changes.children.first
      changed_attribute = changed_child.attributes.first
      expect(changed_child.new?).to be_true
      expect(changed_attribute.name).to eq "r_float"
      expect(changed_attribute.old_value).to be_nil
      expect(changed_attribute.new_value).to eq "3.14"
    end

    it 'marked children' do
      first_child_resource = @resource.child_resources[0]
      version = @resource.submit_revision(child_resources_attributes: [
        {id: first_child_resource.id, _destroy: true}
      ])
      changed_child = version.versionable_changes.children.first
      expect(changed_child.marked_for_removal?).to be_true
    end
  end

  context 'has a scope that' do
    before :each do
      @resource = create(:versionable_resource)
      @accepted_1 = @resource.submit_revision(r_string: "accepted 1")
      @accepted_2 = @resource.submit_revision(r_string: "accepted 2")
      @declined_1 = @resource.submit_revision(r_string: "declined 1")
      @declined_2 = @resource.submit_revision(r_string: "declined 2")
      @pending_1 = @resource.initial_version
      @pending_2 = @resource.submit_revision(r_string: "pending 2")
      @accepted_1.accept
      @accepted_2.accept
      @declined_1.decline
      @declined_2.decline
    end

    it 'returns an array of pending versions' do
      expect(@resource.versions.pending).to match_array(
        [@pending_1, @pending_2])
    end

    it 'returns an array of accepted versions' do
      expect(@resource.versions.accepted).to match_array(
        [@accepted_1, @accepted_2])
    end

    it 'returns an array of declined versions' do
      expect(@resource.versions.declined).to match_array(
        [@declined_1, @declined_2])
    end
  end

end
