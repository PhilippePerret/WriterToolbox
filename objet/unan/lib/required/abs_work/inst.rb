# encoding: UTF-8
=begin

Class Unan::Program::AbsWork
----------------------------
Données absolues d'une travail du programme

=end

class Unan
class Program
class AbsWork

  # -> MYSQL UNAN
  include MethodesObjetsBdD

  attr_reader :id

  def initialize wid
    @id = wid.to_i_inn
  end

  # ---------------------------------------------------------------------
  #   Propriétés en base de données
  # ---------------------------------------------------------------------

  # Type complet
  # ------------
  #   BIT 1     Le type général (accomplir action, lire page cours, etc.)
  #   BIT 2-3   La cible narrative du travail (narrative_target), par exemple
  #             les personnage, ou la structure.
  def titre         ; @titre          ||= get(:titre)         end
  def type_w        ; @type_w         ||= get(:type_w)        end
  def item_id       ; @item_id        ||= get(:item_id)       end
  def type          ; @type           ||= get(:type)          end
  def duree         ; @duree          ||= get(:duree)         end
  def travail       ; @travail        ||= get(:travail)       end
  def resultat      ; @resultat       ||= get(:resultat)      end
  def exemples      ; @exemples       ||= get(:exemples)      end
  def type_resultat ; @type_resultat  ||= get(:type_resultat) end
  def points        ; @points         ||= get(:points)        end
  # IDs des pages de cours d'aide qui peuvent être associées au
  # travail (pas obligatoires)
  # Noter que la donnée est enregistrée en String mais qu'elle
  # est transformée ici pour retourner un Array
  def pages_cours_ids
    @pages_cours_ids ||= (get(:pages_cours_ids)||"").split(' ').collect{|e| e.to_i}
  end

  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------

  def exemples_ids
    @exemples_ids ||= exemples.split(' ').collect{|eid|eid.to_i} unless exemples.empty?
  end

  # La table "absolute_works" dans la base de données du programme
  def table
    # -> MYSQL UNAN
    @table ||= Unan::table_absolute_works
  end

  def data_type_w
    @data_type_w ||= TYPES[type_w]
  end

  # Le type de liste, :pages, :quiz, etc.
  def id_list_type
    @id_list_type ||= begin
      data_type_w[:id_list]
    rescue Exception => e
      error "PROBLÈME AVEC LE type_w : #{type_w.inspect}. Je mets 0 (indéfini)"
      debug e
      @type_w = 0
      @data_type_w = nil
      retry
    end
  end


  def narrative_target
    @narrative_target ||= begin
      bits = type[2..3]
    end
  end
  # {Hash} décrivant le type du projet
  # Pour savoir à qui s'adresse le travail lorsque plusieurs travaux
  # alternatifs co-existent (par exemple quand l'auteur de roman devra
  # travailler sur le manuscrit alors que l'auteur de film devra travailler
  # sur le scénario)
  def type_projet # typeP
    @type_projet ||= begin
      Unan::Projet::TYPES[type[4].to_i]
      # type[5] pourra servir pour préciser
    end
  end


end #/AbsWork
end #/Program
end #/Unan
