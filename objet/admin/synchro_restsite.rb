# encoding: UTF-8
raise_unless_admin
=begin

  Ce module est destiné à faire la synchronisation des fichiers
  système RestFull entre deux applications qui l'utilise.

  On a l'application source, qui contient les fichiers les plus
  à jour, et on a l'application destination, qui contient les
  fichiers à actualisation.

  Le script montre la différence entre les fichiers avant des
  les actualiser.

=end
Admin.require_module 'sync_restsite'

case param(:operation)
when '', nil then nil # ne rien faire
else
  debug "-> SyncRestsite::param(:operation)"
  SyncRestsite.send(param(:operation).to_sym)
  # Note : toutes les opérations se trouvent dans :
  #   ./objet/admin/lib/module/sync_restsite/sync_restsite/operations.rb
end
