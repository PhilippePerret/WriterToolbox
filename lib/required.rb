# encoding: UTF-8

# Méthodes qu'on peut utiliser au chargement (avant que les
# librairies de débug soient en place) pour laisser des messages
# de débug.
#
# @usage      safed_log <message>
#
# Il faut ensuite aller charger le fichier ./safed.log par
# FTP
def safed_log mess
  ref_log.puts mess
end
def ref_log
  @ref_log ||= File.open(safe_log_path, 'a')
end
def safe_log_path
  @safe_log_path ||= "./safed.log"
end

# ONLY_REQUIRE est définie pour essayer de ne faire que
# charger les modules par le Terminal, sinon on se
# retrouve avec CGI qui attend des pairs de variable
unless defined?(ONLY_REQUIRE)
  ONLY_REQUIRE = false
end

unless defined?(ONLINE)
  ONLINE  = ENV['HTTP_HOST'] != "localhost"
  OFFLINE = !ONLINE
end

def require_folder dossier
  # safed_log "Require dossier #{dossier}"
  Dir["#{dossier}/**/*.rb"].each do |m|
    # safed_log "Module : #{m}"
    require m
  end
end

# On essaie ça : si on est ONLINE, on met tous les dossier GEMS
# de ../.gems/gems en path par défaut, ainsi, tous les gems
# seront accessibles
if ONLINE
  Dir["../.gems/gems/*"].each do |fpath|
    $LOAD_PATH << "#{fpath}/lib"
  end
end



# On peut maintenant requérir tous les gems
require 'singleton'
require 'sqlite3'
require 'json'


# Le site
require_folder './lib/deep/deeper/required/divers'
require_folder './lib/deep/deeper/required/Site'
require_folder "./lib/deep/deeper/required"
site.require_gem 'superfile'
# Requérir les librairies propres à l'application
require_folder "./lib/app/handy"
require_folder "./lib/app/required"
site.require_config
require './lib/deep/deeper/output'

# ---------------------------------------------------------------------
#   Quelques initialisations et vérification
# ---------------------------------------------------------------------

unless ONLY_REQUIRE
  if site.ajax?
    site.require_module('ajax')
  else
    require './lib/preambule'
    execute_preambule
  end
end
