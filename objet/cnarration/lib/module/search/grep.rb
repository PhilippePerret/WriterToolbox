# encoding: UTF-8
class Cnarration
class Search
class Grep

  DELIMITEUR_FICHIERS = "\n--\n"

  # {Cnarration::Search} Instance de la recherche qui
  # contient cette instance Grep
  attr_reader :search

  # Initialisation d'une recherche dans les textes par grep
  #
  # +isearch+ Instance {Cnarration::Search} de la recherche
  def initialize isearch
    @search = isearch
  end

  # = main =
  #
  # Méthode appelée pour procéder à la recherche dans les
  # textes de la collection Narration
  def proceed
    build_resultat
  end

  def build_resultat
    founds = raw_founds.split(DELIMITEUR_FICHIERS)
    flash "#{founds.count} résultats"
  end

  # Résultat de la recherche sur tous les textes, brute,
  # c'est-à-dire comme elle est retournée par l'exécution
  # de la ligne de commande
  def raw_founds
    @raw_founds ||= begin
      begin
        res = `#{command_line}`
        res = res.force_encoding('utf-8')
        res
      rescue Exception => e
        debug e
        error e.message
        nil
      end
    end
  end

  # Ligne de commande pour rechercher +searched+ dans tous
  # les textes de la collection.
  def command_line
    cmd = "grep "
    cmd << "-E " if search.regular?
    cmd << "-2 "  # Pour afficher 2 lignes avant et après
    # Options
    #   -r    Récursif
    #   -n    Numéro de ligne
    #   -b    Indiquer le décalage au sein du fichier
    #   ---------
    #   Optionnelles
    #   -i    Case insensitive
    #   -w    Recherche de mots entiers
    options_min = ['n', 'r', 'b']
    options_min << 'i' unless search.exact?
    options_min << 'w' if search.whole_word?
    options_min = options_min.join("")
    cmd << "-#{options_min} "
    cmd << "#{grep_searched} "
    cmd << "\"#{fullpath_cnarration_folder}/\""
  end

  # Raccourci : l'expression à trouver
  def searched
    @searched ||= search.searched
  end

  # Expression à mettre dans la commande grep pour rechercher dans
  # les fichiers en fonction du fait que c'est une expression
  # régulière ou non.
  def grep_searched
    @grep_searched ||= (search.regular? ? /#{searched}/ : "\"#{searched}\"" )
  end

  def fullpath_cnarration_folder
    fullpath_cnarration_folder ||= Cnarration::folder_data_semidyn.expanded_path
  end

end #/Grep
end #/Search
end #/Cnarration
