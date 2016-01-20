# encoding: UTF-8
=begin

Class Unan::Program::AbsWork
----------------------------
Données absolues d'une travail du programme

=end
class Unan
class Program
class AbsWork

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
  def type          ; @type           ||= get(:type)          end
  def duree         ; @duree          ||= get(:duree)         end
  def travail       ; @travail        ||= get(:travail)       end
  def resultat      ; @resultat       ||= get(:resultat)      end
  def type_resultat ; @type_resultat  ||= get(:type_resultat) end

  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------

  # La table "absolute_works" dans la base de données du programme
  def table
    @table ||= Unan::table_absolute_works
  end

  def data_type_w
    @data_type_w ||= TYPES[type_w]
  end
  def human_type_w
    @human_type_w ||= data_type_w[:hname]
  end

  def narrative_target
    @narrative_target ||= begin
      bits = type[2..3]
    end
  end
  # {Hash} décrivant le type du projet
  # Pour savoir à qui s'adresse le travail lorsque plusieurs travaux
  # alterantifs co-existent (par exemple quand l'auteur de roman devra
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
