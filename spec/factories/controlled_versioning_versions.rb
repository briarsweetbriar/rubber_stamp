# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :controlled_versioning_version, :class => 'Version' do
    pending false
  end
end
