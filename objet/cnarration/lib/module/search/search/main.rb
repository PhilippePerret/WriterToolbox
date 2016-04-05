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
    check_data || return
    init_result
    make_base_duplicat
    search_in_titres  if in_titres?
    search_in_textes  if in_textes?
    @result[:end_time] = Time.now.to_f
    @result[:duration] = @result[:end_time] - @result[:start_time]
    destroy_base_duplicat
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

  # ---------------------------------------------------------------------
  #   Méthodes d'helper
  # ---------------------------------------------------------------------


  # Résumé humain de la recherche
  def human_search_summary
    @human_search_summary ||= begin
      t = String::new
      t << "Rechercher "
      t << "exactement " if exact?
      t << "“#{searched}”".in_span(class:'bold')
      where = Array::new
      where << "les <span class='bold'>titres</span>" if in_titres?
      where << "les <span class='bold'>textes</span>" if in_textes?
      t << " dans #{where.pretty_join}"
      t << " sans se soucier de la casse" unless exact?
      t << " comme expression régulière" if regular?
      t << "."
      t.in_div(class:'green small')
    end
  end



end #/Search
end #/Cnarration
