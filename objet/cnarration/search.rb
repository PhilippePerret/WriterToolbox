# encoding: UTF-8
class Cnarration
class Search

  class << self
    # La recherche courante
    attr_reader :current_search

    # Retourne le code HTML pour le formulaire de recherche
    def formulaire
      site.require 'form_tools'
      form.prefix = "csearch"

      "Formulaire".in_a(onclick:"$('form#search_form').toggle()").in_div(class:'right small', display: current_search!=nil) +
      (
        "proceed_search_in_narration".in_hidden(name: 'operation') +
        form.field_text("Rechercher", :content) +
        form.field_checkbox("Chercher dans les titres", :search_in_titre) +
        form.field_checkbox("Chercher dans les textes", :search_in_texte) +
        form.field_checkbox("Recherche par expression régulière", :regular_search) +
        form.field_checkbox("Rechercher l'expression exacte (min/maj)", :search_exact) +
        form.field_checkbox("Recherches les mots entiers", :search_whole_word) +
        form.submit_button("Chercher")
      ).in_form(id:'search_form', action: "cnarration/search", class:'dim3070', display: current_search.nil?)
    end

    # Retourne le code HTML pour la recherche effectuée
    def result
      return "" if current_search.nil?
      current_search.output
    end

    # Procède à la recherche d'après les éléments définis
    def proceed
      @current_search = new()
      @current_search.proceed
    end

  end # / << self

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
    search_in_base_duplicat if in_titres?
    search_in_textes        if in_textes?
    @result[:end_time] = Time.now.to_f
    @result[:duration] = @result[:end_time] - @result[:start_time]
    destroy_base_duplicat
  end

  # ---------------------------------------------------------------------
  #   Méthodes de recherche
  # ---------------------------------------------------------------------


  # Méthode qui recherche le texte dans les titres de la
  # base de données (si nécessaire)
  def search_in_base_duplicat
    unless regular?
      # Recherche non régulière
      searched_slashed = searched.gsub(/'/, "\\'")
      request_data = {
        where:    "titre LIKE '%#{searched_slashed}%'",
        colonnes: [:titre, :options]
      }
      request_data.merge!(nocase: true) unless exact?
      table_pages.select( request_data ).each do |pid, pdata|
        ipage = Cnarration::Page::get(pid)
        next if ipage.page? && ipage.developpement < developpement_minimum
        # Sinon, on prend la page
        add_found ipage, :titre
      end
    else
      # Recherche régulière
    end
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

  # Méthode qui ajoute un "found" au résultat
  # +ipage+   {Cnarration::Page} Instance de la page
  # +type_f+  {Symbol} :titre quand trouvé dans le titre et :texte
  #           quand trouvé dans le texte de la page.
  def add_found ipage, type_found
    @result[:nombre_founds]   += 1
    key_type = "nombre_in_#{type_found}s".to_sym
    @result[key_type]         += 1

    return


    unless @result[:founds].has_key? ipage.id
      fdata = {
        page:  ipage,
        fois:  nombre_occurences,
      }
      @result[:founds].merge!( ipage.id => fdata )
    else
    end
  end

  # Méthode pour initialiser les résultats
  def init_result
    @result = {
      summary: human_search_summary,  # Résumé humain de la recherche
      nombre_founds:    0,             # Nombre d'occurrences trouvées
      nombre_in_titres: 0,
      nombre_in_textes: 0,
      founds: Hash::new,


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

  # = main =
  #
  # Code complet affiché en guise de résultat de recherche
  def output
    o = String::new
    o << "<hr>"
    o << result[:summary]
    o << "durée de l'opération : #{result[:duration].round(5)}secs".in_div(class:'small right')

    return o
  end

  # Résumé humain de la recherche
  def human_search_summary
    @human_search_summary ||= begin
      t = String::new
      t << "Rechercher "
      t << "exactement " if exact?
      t << "“#{searched}”".in_span(class:'bold')
      t << " sans se soucier de la casse" unless exact?
      t << " comme expression régulière" if regular?
      where = Array::new
      where << "les <span class='bold'>titres</span>" if in_titres?
      where << "les <span class='bold'>textes</span>" if in_textes?
      t << " dans #{where.pretty_join}"
      t << "."
      t
    end
  end

  # ---------------------------------------------------------------------
  #   Les données de la recherche
  # ---------------------------------------------------------------------
  def data
    @data ||= param(:csearch)
  end
  def searched
    @searched ||= data[:content].nil_if_empty
  end
  def in_titres?
    @search_in_titres = data[:search_in_titre] == 'on' if @search_in_titres === nil
    @search_in_titres
  end
  def in_textes?
    @search_in_textes = data[:search_in_texte] == 'on' if @search_in_textes === nil
    @search_in_textes
  end
  def regular?
    @regular_search = data[:regular_search] == 'on' if @regular_search === nil
    @regular_search
  end
  def exact?
    @search_exact = data[:search_exact] == 'on' if @search_exact === nil
    @search_exact
  end
  def whole_word?
    @whole_word = data[:search_whole_word] == 'on' if @whole_word === nil
    @whole_word
  end

  # Le développement minimum de la page pour qu'elle soit consultable
  # par le visiteur.
  # Pour un administrateur, toutes les pages sans exception.
  def developpement_minimum
    @developpement_minimum ||= (user.admin? ? 0 : 7)
  end




  # ---------------------------------------------------------------------
  #   Class Cnarration::Search::Found
  #   -------------------------------
  #   Pour un résultat trouvé
  # ---------------------------------------------------------------------

  class Found

  end

end #/Search
end #/Cnarration

# Requérir le dossier qui contient tous les modules de
# recherche.
Cnarration::require_module 'search'
