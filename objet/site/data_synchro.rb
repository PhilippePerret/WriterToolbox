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
  def ignored_files
    h = Hash::new ; [
      # Ici la liste des paths de fichiers à ignorer
    ].each { |p| h.merge!(p => true) } ; h
  end
  def ignored_folders
    ["./database/"]
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
      'lib'     => {extensions: COMMON_EXTENSIONS,  dir: :l2s},
      'objet'   => { extensions: COMMON_EXTENSIONS,  dir: :l2s },
      'view'    => { extensions: COMMON_EXTENSIONS,   dir: :l2s }
    }
  end
end
