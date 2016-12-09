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

    # -----------------------------
    #     Texte à retourner
    # -----------------------------
    separator +
    "=== Données générales ===\n\n" +
    "Nombre total de fichiers  : #{pages.count}\n" +
    "Nombre de chapitres  : #{chapitres.count}\n" +
    "Nombre de sous-chaps : #{sous_chapitres.count}" +
    separator +
    "=== Nombre de fichiers par niveau de développement ===\n\n" +
    pages_per_niveau.sort_by{|niveau| niveau}.collect do |niveau, arr_pages|
      nb_reel = arr_pages.count
      curseur = increments_curseur nb_reel, nombre_max_pages_per_niveau
      "Niveau #{niveau.rjust(2)} | #{curseur}"
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
    @table_per_book = Hash.new

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
        expected: dbook[:nbp_expected],
        pages_per_niveau: Hash.new
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

        # Boucle sur chaque livre
        arr_book.each do |hpage|
          @rapport_string << "  - #{dbook[:folder]}/#{hpage[:handler]}"
          ipage = Cnarration::Page.get(hpage[:id])

          # ==================================
          # C'est ici qu'on prend le nombre de
          # pages moyen du fichier.
          # Cf. aussi plus bas.
          # ==================================
          nb_pgs_moy = ipage.nombre_pages_1750

          # On mémorise, par livre et par niveau de développement,
          # les fichiers et le nombre de pages
          nivp = ipage.developpement
          @table_per_book[livre_id][:pages_per_niveau].key?(nivp) || begin
            @table_per_book[livre_id][:pages_per_niveau].merge!(
              nivp => {
                nombre_pages: 0,
                files:        Array.new
              }
            )
          end
          @table_per_book[livre_id][:pages_per_niveau][nivp][:nombre_pages] += nb_pgs_moy
          @table_per_book[livre_id][:pages_per_niveau][nivp][:files] << hpage[:id]



          if ipage.papier?
            # C'est une page qui doit être affichée dans la
            # version papier de la collection.
            nombre_fichiers_papier += 1


            # ===========================
            # C'est ici qu'on prend le
            # nombre de page mini et maxi
            # Cf. aussi plus haut.
            # ===========================
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

    # On produit le petit code du graphe des pages comme
    # ci-dessus mais juste pour les pages achevées
    graphe_accueil_etat_pages_achevees

    # On retourne le texte résultat
    tableau_stats
  end

  # Produit et écrit le graphe de l'état actuel de la collection
  # pour l'accueil de la collection
  def graphe_pour_accueil_etat_collection
    coef_longueur = 4
    row_height    = '18px'

    code = @table_per_book.collect do |bid, bdata|
      bname    = bdata[:name]
      expected = bdata[:expected]
      sections = bdata[:sections]
      pages    = bdata[:pages]
      # signes   = bdata[:signes]

      # Pourcentage exécuté
      pct_done  = ((pages.to_f / expected) * 100).to_i
      pct_done = 100 if pct_done > 100
      pct_reste = 100 - pct_done

      (
        bname.in_span(style:"padding-right:12px;text-align:right;display:inline-block;width:300px;overflow:hidden") +
        "".in_span(class: 'done all', style:"width:#{pct_done*coef_longueur}px;") +
        "".in_span(class: 'undo all', style:"width:#{pct_reste*coef_longueur}px;") +
        "#{pages}/#{expected}".in_span(class: 'pages')
      ).in_div(class:'bookrang', onclick:"document.location.href='livre/#{bid}/tdm?in=cnarration'")
    end.join.in_div(id:"cnarration_inventory", style:"line-height:1em")

    code = "<h4>Nombre de pages en développement par livre</h4>" +
            avertissement_valeurs_aberrantes +
            styles_css_graphiques_pages +
            code
    inventory_file.write code
  end

  # Produit et écrit le graphe de l'état actuel de la collection
  # pour l'accueil de la collection MAIS EN NE CONSIDÉRANT QUE
  # LES PAGES ACHEVÉES
  def graphe_accueil_etat_pages_achevees

    coef_longueur = 4
    row_height    = '18px'

    code = @table_per_book.collect do |bid, bdata|
      bname    = bdata[:name]
      expected = bdata[:expected]

      nombre_pages_achevees = 0
      nombre_files_acheves  = 0

      # (8..10).each do |niveau|
      #   data_niveau_x = bdata[:pages_per_niveau][niveau]
      #   data_niveau_x != nil || next
      #   nombre_pages_achevees += data_niveau_x[:nombre_pages]
      #   nombre_files_acheves  += data_niveau_x[:files].count
      # end

      (10..10).each do |niveau|
        data_niveau_x = bdata[:pages_per_niveau][niveau]
        data_niveau_x != nil || next
        nombre_pages_achevees += data_niveau_x[:nombre_pages]
        nombre_files_acheves  += data_niveau_x[:files].count
      end

      nombre_pages_achevees = nombre_pages_achevees.ceil

      pages = nombre_pages_achevees
      # signes   = bdata[:signes]

      # Pourcentage exécuté
      pct_done  = ((pages.to_f / expected) * 100).to_i
      pct_done = 100 if pct_done > 100
      pct_reste = 100 - pct_done

      (
        bname.in_span(style:"padding-right:12px;text-align:right;display:inline-block;width:300px;overflow:hidden") +
        "".in_span(class: 'done end', style:"width:#{pct_done*coef_longueur}px;") +
        "".in_span(class: 'undo end', style:"width:#{pct_reste*coef_longueur}px;") +
        "#{pages}/#{expected}".in_span(class: 'pages')
      ).in_div(class:'bookrang', onclick:"document.location.href='livre/#{bid}/tdm?in=cnarration'")
    end.join.in_div(id:"cnarration_inventory_done", style:"line-height:1em")
    #
    code = "<h4>Nombre de pages achevées par livre</h4>"+
            code
    inventory_file.append code
  end

  def styles_css_graphiques_pages
    <<-EOD
