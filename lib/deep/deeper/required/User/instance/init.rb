# encoding: UTF-8
=begin

Si un dossier ./objet/user/lib existe, on le charge toujours

=end
class User
  class << self

    def init
      folder_custom_lib.require if folder_custom_lib.exist?
    end

    def folder_custom_lib
      @folder_custom_lib ||= site.folder_objet+'user/lib'
    end
  end

  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------

  # À l'initialisation de l'user (en fait, au chargement de
  # la page), on enregistre toujours sa dernière connexion
  def set_last_connexion
    rt = site.current_route ? site.current_route.route : nil
    site.db.create_table_if_needed('users', 'connexions').set(self.id, {
      id: self.id, route: rt, time: NOW
      })
  end

  # Retourne la date de dernière connexion de l'user, ou NIL
  def last_connexion
    @last_connexion ||= begin
      rs = site.db.create_table_if_needed('users', 'connexions').get(self.id)
      rs.nil? ? nil : rs[:time]
    end
  end

end
