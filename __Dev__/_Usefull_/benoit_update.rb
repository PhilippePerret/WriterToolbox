# encoding: UTF-8
=begin

Ce script doit updater Benoit, c'est-à-dire le créer pour qu'il
puisse servir pour les tests principaux et notamment le cron-job.

=end

# ---------------------------------------------------------------------
#   QUELQUES DONNÉES À DÉFINIR

# Date de démarrage du programme UN AN UN SCRIPT.
# Par défaut, c'est maintenant, mais on peut vouloir le mettre
# à une autre date.
start_time = Time.now.to_i

#
# ---------------------------------------------------------------------

require 'singleton'
require './lib/required'
site.require_objet 'unan'

class Benoit
  include Singleton
  def id; @id = 2 end
  def detruire
    # Détruire tous ses programmes
    Unan::table_programs.delete(where:{id: id})
    # Détruire tous ses projets
    Unan::table_projets.delete(where:{id: id})
    # Détruire son dossier data
    folder_data.remove if folder_data.exist?
  end
  # Méthode pour faire démarrer le programme à
  # benoit au temps +start_time+
  def start_unanunscript_at start_time = nil
    start_time ||= Time.now.to_i
    (Unan::folder_modules + 'signup_user.rb').require
    user.signup_program_uaus
    # NOTE Pour le moment on ne tient pas compte de la date
    # de démarrage
    # TODO Tenir compte de la date de démarrage
  rescue Exception => e
    puts "# ERROR : #{e.message}"
    puts e.backtrace.join("\n")
  end
  # Benoit en tant que User du site
  def user; @user ||= User::new(id) end
  # Dossier des data dans ./database/data/unan/user
  def folder_data
    @folder_data ||= Unan::folder_data + "user/#{id}"
  end
end
def benoit; @benoit ||= Benoit.instance end

# ---------------------------------------------------------------------
#   Début des opérations
# ---------------------------------------------------------------------
puts "* Construction de Benoit…"

benoit.detruire

benoit.start_unanunscript_at(start_time)

puts "Benoit construit avec succès."
