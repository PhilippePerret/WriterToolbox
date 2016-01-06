# encoding: UTF-8
class SiteHtml
  def require_gem gem_name, version = nil
    FakeGem::new(gem_name, version).require_gem
  rescue Exception => e
    error "Impossible de requérir le gem #{gem_name} : #{e.message}"
  end
end
