class ArrayConverter

  def self.to_s!(array)
    array.map! { |s| s.to_s } if array.present?
  end
end