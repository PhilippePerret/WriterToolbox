ONLINE  = ENV['HTTP_HOST'] != "localhost"
OFFLINE = !ONLINE

def require_folder dossier
  Dir["#{dossier}/**/*.rb"].each { |m| require m }
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

site.require_module('ajax') if site.ajax?

require './lib/preambule'
execute_preambule
