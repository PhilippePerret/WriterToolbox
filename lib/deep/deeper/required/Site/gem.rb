# encoding: UTF-8
class SiteHtml
  def require_gem gem_name, version = nil
    FakeGem::new(gem_name, version).require_gem
  rescue Exception => e
    error "Impossible de requérir le gem #{gem_name} : #{e.message}"
  end

  def require_deep_gem gem_name
    path = folder_deeper+"gem/#{gem_name}"
    if path.exist?
      libpath = path + 'lib'
      dospath = (libpath + gem_name).expanded
      debug "lib path : #{libpath}"
      debug "dos path : #{dospath}"
      $: << libpath.to_s
      (libpath+"#{gem_name}.rb").require
    else
      error "Le gem #{path} est introuvable"
    end
  end
end
