FactoryGirl.define do
  factory :version_child, class: "RubberStamp::VersionChild" do
    version { create(:version) }
    association_name "ChildResource"

  end
end
