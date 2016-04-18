# encoding: UTF-8
=begin

Module séparé permettant d'établir un état des lieux de
la collection au niveau des pages principalement.

Note : À la fin de ce fichier on étend la classe Cnarration::Page
pour lui ajouter les méthodes statistiques (nombre de pages, etc.)
=end
class Cnarration
class << self

  # Retourne le code pour l'affichage des données statistiques
  # générales
  def donnees_statistiques
    separator = "\n\n#{'-'*50}\n\n"
    nombre_max_pages_per_niveau = pages_per_niveau.collect{|bid,barr|barr.count}.max

    pages_version_papier = 0
    pages_version_online = 0


    # -----------------------------
    #     Texte à retourner
    # -----------------------------
    separator +
    "=== Données générales ===\n\n" +
    "Nombre total de fichiers  : #{pages.count}\n" +
    "  Fichiers version papier : #{pages_version_papier}\n" +
    "  Fichiers only online    : #{pages_version_online}\n" +
    "Nombre de chapitres  : #{chapitres.count}\n" +
    "Nombre de sous-chaps : #{sous_chapitres.count}" +
    separator +
    "=== Nombre de fichiers par niveau de développement ===\n\n" +
    pages_per_niveau.sort_by{|niveau| niveau}.collect do |niveau, arr_pages|
      nb_reel = arr_pages.count
      curseur = increments_curseur nb_reel, nombre_max_pages_per_niveau
      "Niveau #{niveau} | #{curseur}"
    end.join("\n") +
    separator
  end

  # Retourne les données statistiques pour chaque livre.
  # Produit un code HTML pour
  def data_statistiques_per_book
    nombre_max_pages_per_book = pages_per_book.collect{|bid,barr|barr.count}.max

    # On prépare une table pour conserver les données générales
    # qui vont permettre de faire un rapport statistique pour
    # l'accueil de la collection sur le site, visible par tout
    # visiteur. Principalement, le nombre de pages par livre,
    # en tablant sur 120 pages par livre.
    @table_per_book = Hash::new

    tableau_stats = Array::new
    @rapport_string = Array::new

    sep_tableau_bords = "-"*85
    # sep_tableau = ("-"*34) + ("-"*7).in_span(class:'cell_col')+("-"*38)
    sep_tableau = ("-"*25) + ("-"*7).in_span(class:'cell_col')+("-"*38)
    delcel = ("-"*7).in_span(class:'cell_col')
    sep_tableau = "|#{'-'*26}|#{'-'*5}|#{delcel}|#{'-'*5}|#{'-'*5}|#{'-'*8}|#{'-'*7}|#{'-'*6}|#{'-'*6}|"

    cm = "  MOY  ".in_span(class:'cell_col')
    pages = "          pages          ".in_span(class:'cell_col')
    delim_pages = ("-"*25).in_span(class:'cell_col')

    tableau_stats << sep_tableau_bords
    tableau_stats << "|#{' '*26}|" + (' '*25).in_span(class:'cell_col') + "|        |#{' '*21}|"
    # --- ENTETE ---
    tableau_stats << "| LIVRE".ljust(27) + "|#{     pages    }| signes |        files        |"
    tableau_stats << "| ".ljust(27)      + "|#{ delim_pages  }|        |---------------------|"
    tableau_stats << "| ".ljust(27)      + "| min |#{cm}| ALL | max |        |  Tous |Online|Papier|"
    tableau_stats << sep_tableau

    total_fichiers      = 0
    total_files_online  = 0
    total_files_papier  = 0
    total_pages_max     = 0
    total_pages_min     = 0
    total_pages_moy     = 0
    total_pages_pap_moy = 0
    total_signes        = 0

    # On procède de livre en livre, en récupérant les pages
    # dans le hash +pages_per_book+ (qui contient toutes les
    # pages, versions papier et version online)
    curseur_nombre_pages = Cnarration::LIVRES.collect do |livre_id, dbook|
      @rapport_string << "\n\n*** LIVRE #{dbook[:hname]} ***"
      arr_book  = pages_per_book[livre_id]
      book_name = livre_humain livre_id
      book_name = "#{book_name[0..21]}[…]" if book_name.length > 25

      @table_per_book.merge!( livre_id => {
        name:     livre_humain( livre_id),
        pages:    nil,
        signes:   nil,
        sections: nil, # = fichiers
        expected: dbook[:nbp_expected]
        })
      # Pour le nombre de pages et de caractères
      nombre_fichiers         = 0
      nombre_fichiers_online  = 0
      nombre_fichiers_papier  = 0
      nombre_pages_max        = 0
      nombre_pages_min        = 0
      nombre_pages_moy        = 0
      nombre_papes_pap_moy    = 0 # pages version papier
      nombre_signes           = 0
      unless arr_book.nil?
        nombre_fichiers = arr_book.count
        arr_book.each do |hpage|
          @rapport_string << "  - #{dbook[:folder]}/#{hpage[:handler]}"
          ipage = Cnarration::Page::get(hpage[:id])
          nb_pgs_moy = ipage.nombre_pages_1750
          if ipage.papier?
            # C'est une page qui doit être affichée dans la
            # version papier de la collection.
            nombre_fichiers_papier += 1
            max = ipage.nombre_pages_1500
            min = ipage.nombre_pages_2000
            moy = nb_pgs_moy
            nombre_pages_max      += max
            nombre_pages_min      += min
            nombre_papes_pap_moy  += moy
            nombre_signes     += ipage.nombre_signes
            @rapport_string << "    = min:#{min.round(2)} moy:#{moy.round(2)} max:#{max.round(2)}"
          else
            # C'est une page qui n'est affichée qu'en
            # version online de la collection
            nombre_fichiers_online += 1
          end
          nombre_pages_moy      += nb_pgs_moy
        end
        @rapport_string << "  NOMBRE FICHIERS #{nombre_fichiers}"
      end

      # Ajouter aux totaux (avant transformation en string)
      total_fichiers      += nombre_fichiers.to_i
      total_files_online  += nombre_fichiers_online
      total_files_papier  += nombre_fichiers_papier
      total_pages_max     += nombre_pages_max.to_i
      total_pages_min     += nombre_pages_min.to_i
      total_pages_moy     += nombre_pages_moy.to_i
      total_pages_pap_moy += nombre_papes_pap_moy.to_i
      total_signes        += nombre_signes.to_i

      @table_per_book[livre_id][:sections]= nombre_fichiers_papier
      @table_per_book[livre_id][:pages]   = nombre_pages_moy.to_i
      @table_per_book[livre_id][:signes]  = nombre_signes.to_i

      nb_pages_online_j = nombre_fichiers_online.to_i.to_s.rjust(5)
      nb_pages_papier_j = nombre_fichiers_papier.to_i.to_s.rjust(5)
      nombre_pages_min = nombre_pages_min.to_i.to_s.rjust(4)
      nombre_pages_max = nombre_pages_max.to_i.to_s.rjust(4)
      nombre_pages_moy = nombre_pages_moy.to_i.to_s.rjust(4)
      nombre_papes_pap_moy = nombre_papes_pap_moy.to_i.to_s.rjust(4).in_span(class:'bold')
      nombre_signes   = nombre_signes.to_s.rjust(7)
      nombre_fichiers = nombre_fichiers.to_s.rjust(6)


      celmoy = "|"+" #{nombre_papes_pap_moy}  ".in_span(class:'cell_col')+"|"
      tableau_stats << "| " + "#{book_name}".ljust(25) + "|#{nombre_pages_min} #{celmoy}#{nombre_pages_moy} |#{nombre_pages_max} |#{nombre_signes} |#{nombre_fichiers} |#{nb_pages_online_j} |#{nb_pages_papier_j} |"

      # Pour le nombre de fichiers
      nb_reel = arr_book.nil? ? 0 : arr_book.count
      curseur  = increments_curseur( nb_reel, nombre_max_pages_per_book )
      "| #{book_name}".ljust(25) + "|" + "#{curseur}"
    end.join("\n") # / boucle sur tous les livres

    # Ligne au-dessus des totaux
    tableau_stats << sep_tableau

    # --- LIGNE DES TOTAUX ---
    total_pages_min = total_pages_min.to_s.rjust(4)
    total_pages_max = total_pages_max.to_s.rjust(4)
    total_pages_moy = total_pages_moy.to_s.rjust(4)
    total_fichiers  = total_fichiers.to_s.rjust(6)
    total_files_online = total_files_online.to_s.rjust(5)
    total_files_papier = total_files_papier.to_s.rjust(5)
    total_signes    = total_signes.to_s.rjust(7)
    total_pages_pap_moy = "  #{total_pages_pap_moy}  ".to_s.rjust(4).in_span(class:'cell_col')
    tableau_stats << "|#{'TOTAL'.rjust(25)} |#{total_pages_min} |#{total_pages_pap_moy}|#{total_pages_moy} |#{total_pages_max} |#{total_signes} |#{total_fichiers} |#{total_files_online} |#{total_files_papier} |"

    tableau_stats << sep_tableau_bords

    # Finalisation du tableau de statistiques
    tableau_stats = "\n" + tableau_stats.join("\n") + "\n"

    debug "\n\n=== RAPPORT D'ÉVALUATION ==="
    debug @rapport_string.join("\n")
    debug "\n#{'='*70}\n\n"

    # On produit le petit code qui va écrire sur la page
    # d'accueil de la collection l'état actuel du livre
    # en ligne, de façon graphique
    graphe_pour_accueil_etat_collection

    # On retourne le texte résultat
    tableau_stats
  end

  # Produit et écrit le graphe de l'état actuel de la collection
  # pour l'accueil de la collection
  def graphe_pour_accueil_etat_collection
    code = @table_per_book.collect do |bid, bdata|
      bname    = bdata[:name]
      expected = bdata[:expected]
      sections = bdata[:sections]
      pages    = bdata[:pages]
      signes   = bdata[:signes]

      # Pourcentage exécuté
      pct_done  = ((pages.to_f / expected) * 100).to_i
      pct_done = 100 if pct_done > 100
      pct_reste = 100 - pct_done

      coef_longueur = 4
      row_height    = '18px'

      (
        bname.in_span(style:"padding-right:12px;text-align:right;display:inline-block;width:300px;overflow:hidden") +
        "".in_span(style:"display:inline-block;width:#{pct_done*coef_longueur}px;background-color:green;height:#{row_height}") +
        "".in_span(style:"display:inline-block;width:#{pct_reste*coef_longueur}px;background-color:mediumaquamarine;height:#{row_height}") +
        "#{pages}/#{expected}".in_span(style:"padding-left:12px;font-size:8.5pt;vertical-align:super;")
      ).in_div(class:'bookrang', style:'font-size:11pt;vertical-align:middle', onclick:"document.location.href='livre/#{bid}/tdm?in=cnarration'")
    end.join.in_div(id:"cnarration_inventory", style:"line-height:1em")

    (Cnarration::folder+"cnarration_inventory.html").write code
  end

  # Reçoit un nombre quelconque et un nombre max et retourne le
  # nombre d'incréments curseur. Pour l'affichage des nombres
  # sous forme de curseur de "•".
  # Le nombre +max+ doit être calculé au départ.
  def increments_curseur nb_init, max
    # Il faut que max * coef = 50
    # Donc que coef = 50.0 / max
    nb = max > 50 ? ( nb_init * (50.0 / max) ).to_i : nb_init
    "#{'•' * nb} #{nb_init}"
  end

  # Retourne le code pour l'affichage des pages par niveau de
  # développement
  def pages_par_niveau_developpement
    pages_per_niveau.sort_by{|n, a| n}.collect do |niveau, arr|
      "Page niveau #{niveau} (#{niveau_humain(niveau)})".in_h4 +
      arr.collect do |hpage|
        (
          div_boutons(hpage) +
          "#{hpage[:titre]} (#{livre_humain hpage[:livre_id]})"
        ).in_li(class:'hover')
      end.join.in_ul
    end.join
  end

  def div_boutons hpage
    (
      "text".in_a(href:"page/#{hpage[:id]}/show?in=cnarration", target:"_blank") +
      "data".in_a(href:"page/#{hpage[:id]}/edit?in=cnarration", target:"_blank")
    ).in_span(class:'btns fright small')
  end

  # Niveau humain de développement
  def niveau_humain niveau
    Cnarration::NIVEAUX_DEVELOPPEMENT[niveau.to_i][:hname]
  rescue Exception => e
    "Cnarration::NIVEAUX_DEVELOPPEMENT ne connait pas le niveau #{niveau.inspect}…"
  end

  # Titre humain du livre
  # +livre_id+ {Fixnum} ID du livre
  def livre_humain livre_id
    Cnarration::LIVRES[livre_id][:hname]
  end

  # Retourne un Hash des pages classées par niveau, avec en
  # clé le niveau (de 0 à 'a') et en valeur un Array des
  # Hash des données de la page.
  def pages_per_niveau
    @pages_per_niveau ||= begin
      h = Hash::new
      pages.each do |pid, hpage|
        niveau = hpage[:options][1]
        h.merge!(niveau => Array::new) unless h.has_key?(niveau)
        h[niveau] << hpage
      end
      h
    end
  end

  def pages_per_book
    @pages_per_book ||= begin
      hbooks = Hash::new
      pages.each do |pid, hpage|
        livre_id = hpage[:livre_id].to_i
        hbooks.merge!(livre_id => Array::new) unless hbooks.has_key?(livre_id)
        hbooks[livre_id] << hpage
      end
      hbooks
    end
  end

  # Hash avec en clé l'ID de la page (seulement des pages) et
  # en valeur un hash de toutes les données.
  def pages
    @pages ||= begin
      Cnarration::table_pages.select(where: "options LIKE '1%'")
    end
  end

  def chapitres
    @chapitres ||= Cnarration::table_pages.select(where: "options LIKE '3%'")
  end

  def sous_chapitres
    @sous_chapitres ||= Cnarration::table_pages.select(where:"options LIKE '2%'")
  end

  def textes_types
    @textes_types ||=  Cnarration::table_pages.select(where:"options LIKE '5%'")
  end

