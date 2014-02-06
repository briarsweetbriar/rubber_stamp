class AttributeEncapsulator

  attr_reader :attr
  def initialize(attr)
    @attr = AttrStruct.new(attr[0], attr[1])
  end

  def key
    attr.key
  end

  def value
    attr.value
  end

  private
  AttrStruct = Struct.new(:key, :value)
end