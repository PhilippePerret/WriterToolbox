# encoding: UTF-8
=begin
Extension de la class User pour le programme UN AN
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

  # Nombre de poins de l'auteur pour son programme
  # courant.
  def points
    program.points
  end

  def add_points nb_points
    nb_points.to_i > 0 || return
    tot_pts_programme = points + nb_points
    program.set(:points => tot_pts_programme)
  end

  # Return TRUE si l'user vient de s'inscrire au programme
  # UN AN

  # RETURN true si l'user suit le programme UN AN
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
