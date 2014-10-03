class Revision::DiffAttribute::Rewinder < Revision::DiffAttribute

  attr_reader :version_attribute, :version, :versionable
  attr_accessor :text
  def initialize(version_attribute, text)
    @version_attribute = version_attribute
    @version = version_attribute.version
    @versionable = @version.versionable
    @text = text
    @vtas = []
  end

  def recompile
    prepare_vtas
    rewind
    fastforward
    return @text
  end

  private
  def prepare_vtas
    prior_versions = versionable.versions.where(
                      "accepted_at > ? AND id != ?", version.created_at, version.id
                     ).order('accepted_at DESC')
    prior_versions.each do |prior_version|
      prior_version_attribute = prior_version.version_attributes.find_by(name: version_attribute.name)
      @vtas.push(prior_version_attribute.diff_attributes)
    end
    @vtas.flatten!
  end

  def rewind
    remove_duplicate_changes
    @vtas.sort_by{|vta| vta.index}.each do |vta|
      vta.deletion? ? insert_vta(vta) : delete_vta(vta)
    end
  end

  def fastforward
    merge_in_new_changes
    remove_duplicate_changes
    @vtas.sort{ |a, b| b.index <=> a.index }.each do |vta|
      vta.deletion? ? delete_vta(vta) : insert_vta(vta)
    end
  end

  def insert_vta(vta)
    @text.insert(vta.index, vta.text)
  end

  def delete_vta(vta)
    @text[vta.index, vta.text.length] = ""
  end

  def merge_in_new_changes
    @vtas.push(@version_attribute.diff_attributes).flatten!
  end

  def remove_duplicate_changes
    @vtas.delete_if do |this_vta|
      other_vta_count = 0
      @vtas.each do |other_vta|
        other_vta_count += 1 if this_vta.text == other_vta.text && this_vta.index == other_vta.index && this_vta.deletion == other_vta.deletion
      end
      other_vta_count > 1
    end
  end

end