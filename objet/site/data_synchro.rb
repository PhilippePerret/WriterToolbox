# encoding: UTF-8
=begin

Définition des données de synchro

PENSER À ACTUALISER CE FICHIER SI DES CHANGEMENT SONT FAITS car il
sert aussi ONLINE.

Pour utiliser ces données n'importe où, il faut :

    require './objet/site/data_synchro.rb'

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
  SERVEUR_SSH = "boite-a-outils@ssh-boite-a-outils.alwaysdata.net"
  # Retourne le serveur SSH
  # Attention, cette méthode est appelée aussi par la synchronisation
  # qui ne connait pas le site `site`.
  def serveur_ssh
    if respond_to?(:site)
      site.serveur_ssh || site.ssh_server || SERVEUR_SSH
    else
      SERVEUR_SSH
    end
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
      './objet/site/home.html',
      './CRON2/rapport_connexions.html'
    ]
  end
  def app_ignored_folders
    # Les dossiers doivent OBLIGATOIREMENT se terminer par "/"
    [
      './lib/deep/deeper/module/synchronisation/',
      './local_cron/',
      './CRON2/rapports_connexions/',
      './view/img/CHANTIER/',
      './lib/deep/deeper/module/links_analyzer/output/routes_msh/'
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
      'CRON2'     => { extensions: COMMON_EXTENSIONS, dir: :l2s},
      'lib'       => { extensions: COMMON_EXTENSIONS, dir: :l2s},
      'objet'     => { extensions: COMMON_EXTENSIONS, dir: :l2s},
      'view'      => { extensions: COMMON_EXTENSIONS, dir: :l2s},
      'data'      => { extensions: COMMON_EXTENSIONS, dir: :l2s},
      'hot'       => { extensions: COMMON_EXTENSIONS, dir: :l2s},
      'data/analyse' => {extensions:['htm', 'png', 'jpg', 'css', 'js'], dir: :l2s},
      'database'  => {extensions: ['db', 'rb'], dir: :l2s}
    }
  end
  def files_2_check
    {
    }
  end
end

# ---------------------------------------------------------------------
#   Différentes configurations dont a besoin la synchronisation
#
class Synchro

  def base
    @base ||= "http://localhost/WriterToolbox/"
  end

  # LE NOM DU DOSSIER DE L'APPLICATION (DERNIER MOT DE base CI-DESSUS)
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
