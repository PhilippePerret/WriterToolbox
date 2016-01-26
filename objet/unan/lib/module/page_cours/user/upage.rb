# encoding: UTF-8
=begin

Class User::UPage
-----------------
Gestion des pages de cours lues par l'auteur

=end
class User
class UPage

  include MethodesObjetsBdD

  # {User} Auteur pour l'instance
  attr_reader :auteur
  # ID de la page dans la table de l'auteur
  attr_reader :id

  # +pid+ ID de la page de cours (absolue) qui correspond également
  # à l'identifiant de cette donnée user
  def initialize auteur, pid
    @auteur = auteur
    @id     = pid
  end

  def create
    table.insert(data2save.merge(created_at: NOW))
  end
  def data2save
    @data2save ||= {
      id:           id,
      status:       0,
      lectures:     nil,
      comments:     nil,
      index_tdm:    nil,
      updated_at:   NOW
    }
  end

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  def status    ; @status     ||= get(:status)    end
  def comments  ; @comments   ||= get(:comments)  end
  def lectures  ; @lectures   ||= (get(:lectures) || Array::new)  end
  def index_tdm ; @index_tdm  ||= get(:index_tdm) end

  # ---------------------------------------------------------------------
  #   Data volatiles
  # ---------------------------------------------------------------------

  def page_cours
    @page_cours ||= Unan::Program::PageCours::get(id)
  end

  # ---------------------------------------------------------------------
  #   Méthodes
  # ---------------------------------------------------------------------
  def add_lecture
    create unless exist?
    set(lectures: (lectures << NOW) )
  end

  # L'auteur peut ajouter un commentaire personnel sur la page
  def add_comments commentaire = nil
    create unless exist?
    set(comments: commentaire)
  end

  def status= valeur
    raise ArgumentError, "Il faut fournir un nombre pour le status." unless valeur.instance_of?(Fixnum)
    raise ArgumentError, "Le status doit valoir entre 0 et 16." unless valeur >= 0 && valeur < 16
    set(status: valeur)
  end

  # ---------------------------------------------------------------------
  #   Database
  # ---------------------------------------------------------------------

  def table
    @table ||= auteur.table_pages_cours
  end

end #/UPage
end #User
