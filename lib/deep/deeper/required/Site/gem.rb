# encoding: UTF-8
class SiteHtml
  def require_gem gem_name, version = nil
    FakeGem::new(gem_name, version).require_gem
  rescue Exception => e
    error "Impossible de requérir le gem #{gem_name} : #{e.message}"
  end

  # Pour requérir un gem dans le dossier ./lib/deep/deeper/gem
  def require_deeper_gem folder_name
    gem_name = folder_name.split('-')[0]
    $LOAD_PATH << "./lib/deep/deeper/gem/#{folder_name}/lib"
    require gem_name
  end
end
