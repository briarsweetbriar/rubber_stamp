FactoryGirl.define do
  factory :version, class: "RubberStamp::Version" do
    versionable { create(:versionable_resource) }

  end
end
