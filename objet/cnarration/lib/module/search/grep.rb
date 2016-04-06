# encoding: UTF-8
class Cnarration
class Search
class Grep

  # DELIMITEUR_FOUNDS = "\n--\n" # Si plusieurs lignes avant/après
  DELIMITEUR_FOUNDS = "\n"

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
    analyse_resultat
  end

  # Analyse des résultats obtenus avec la recherche dans
  # les textes et renseignement du résultat global.
  #
  # La méthode crée autant de `gfile` que nécessaire ou
  # utilise ceux que les titres ont déjà créés si une
  # recherche dans les titres a été demandée.
  def analyse_resultat
    every_founds.each_with_index do |pfound, i|
      debug "\n\n\n\nFOUND ##{i}\n\n"
      # debug "#{pfound}"
      ifound = ::Cnarration::Search::Found::new( search, pfound )
      ifound.igrep = self
      ifound.parse # ce qu'on ne fait pas avec un titre

      # L'ID de la page visée par ce found
      page_id = ifound.page_id
      # Si
      ifile = search.result[:by_file][page_id]
      ifile || begin
        # Il faut instancier un nouveau fichier de recherche
        # Rappel : Un fichier de recherche (ou de found) est
        # directement lié à un fichier narration.
        ifile = ::Cnarration::Search::SFile::new(search, page_id)
        ifile.page_titre    = ifound.page_titre
        ifile.livre_id      = ifound.livre_id
        ifile.relative_path = ifound.relative_path
        search.result[:by_file].merge!(page_id => ifile)
      end

      ifile.occurrences += ifound.iterations
      ifile.weight      += ifound.iterations    # Les occurrences dans les textes ont un poids de 1
      ifile.founds_in_textes << ifound

    end

    nombre_founds = every_founds.count
    search.result[:nombre_founds]     += nombre_founds
    search.result[:nombre_in_textes]  += nombre_founds
  end

  def every_founds
    @every_founds ||= purified_founds.split(DELIMITEUR_FOUNDS)
  end

  # Résultat brut où toutes les balises html ont été
  # supprimées ainsi que quelques autres petites choses
  def purified_founds
    @purified_founds ||= begin
      str = raw_founds
      str.gsub!(/<(.+?)>/,'')
      str
    end
  end

  # Résultat de la recherche sur tous les textes, brute,
  # c'est-à-dire comme elle est retournée par l'exécution
  # de la ligne de commande
  def raw_founds
    @raw_founds ||= begin
      begin
        debug "command_line : #{command_line.inspect}"
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
    @command_line ||= begin
      cmd = "grep "
      cmd << "-#{search.regular? ? 'E' : 'F'} " # F = Fast
      # Ci-dessus, F permet d'obtenir un traitement vraiment sans
      # expression régulière car par défaut grep fonctionne avec
      # des régulières et l'option E lui ajoute simplement les
      # expressions régulières étendues.
      # cmd << "-1 "  # Pour afficher N lignes avant et après
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
      cmd << "\"#{fullpath_cnarration_folder}\""
      cmd
    end
  end

  # Raccourci : l'expression à trouver
  def searched
    @searched ||= search.searched
  end

  # Expression à mettre dans la commande grep pour rechercher dans
  # les fichiers en fonction du fait que c'est une expression
  # régulière ou non.
  #
  # Noter qu'on ne peut pas prendre search.reg_searched qui est
  # une instance RegExp alors que là il faut un texte simple.
  def grep_searched
    @grep_searched ||= begin
      reg = "#{searched}"
      reg
    end
  end

  def fullpath_cnarration_folder
    fullpath_cnarration_folder ||= Cnarration::folder_data_semidyn.expanded_path
  end

end #/Grep
end #/Search
end #/Cnarration
