FactoryGirl.define do
  factory :partially_exclusive_versionable_resource do
    r_boolean true
    r_date Date.today
    r_datetime DateTime.now
    r_decimal 3.14
    r_float 3.14
    r_integer 3
    r_string "my string"
    r_text "my text"
    r_time Time.now

    initialize_with { PartiallyExclusiveVersionableResource.create_with_version(attributes) }

  end
end
