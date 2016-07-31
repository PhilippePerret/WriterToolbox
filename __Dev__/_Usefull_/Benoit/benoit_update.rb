# encoding: UTF-8
=begin

Ce script doit updater Benoit, c'est-à-dire le créer pour qu'il
puisse servir pour les tests principaux et notamment le cron-job.

=end

# ---------------------------------------------------------------------
#   QUELQUES DONNÉES À DÉFINIR

# Date de démarrage du programme UN AN.
# Par défaut, c'est maintenant, mais on peut vouloir le mettre
# à une autre date.

start_time = Time.now.to_i

#
# ---------------------------------------------------------------------

require 'singleton'
require './lib/required'

class Benoit

  include Singleton

  def id
    @id ||= 2
  end

  # Benoit en tant que User du site
  def as_user
    @as_user ||= User::new(id)
  end

  def detruire
    # Détruire tous ses programmes
    Unan::table_programs.delete(where:{id: id})
    # Détruire tous ses projets
    Unan::table_projets.delete(where:{id: id})
    # Détruire son dossier data
    folder_data.remove if folder_data.exist?
  rescue Exception => e
    puts "#[detruire] ERROR : #{e.message}"
  end
  # Méthode pour faire démarrer le programme à
  # benoit au temps +start_time+
  def start_unanunscript_at stime = nil
    stime ||= Time.now.to_i

    raise "benoit.user n'est pas un `User`" unless self.as_user.instance_of?(::User)

    # Il faut mettre benoit en auteur courant pour
    # toutes les méthodes qui utilisent `user`
    User::current = self.as_user

    raise "Benoit devrait être en user courant" unless User::current == self.as_user

    # On requiert le module de démarrage d'un auteur
    (Unan::folder_modules + 'signup_user.rb').require
    raise "Méthode `signup_program_uaus` inconnue" unless self.as_user.respond_to?(:signup_program_uaus)

    begin
      # as_user.signup_program_uaus
    rescue Exception => e
      puts e.message
    end

    # # NOTE Pour le moment on ne tient pas compte de la date
    # # de démarrage
    # # TODO Tenir compte de la date de démarrage
  rescue Exception => e
    puts "# ERROR : #{e.message}"
    puts e.backtrace.join("\n")
  end
  # Dossier des data dans ./database/data/unan/user
  def folder_data
    @folder_data ||= Unan::folder_data + "user/#{id}"
  end
end

# ---------------------------------------------------------------------
#   Début des opérations
# ---------------------------------------------------------------------

site.require_objet 'unan'
# Instance du singleton
def benoit; @benoit ||= Benoit.instance end

puts "* Construction de Benoit…"

benoit.detruire
#
benoit.start_unanunscript_at(start_time)

puts "Benoit construit avec succès."
