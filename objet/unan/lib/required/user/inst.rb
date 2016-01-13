# encoding: UTF-8
require 'json'

class User

  # {Unan::Projet} Le projet courant de l'user, ou nil
  def projet
    @projet ||= Unan::Projet::get_current_projet_of(self.id)
  end
  def projet_id; @projet_id ||= projet.id end

  # Retourne le nombre de +quoi+ de l'user (nombre de
  # messages forum, de pages de cours à lire, etc.)
  # Note : Toutes les variables qu'on relève par ici sont
  # des listes d'identifiants. Par exemple des identifiants
  # de pages de cours, ou de questionnaires, ou de messages
  # de forum, etc.
  def nombre_de quoi
    ( variables[quoi] || Array::new ).count
  end

  # Return TRUE si l'user vient de s'inscrire au programme
  # un an un script

  # RETURN true si l'user suit le programme Un An Un Script
  # On le sait à partir du moment où il possède un programme
  # ACTIF dans la table des programmes
  def unanunscript?
    program.instance_of?(Unan::Program)
  end

  # Le dossier data de l'user dans ./database/data/unan/user/<id>/
  def folder_data
    @folder_data ||= begin
      d = site.folder_db + "unan/user/#{id}"
      d.build unless d.exist?
      d
    end
  end
end
