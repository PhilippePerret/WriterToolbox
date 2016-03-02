# encoding: UTF-8
=begin
Class RFile (pour Remonte-File)
-------------------------------
Pour la gestion des fichiers distants/locaux

Noter que ce sont les méthodes implémentées pour la synchro mais que
pour le moment la synchro utilise ses propres méthodes (dans output/ajax.rb)
Ce module a été inauguré pour gérer la synchronisation des bases de
données pour le filmodico et le scénodico

@usage

    site.require_module 'remove_file'

    rfile = RFile::new("./to/local/path.ext")
    # => Instance de fichier RFile

    rfile.upload
    # => Upload le fichier local vers le site distant

    rfile.distant.download
    # => Download le fichier distant vers le site local

    rfile.exist?
    # => true si existe en local

    rfile.distant
    # => L'instance RFile::Distant du fichier distant

    rfile.distant.exist?
    # => true si le fichier distant existe

    rfile.mtime
    # => temps de modification du fichier local
    rfile.distant.mtime
    # => Temps de dernière modification du fichier distant



    rfile.synchronized?
    # Return true si les fichiers sont synchronisés

=end

# Inclure les données de synchro propres au site courant
# Produira une erreur si le fichier n'existe pas.
require './objet/site/data_synchro.rb'

class RFile

  attr_accessor :message
  attr_reader   :path

  def initialize local_path
    @path = local_path
  end

  def exist?
    @is_exist ||= !!File.exist?(path)
  end

  def synchronized?
    @are_synchronized ||= ( exist? && distant.exist? && mtime == distant.mtime )
  end

  def upload
    # `ssh #{serveur_ssh} "mkdir -p ./www/#{File.dirname(path_no_dot)}"`
    `ssh #{serveur_ssh} "mkdir -p ./#{File.dirname(distant.path_no_dot)}"`
    cmd = "scp -p #{path} #{serveur_ssh}:#{distant.path}"
    # debug "Commande d'upload : #{cmd.inspect}"
    `#{cmd}`
    distant.instance_variable_set("@is_exist", nil)
    @success = distant.exist?
    @message = "UPLOAD du fichier `#{path}` "
    @message << (@success ? "opéré avec succès" : "manqué…")
    @message = @message.in_span(class: (@success ? nil : 'warning'))
    @message << "Contrôler/revenir".in_a(href:route_courante).in_p(class:'right')
  end

  def mtime
    @mtime ||= File.stat(path).mtime.to_i
  end

  def destroy
    File.unlink path
    @message  = "DESTRUCTION du fichier `#{path}` "
    @is_exist = nil
    @message << ( exist? ? "manquée…" : "opérée avec succès." )
  end

  def path_no_dot
    @path_no_dot ||= path[2..-1]
  end

  def full_path
    @full_path ||= File.join(folder_app, path_no_dot)
  end
  def folder_app
    @folder_app ||= begin
      @relative_folder = ""
      folder_name = "#{folder}"
      begin
        folder_name = File.dirname(folder_name)
        @relative_folder << "../"
      end while File.basename(folder_name) != synchro.app_name
      @relative_folder
    end
  end

  # Dossier du fichier (expandu)
  def folder
    @folder ||= File.expand_path('.')
  end

  # Adresse du serveur SSH sous la forme "<user>@<adresse ssh>"
  def serveur_ssh
    @serveur_ssh ||= Synchro::new().serveur_ssh
  end

  # ---------------------------------------------------------------------

  # {RFile::Distant} Instance du fichier distant associé
  def distant
    @distant ||= Distant::new(self)
  end

  # ---------------------------------------------------------------------
  #   Instance du fichier distant
  # ---------------------------------------------------------------------
  class Distant

    # Instance RFile du fichier local
    attr_reader :rfile

    def initialize rfile
      @rfile = rfile
    end

    def download
      # Créer la hiérarchie de dossier en local si nécessaire
      `ssh #{rfile.serveur_ssh} "mkdir -p #{path_no_dot}"`
      `scp -p #{rfile.serveur_ssh}:#{path} #{rfile.path}`
      success = File.exist? rfile.path
      mess = "DOWNLOAD du fichier `#{path}` "
      mess << ( success ? "opéré avec succès." : "manqué…")
      mess = mess.in_span(class: (success ? nil : 'warning'))
      mess << "Contrôler/revenir".in_a(href:route_courante).in_p(class:'right')
      rfile.message = mess
    end

    # Date de dernière modification
    def mtime
      @mtime ||= begin
        res = `ssh #{rfile.serveur_ssh} "ruby -e \\"STDOUT.write File.stat('#{path}').mtime.to_i\\""`
        res.to_i
      end
    end

    # Pour détruire le fichier distant
    def destroy
      mess = "DESTRUCTION du fichier distant `#{path}` "
      res = `ssh #{rfile.serveur_ssh} "ruby -e \\"File.unlink('#{path}');STDOUT.write File.exist?('#{path}').inspect\\""`
      @is_exist = nil
      mess << ((false == exist?) ? "opérée avec succès" : "manquée…")
      rfile.message = mess
    end

    def exist?
      @is_exist ||= begin
        "true" == `ssh #{rfile.serveur_ssh} "ruby -e \\"STDOUT.write File.exist?('#{path}').inspect\\""`
      end
    end

    # Pour le fichier distant ça correspond à la même chose, normalement
    def path_no_dot
      @path_no_dot ||= path
    end

    def path
      @path ||= "www/#{rfile.path_no_dot}"
    end

  end #/Distant

end #/RFile
