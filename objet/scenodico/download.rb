# encoding: UTF-8
=begin

Procédure pour rappatrier la base de donnée des mots du scénodico

Le module vérifie si ça n'est pas dangereux et
demande une confirmation en cas de doute.

=end
site.require_module 'remote_file'

def rfile
  @rfile ||= RFile::new("./database/data/scenodico.db")
end
