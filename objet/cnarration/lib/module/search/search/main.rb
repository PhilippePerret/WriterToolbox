# encoding: UTF-8
class Cnarration
class Search

  # ---------------------------------------------------------------------
  #   Instance de la recherche (= une recherche)
  # ---------------------------------------------------------------------

  # {Hash} Résultat de la recherche
  attr_reader :result

  # = main =
  #
  # Procède à la recherche. C'est la méthode principale appelée par
  # la méthode Cnarration::Search::proceed
  def proceed
    check_data || (return false)
    init_result
    make_base_duplicat
    search_in_titres  if in_titres?
    search_in_textes  if in_textes?
    finir_recherche
    destroy_base_duplicat
    return true
  end

  def finir_recherche
    @result[:end_time] = Time.now.to_f
    @result[:duration] = @result[:end_time] - @result[:start_time]
    # Calcul du nombre d'éléments cherchés en fonction de
    # titres et/ou pages
    @result[:nombre_searched] = if in_titres?
      table_pages.count
    else
      table_pages.count(where:"options LIKE '1%'")
    end
  rescue Exception => e
    debug e
    error e.message
  end

  # Recherche dans les textes
  #
  # Ruby étant plutôt lent pour rechercher dans les fichiers, on
  # utilise la commande bash `grep` en cherchant récursivement
  # dans tous les fichiers puis on analyse le résultat.
  def search_in_textes
    ::Cnarration::Search::Grep::new(self).proceed
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  # Méthode pour initialiser les résultats
  def init_result
    @result = {
      summary: human_search_summary,  # Résumé humain de la recherche
      # Nombre d'éléments checkés
      # Si on doit faire une recherche sur les titres (avec ou sans
      # recherche dans les textes), ça correspond au nombre d'éléments
      # dans la table. Sinon, sans recherche sur les titres, c'est le
      # nombre de pages réelles dans la table.
      nombre_searched:  0,
      nombre_founds:    0,             # Nombre d'occurrences trouvées
      nombre_in_titres: 0,
      nombre_in_textes: 0,
      founds: Hash::new,

      # Tous les résultats, par fichier
      # Clé : ID de la page (dans la table cnarration.db)
      # Valeur : Instance Cnarration::Search::SFile
      by_file: Hash::new,

      start_time:   Time.now.to_f,
      end_time:     nil,
      duration:     nil
    }
  end

  # Méthode qui vérifie que les données soient valident. Pour le moment,
  # pour qu'elles le soient, il suffit que :
  #   1. Un texte soit défini
  #   2. Une cible (titre et/ou texte) soit définie
  def check_data
    raise "Il faut définir le texte à chercher." if searched.nil?
    raise "Impossible d'injecter le signe '&lt;' dans la recherche…" if searched.index('<') != nil
    raise "Il faut faire une recherche sur des mots d'au moins trois lettres" if searched.length < 3
    raise "Il faut choisir où chercher (titres et/ou textes)" unless in_titres? || in_textes?
  rescue Exception => e
    error e.message
  else
    true # pour poursuivre
  end

  # ---------------------------------------------------------------------
  #  Méthodes pour la database
  # ---------------------------------------------------------------------

  # {BdD::Table} Tables (copiée) des données de pages
  def table_pages
    @table_pages ||= base_narration.table('pages')
  end
  # {BdD} La base de données (copiée) contenant les
  # données Narration
  def base_narration
    @base_narration ||= BdD::new(base_duplicat_path.to_s)
  end
  # Pour ne pas "encombrer" la base pendant la recherche,
  # je fais une duplication provisoire de la table originale
  # pour pouvoir chercher dedans
  def make_base_duplicat
    FileUtils::cp base_original_path.to_s, base_duplicat_path.to_s
  end
  def destroy_base_duplicat
    base_duplicat_path.remove if base_duplicat_path.exist?
  end
  def base_original_path
    @base_original_path ||= site.folder_db + 'cnarration.db'
  end
  def base_duplicat_path
    @base_duplicat_path ||= site.folder_tmp + "cnarration-#{NOW}-#{user.id}.db"
  end



end #/Search
end #/Cnarration
