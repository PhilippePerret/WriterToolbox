require 'singleton'
require 'sqlite3'
require 'json'

ONLINE  = ENV['HTTP_HOST'] != "localhost"
OFFLINE = !ONLINE

def require_folder dossier
  Dir["#{dossier}/**/*.rb"].each { |m| require m }
end
# Le site
require_folder './lib/deep/deeper/required/divers'
require_folder './lib/deep/deeper/required/Site'
require_folder "./lib/deep/deeper/required"
site.require_gem 'superfile'
site.require_config
require './lib/deep/deeper/output'

# Quelques initialisations
User::init
