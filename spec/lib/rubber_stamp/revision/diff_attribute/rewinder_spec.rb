require 'spec_helper'

describe "Revision::DiffAttribute::Rewinder" do

  before :each do
    @versionable = create(:diff_resource, r_text: "This is the original txt. It has a ommissions and mispelings.")
    @version1 = @versionable.submit_revision({ r_text: "This is the revised text. It has a few ommissions and mispelings." })
    @version2 = @versionable.submit_revision({ r_text: "This is the revised text. It has a ommissions and mispellings." })
  end

  it "#recompile" do
    @versionable.reload
    new_value = Revision::DiffAttribute::Rewinder.new(@version2.version_attributes.first, @versionable.r_text).recompile
    expect(new_value).to eq "This is the revised text. It has a ommissions and mispellings."
  end


  it "updates the versionable with async revisions" do
    @version2.accept
    @version1.accept
    @versionable.reload
    expect(@versionable.r_text).to eq "This is the revised text. It has a few ommissions and mispellings."
  end


  it "when async revising, only refers to revisions accepted since submission" do
    @version2.accept
    @version1.accept
    @versionable.reload
    version3 = @versionable.submit_revision({ r_text: "This is the revised text. Yo! It has a few ommissions and mispellings." })
    version4 = @versionable.submit_revision({ r_text: "Pretext. This is the revised text. It has a few ommissions and mispellings." })
    version4.accept
    version3.accept
    @versionable.reload
    expect(@versionable.r_text).to eq "Pretext. This is the revised text. Yo! It has a few ommissions and mispellings."
  end

end