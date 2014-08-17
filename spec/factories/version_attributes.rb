FactoryGirl.define do
  factory :version_attribute, class: "RubberStamp::VersionAttribute" do
    version { create(:version) }
    name "r_string"
    old_value "old value"
    new_value "new value"

  end
end
