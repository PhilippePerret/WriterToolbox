# encoding: UTF-8
=begin

Définition des données de synchro

PENSER À ACTUALISER CE FICHIER SI DES CHANGEMENT SONT FAITS car il
sert aussi ONLINE.

=end

# ---------------------------------------------------------------------
#   Serveur SSH à utiliser
#
# Il faut tout avoir régler pour pouvoir utiliser la commande SSH
# sans avoir à donner de mot de passe. Donc il faut avoir installé
# une clé d'authentification, etc.
# On doit pourvoir faire tout ça avec le Terminal pour une première
# utilisation.
# ---------------------------------------------------------------------
class Synchro
  def serveur_ssh
    "boite-a-outils@ssh-boite-a-outils.alwaysdata.net"
  end


end

# ---------------------------------------------------------------------
#   Fichiers à ignorer
#
# Les dossiers doivent obligatoirement se terminer par "/" car c'est
# comme ça que l'on sait que l'élémnet qu'on traite est le dossier
# recherché.
#
# ACTUALISER CE FICHIER ONLINE APRÈS TOUTE MODIFICAITON pour être sûr
# que les fichiers écartés seront les mêmes.
# ---------------------------------------------------------------------
class Synchro
  def app_ignored_files
    [
      # Ici la liste des paths de fichiers à ignorer
      "./database/data/users.db",
      "./database/data/forum.db",
      "./database/data/unan_hot.db",
      './database/data/site_hot.db',
      './database/data/filmodico.db',
      './database/data/scenodico.db'
    ]
  end
  def app_ignored_folders
    # Les dossiers doivent OBLIGATOIREMENT se terminer par "/"
    [
      "./database/data/unan/",
      "./database/data/user/"
    ]
  end
end

# ---------------------------------------------------------------------
#   Dossiers à checker et dans quel sens
#
# :dir détermine le type de check en s'appuyant sur la date de
# dernière modification du fichier.
#   Si :dir = :l2s (local-to-server), on doit seulement s'assurer que
#   le fichier online est au moins égal sinon plus vieux que le fichier
#   offline.
#   SI :dir = :s2l (server-to-local), c'est l'inverse
#

# ---------------------------------------------------------------------
class Synchro
  def folders_2_check
    {
      'lib'       => { extensions: COMMON_EXTENSIONS, dir: :l2s},
      'objet'     => { extensions: COMMON_EXTENSIONS, dir: :l2s },
      'view'      => { extensions: COMMON_EXTENSIONS, dir: :l2s },
      'data'      => { extensions: COMMON_EXTENSIONS, dir: :l2s},
      'database'  => {extensions: ['db', 'rb'], dir: :l2s}
    }
  end
  def files_2_check
    # {
    #   './database/filmodico.db'   => {dir: :both},
    #   './database/cnarration.db'  => {dir: :both},
    #   './database/scenodico.db'   => {dir: :both},
    #   './'
    # }
  end
end

# ---------------------------------------------------------------------
#   Différentes configurations dont a besoin la synchronisation
#
class Synchro

  def base
    @base ||= "http://localhost/WriterToolbox/"
  end

  def app_name
    @app_name = "WriterToolbox"
  end
  # Le dossier contenant les librairies javascript de
  # base (Ajax, jQuery, etc.)
  # Ce dossier doit contenir le dossier 'first_required' pour les
  # premiers JS requis et le dossier 'required' pour les autres
  # js requis
  def javascript_folder
    @javascript_folder ||= './lib/deep/deeper/js'
    # @javascript_folder ||= File.join('.', 'lib', 'deep', 'deeper', 'js')
  end
end
