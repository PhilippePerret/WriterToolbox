# encoding: UTF-8

class User

  # Retourne true si l'utilisateur possède son propre fichier
  # dashboard dans ./objet/admin/admins/
  def has_own_dashboard?
    dashboard_path.exist?
  end

  # {SuperFile} Path au fichier dashboard propre s'il existe
  def dashboard_path
    @dashboard_path ||= Admin::Dashboard::folder_admins + "#{id}-#{pseudo}.erb"
  end
end

class Admin
class Dashboard
  class << self
    def folder_admins
      @folder_admins ||= site.folder_objet + "admin/admins"
    end
  end #/<< self
end #/Dashboard
end #/Admin
