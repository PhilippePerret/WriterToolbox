# encoding: UTF-8
#
# Mettre ONLY_REQUIRE à true dans le module appelant pour ne faire
# que requérir cette librairie, sans lancer le préambule.
#
# Méthodes qu'on peut utiliser au chargement (avant que les
# librairies de débug soient en place) pour laisser des messages
# de débug.
#
# @usage      main_safed_log <message>
#
# Il faut ensuite aller charger le fichier ./safed.log par
# FTP
timein = Time.now.to_f
def main_safed_log mess
  main_ref_log.puts mess
end
def main_ref_log
  @main_ref_log ||= File.open(main_safe_log_path, 'a')
end
def main_safe_log_path
  @main_safe_log_path ||= "./safed.log"
end

# ONLY_REQUIRE est définie pour essayer de ne faire que
# charger les modules par le Terminal, sinon on se
# retrouve avec CGI qui attend des pairs de variable
defined?(ONLY_REQUIRE) || ONLY_REQUIRE = false

defined?(ONLINE) || begin
  ONLINE  = ENV['HTTP_HOST'] != "localhost"
  OFFLINE = !ONLINE
end

def require_folder dossier
  # main_safed_log "Require dossier #{dossier}"
  Dir["#{dossier}/**/*.rb"].each do |m|
    # main_safed_log "Module : #{m}"
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
require 'mysql2'
require 'json'

# Le site
require_folder './lib/deep/deeper/first_required'
require_folder './lib/deep/deeper/required/divers'
require_folder './lib/deep/deeper/required/Site'
require_folder './lib/deep/deeper/required'
site.require_gem 'superfile'
# Requérir les librairies propres à l'application
require_folder './lib/app/handy'
require_folder './lib/app/required'
require_folder './objet/site/lib/required'
site.require_config

User.init # charge les librairies du dossier objet/user

if param(:uid)
  debug "-- param :uid -- défini (#{param(:uid).inspect}) => mise en session"
  debug "Est-il identique à #{app.session['user_id'].inspect} ?"
  if app.session['user_id'] == param(:uid)
    debug "Identique à app.session['user_id'] => je le mémorise"
    app.session['boa_user_id'] = param(:uid)
    User.current = User.get(param(:uid).to_i)
    debug "J'ai mis en user courant #{user.pseudo} ##{user.id}"
  end
end

# ---------------------------------------------------------------------
#   Quelques initialisations et vérification
# ---------------------------------------------------------------------

ONLY_REQUIRE || begin
  if site.ajax?
    site.require_module('ajax')
  else
    require './lib/preambule'
    execute_preambule
  end
end
app.benchmark('-> required.rb', timein)
app.benchmark('<- required.rb')