<style type="text/css">
div.bookrang {
  font-size:11pt;
  vertical-align:middle
}
div.bookrang span.done {
  display:inline-block;
  height:18px;
}
div.bookrang span.undo {
  display:inline-block;
  height:18px;
}
/* Graphique de toutes les pages */
div.bookrang span.undo.all{background-color:mediumaquamarine;}
div.bookrang span.done.all{background-color:green;}

/* Graphique des pages achevées */
div.bookrang span.undo.end{background-color:#cdfff5;}
div.bookrang span.done.end{background-color: #477078;}

div.bookrang span.pages {
  padding-left:12px;
  font-size:8.5pt;
  vertical-align:super;
}
</style>

    EOD
  end

  def avertissement_valeurs_aberrantes
    'Pour l’explication de certaines valeurs aberrantes, cf. sous les graphiques.'.in_div(class: 'tiny right italic', style:'margin-bottom:2em')
  end

  # Reçoit un nombre quelconque et un nombre max et retourne le
  # nombre d'incréments curseur. Pour l'affichage des nombres
  # sous forme de curseur de "•".
  # Le nombre +max+ doit être calculé au départ.
  def increments_curseur nb_init, max
    # Il faut que max * coef = 50
    # Donc que coef = 50.0 / max
    nb = max > 50 ? ( nb_init * (50.0 / max) ).to_i : nb_init
    nb > 0 || nb = 1
    "#{'•' * nb} #{nb_init}"
  end

  # Retourne le code pour l'affichage des pages par niveau de
  # développement
  def pages_par_niveau_developpement
    pages_per_niveau.sort_by{|n, a| n}.collect do |niveau, arr|
      ul_id = "ul_pages_niveaux_#{niveau}"
      "Page niveau #{niveau} (#{niveau_humain(niveau)})".in_a(onclick: "$('ul##{ul_id}').toggle()").in_h4 +
      arr.collect do |hpage|
        (
          div_boutons(hpage) +
          "[#{hpage[:id]}] #{hpage[:titre]} (#{livre_humain hpage[:livre_id]})"
        ).in_li(class:'hover')
      end.join.in_ul(id: ul_id, display: false)
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
    niveau = niveau.to_s(11)
    niv = niveau.to_s == "a" ? "a" : niveau.to_i
    Cnarration::NIVEAUX_DEVELOPPEMENT[niv][:hname]
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
      h = {}
      pages.each do |hpage|
        niveau = hpage[:options][1].to_i(11)
        h.merge!(niveau => Array::new) unless h.key?(niveau)
        h[niveau] << hpage
      end
      h
    end
  end

  def pages_per_book
    @pages_per_book ||= begin
      hbooks = {}
      pages.each do |hpage|
        livre_id = hpage[:livre_id].to_i
        hbooks.merge!(livre_id => Array.new) unless hbooks.key?(livre_id)
        hbooks[livre_id] << hpage
      end
      hbooks
    end
  end

  # Array des pages (seulement des pages) où chaque élément est
  # un hash de toutes les données de la page.
  def pages
    @pages ||= Cnarration.table_pages.select(where: "options LIKE '1%'")
  end

  def chapitres
    @chapitres ||= Cnarration.table_pages.select(where: "options LIKE '3%'")
  end

  def sous_chapitres
    @sous_chapitres ||= Cnarration.table_pages.select(where:"options LIKE '2%'")
  end

  def textes_types
    @textes_types ||=  Cnarration.table_pages.select(where:"options LIKE '5%'")
  end

end #/<< self


class Page

  # ---------------------------------------------------------------------
  #
  #   Méthodes permettant de calculer le nombre de pages/signes, etc.
  #   de chaque fichier de la collection Narration.
  #
  # ---------------------------------------------------------------------

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
    @content_stripped ||= begin
      # content.strip_tags
      cont_stripped = contenu_deserbed
      if id == 629 # fiches structure (avec des images)
        debug "Page #629\n"+
              "---------\n"+
              "Contenu initial : #{cont_stripped.gsub(/</,'&lt;')}"
      end

      # TRAITEMENT DES IMAGES
      # ---------------------
      # Si la page contient des images, il faut estimer la place que
      # ces images occuperait dans la page.
      @nombre_pages_pour_images = 0.0
      if cont_stripped.match(/<img/)
        debug "LA PAGE ##{id} CONTIENT DES IMAGES"
        cont_stripped.scan(/<img(.*?)src=\"(.*?)\"(.*?)\/>/).to_a.each do |arr_found|
          rienavant, img_relpath, rienapres = arr_found
          @nombre_pages_pour_images += nombre_pages_pour_image(img_relpath)
        end
      end


      cont_stripped = cont_stripped.strip_tags
      cont_stripped = cont_stripped.gsub(/\r/,'').gsub(/\n\n\n+/, "\n\n")
      # if id == 635 # exemples de fondamentales
      #   debug "Page ##{id}\n"+
      #         "Longueur strippé : #{cont_stripped.length}\n"+
      #         "Contenu strippé :\n#{cont_stripped.gsub(/</,'&lt;')}"
      # end
      if id == 629 # fiches structure (avec des images)
        debug "Longueur strippé : #{cont_stripped.length}\n"+
              "Contenu strippé :\n#{cont_stripped.gsub(/</,'&lt;')}"
      end
      cont_stripped
    end

    @content_length   ||= @content_stripped.length.to_f
    (@content_length.to_f / signes_per_page) + @nombre_pages_pour_images
  end

  # Retourne le nombre de pages occupées par l'image
  # de chemin relatif +relpath+.
  # Ce nombre est un flottant pour pouvoir bien sûr tenir compte du
  # fait qu'une image n'occupe qu'une partie de la page.
  #
  # En cas d'erreur, la méthode retourne 0
  #
  # Pour les images en dessous de 30px on retourne aussi 0.
  #
  def nombre_pages_pour_image relpath
    # debug "- IMG #{relpath}"

    # Récupération de la taille de l'image (quelconque) avec
    # la commande sips.
    cmd_img_size = "sips -g pixelWidth -g pixelHeight \"#{relpath}\""
    res = `#{cmd_img_size}`
    rien, width_str, height_str = res.strip.split("\n")
    width_str = width_str.split(':').last.strip
    height_str = height_str.split(':').last.strip

    width   = width_str.to_i
    height  = height_str.to_i

    # debug "  Dimensions de l'image : #{width} x #{height}"

    # Calcul de la hauteur relative
    # -----------------------------
    # On va chercher la hauteur relative (rel_h) en fonction de la
    # largeur de l'image sur la base de :
    # Taille en pixel d'une page A5 avec marges de 20mm : 308 x 482
    #
    rel_h =
      if width > 308
        # x * width = 308 => x = 308 / width
        # => rel_h = height * x
        # => rel_h = height * (308 / width)
        height * (308.0 / width)
      else
        height
      end

    # debug "Hauteur relative : #{rel_h}"

    # On ne traite qu'une hauteur minimum, sinon on ne compte
    # rien comme page ajoutée.
    rel_h > 30 || ( return 0 )

    # Calcul de la proportion de page occupée
    # ---------------------------------------
    # Une page fait 482 pixels efficace en hauteur. On renvoie la proportion
    # que ça représente pour l'image courante.
    prop = rel_h.to_f / 482

    # debug "  Proportion de page occupée par l'image : #{prop}"

    return prop

  rescue Exception => e
    debug e
    error "Une erreur est survenue en calculant la proportion de page occupée par l'image #{relpath} : #{e.message}"
    return 0.0
  end

  # Nombre de signes dans le fichier semi-dynamique à
  # charger.
  #
  # Si le fichier semi-dynamique n'existe pas encore, on
  # le construit.
  #
  # On deserbe le fichier semi-dynamique avant de compter son
  # nombre de signes.
  #
  def nombre_signes
    @nombre_signes ||= contenu_deserbed.nombre_signes
  end

  # Le contenu du fichier, déserbé
  #
  # Le fichier est construit s'il n'existe pas
  #
  def contenu_deserbed
    @contenu_deserbed ||= begin
      path_semidyn.exist? || begin
        Cnarration.require_module 'page'
        build(quiet: true)
      end
      # if id == 635
      #   debug "Page #635"
      #   debug "path_semidyn.read  =\n#{path_semidyn.read.gsub(/</,'&lt;')}"
      #   debug "path_semidyn.deserb =\n#{path_semidyn.deserb.gsub(/</,'&lt;')}"
      # end
      path_semidyn.deserb
    end
  end

end #/Page
end #/Cnarration
