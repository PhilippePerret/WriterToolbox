# encoding: UTF-8
=begin
Extension de la class User pour le programme UN AN UN SCRIPT
=end
require 'json'

class User

  # {Unan::Projet} Le projet courant de l'user, ou nil
  def projet
    @projet ||= begin
      Unan::Projet::get_current_projet_of( self.id )
    end
  end
  def projet_id; @projet_id ||= projet.id end


  # Instance Unan::Program::CurPDay de l'auteur courant
  #
  # Permet notamment d'obtenir les travaux inachevés, etc.
  def cur_pday
    @cur_pday ||= begin
      # Unan::Program::CurPDay::new(program.current_pday)
      # TODO Devra être remplacé par current_pday si nécessaire
      nil
    end
  end

  # Retourne le nombre de +quoi+ de l'user (nombre de
  # messages forum, de pages de cours à lire, etc.)
  def nombre_de quoi
    0
    # cur_pday.undone(quoi).count
  end

  # Nombre de poins de l'auteur pour son programme
  # courant.
  def points
    program.points
  end

  def add_points nb_points
    return if nb_points.to_i == 0
    tot_pts_programme = points + nb_points
    program.set(:points => tot_pts_programme)
  end

  # Return TRUE si l'user vient de s'inscrire au programme
  # un an un script

  # RETURN true si l'user suit le programme Un An Un Script
  # On le sait à partir du moment où il possède un programme
  # ACTIF dans la table des programmes
  def unanunscript?
    return false if id.nil?
    program.instance_of?(Unan::Program)
  end

  # Le dossier data de l'user dans ./database/data/unan/user/<id>/
  # Note : ce dossier n'est pas à confondre avec le dossier `folder`
  # de l'user, dossier général, qui se trouve dans `./database/data/user/<id>`
  def folder_data
    @folder_data ||= begin
      d = site.folder_db + "unan/user/#{id}"
      d.build unless d.exist?
      d
    end
  end
end
