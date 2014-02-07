require 'spec_helper'

describe ControlledVersioning::Version do

  it 'returns a hash of changed attributes' do
    resource = create(:versionable_resource)
    version = resource.submit_revision(r_string: "new string", r_float: 90.1)
    expect(version.changes).to eq "r_string" => { new_value: "new string",
      old_value: "my string" }, "r_float" => { new_value: "90.1",
      old_value: "3.14" }
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
