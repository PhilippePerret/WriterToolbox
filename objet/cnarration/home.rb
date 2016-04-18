# encoding: UTF-8
class Cnarration
class << self

  def dernier_inventaire
    SuperFile::new(_('cnarration_inventory.html')).read
  end

end #/<< self
end #/Cnarration