end #/<< self

class Page

  # {Float} Nombre de pages pour le fichier, à la virgule près
  # pour un format SRPS dense
  def nombre_pages_2000 # Format genre SRPS
    @nombre_pages_2000 ||= nombre_pages(2000)
  end

  # {Float} Nombre de pages réelles pour le fichier, à la virgule
  # près, pour un format SPRS moyen
  def nombre_pages_1750
    @nombre_pages_1750 ||= nombre_pages(1750)
  end

  # {Float} Nombre de pages pour le fichier, à la virgule près,
  # pour un format SRPS court ou roman
  def nombre_pages_1500 # format genre roman (ou SRPS avec exemples)
    @nombre_pages_1500 ||= nombre_pages(1500)
  end

  # Pour le calcul de pages suivant le format
  def nombre_pages signes_per_page = 1500
    @content_stripped ||= content.strip_tags
    @content_length   ||= @content_stripped.length.to_f
    @content_length.to_f / signes_per_page
  end

  # Nombre de signes dans le fichier semi-dynamique à
  # charger.
  #
  # Si le fichier semi-dynamique n'existe pas encore, on
  # le construit.
  def nombre_signes
    @nombre_signes ||= begin
      unless path_semidyn.exist?
        Cnarration.require_module 'page'
        build(quiet: true)
      end
      path_semidyn.read.nombre_signes
    end
  end

end #/Page
end #/Cnarration
