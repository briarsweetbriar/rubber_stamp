# require 'spec_helper'

# describe "Revision::TextAttribute::Factory" do

#   context "#build" do

#     before :each do
#       @versionable = create(:versionable_resource, r_text: "This is a very long string, with many things to change and some things to keep.")
#       @version = @versionable.submit_revision(r_text: "This was once a very short string with many things.")
#       @version_attribute = @version.version_attributes.first
#     end

#     it "creates a version_attribute for the version" do
#       expect(@version.version_attributes.size).to eq 1
#     end

#     it "assigns the version_attribute an old_value" do
#       expect(@version_attribute.old_value.present?).to be_truthy
#     end

#     it "does not assign the version_attribute a new_value" do
#       expect(@version_attribute.new_value.present?).to be_falsey
#     end

#     it "creates version_text_attributes for the version_attribute" do
#       expect(@version_attribute.version_text_attributes.size).to eq 6
#     end

#     it "marks some version_text_attributes for deletion" do
#       deletions = @version_attribute.version_text_attributes.deletions
#       expect(deletions.map { |deletion| deletion.text }).to match_array(["is", "long", ",", " to change and some things to keep"])
#     end

#     it "marks some version_text_attributes for insertion" do
#       insertions = @version_attribute.version_text_attributes.insertions
#       expect(insertions.map { |insertion| insertion.text }).to match_array(["was once", "short"])
#     end

#     it "assigns an index to each version_text_attribute" do
#       version_text_attribute = @version_attribute.version_text_attributes[3]
#       expect(version_text_attribute.index).to eq 23
#     end
#   end

# end