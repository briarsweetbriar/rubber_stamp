FactoryGirl.define do
  factory :child_resource do

    parent_resource

    r_boolean true
    r_date Date.today
    r_datetime DateTime.now
    r_decimal 3.14
    r_float 3.14
    r_integer 3
    r_string "my string"
    r_text "my text"
    r_time Time.now

    factory :child_with_grand_children do
        ignore do
            grand_children_count 3
        end

        before(:create) do |child, evaluator|
            create_list(:grand_child_resource, evaluator.grand_children_count,
                child_resource: child)
        end
    end

  end
end
