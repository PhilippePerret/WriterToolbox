# encoding: UTF-8
=begin

Class Unan::Projet
------------------
Gestion des projets des programmes

Note : on peut obtenir le projet du programme en faisant program.projet
=end

class Unan
class Projet

  include MethodesMySQL

  attr_reader :id

  def initialize pid
    @id = pid.to_i
  end

  # ---------------------------------------------------------------------
  #   Données
  # ---------------------------------------------------------------------
  def auteur_id     ; @auteur_id  ||= get(:auteur_id)   end
  def program_id    ; @program_id ||= get(:program_id)  end
  def titre         ; @titre      ||= get(:titre)       end
  def resume        ; @resume     ||= get(:resume)      end
  def created_at    ; @created_at ||= get(:created_at)  end
  def updated_at    ; @updated_at ||= get(:updated_at)  end
  # Pour specs, voir le fichier specs.rb

  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------

  # Instance {User} de l'auteur du projet
  def auteur
    @auteur ||= User.new(auteur_id)
  end
  # Instance {Unan::Program} du programme du projet
  def program
    @program ||= Unan::Program.new(program_id)
  end

  # Nouvelle méthode `set` pour pouvoir fonctionner même avec
  # les “valeurs bits”
  #
  # On récupère la méthode normale
  alias :db_set :set
  # Et on implémente une autre qui va corriger les valeurs à
  # corriger
  def set hdata
    if hdata.has_key?(:type)
      @type = hdata.delete(:type).to_i
      @specs    = specs
      @specs[0] = @type.to_s
      hdata.merge!( :specs => @specs)
    end
    if hdata.has_key?(:sharing)
      # C'est dans les préférences qu'il faut régler ça
      @sharing = hdata.delete(:sharing).to_i
      user.set_preference(:sharing => @sharing)
    end
    db_set hdata # enregistrement dans la db
  end

  # Type du projet
  # C'est le BIT 1 des specs
  def type
    @type ||= specs[0].to_i
  end

  # Autorisation
  # cf. Unan::SHARINGS
  def sharing
    @sharing ||= user.preference(:sharing)
  end

  # ---------------------------------------------------------------------

  def table
    @table ||= Unan.table_projets
  end

end # /Projet
end # /Unan
