# For more information on DiffMatchPatch, look here:
# https://github.com/elliotlaster/Ruby-Diff-Match-Patch

require "diff_match_patch_native"

class Revision::TextAttribute::Factory < Revision::TextAttribute

  attr_reader :attr, :dmp, :version, :version_attribute, :versionable
  attr_accessor :index
  def initialize(args)
    @version = args[:version]
    @versionable = @version.versionable
    @version_attribute = args[:version_attribute]
    @attr = args[:attr]
    @dmp = DiffMatchPatch.new
    @index = 0
  end

  def build
    diffs = build_diffs
    scan_for_changes(diffs)
  end

  private
  def build_diffs
    diffs = dmp.diff_main(version_attribute.old_value, attr.value, false)
    dmp.diff_cleanup_semantic!(diffs)
    diffs
  end

  def scan_for_changes(diffs)
    diffs.each { |diff| scan_for_change(diff) }
  end

  def scan_for_change(diff)
    diff = define_diff(diff)
    build_text_attribute(diff) if diff.type != :equality
    @index += diff.value.length
  end

  def build_text_attribute(diff)
    vta = version_attribute.version_text_attributes.build(text: diff.value)
    vta.deletion = true if diff.type == :deletion
    vta.index = index
  end

  def define_diff(diff)
    Diff.new(diff_type(diff[0]), diff[1])
  end

  def diff_type(type)
    case type
    when -1 then :deletion
    when 0 then :equality
    when 1 then :insertion
    end
  end

  Diff = Struct.new(:type, :value)

end