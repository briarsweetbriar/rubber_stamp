class DiffResource < ActiveRecord::Base
  acts_as_versionable diff_attribute_names: [:r_text]
end
