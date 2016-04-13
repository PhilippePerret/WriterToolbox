# encoding: UTF-8
# Bizarrement, ça pose problème alors que partout avant
# user est défini comme identifié…
# J'ai mis ONLINE pour que ça soit invisible en online mais
# visible en local
debug "-> ./objet/admin/lib/required/admin/class/database.rb"
unless user.admin?
  if ONLINE
    # on reste transparent
  else
    debug "-> ./objet/admin/lib/required/admin/class/database.rb"
    debug "user.id dans l'erreur : #{user.id.inspect}"
    error "Erreur à réparer : user.identified? devrait être true dans admin/class/database.rb (ce message n'apparait qu'en local)"
  end
end
# raise_unless_admin
class Admin
  class << self

    def table_taches
      @table_taches ||= site.db.create_table_if_needed('site_hot', 'todolist')
    end
    alias :table_todolist :table_taches

  end #/ << self
end #/Admin
