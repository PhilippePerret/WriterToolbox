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
    separator +
    "=== Données générales ===\n\n" +
    "Nombre de pages      : #{pages.count}\n" +
    "Nombre de chapitres  : #{chapitres.count}\n" +
    "Nombre de sous-chaps : #{sous_chapitres.count}" +
    separator +
    "=== Nombre de pages par niveau de développement ===\n\n" +
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

    tableau_stats = Array::new
    sep_tableau_bords = "-"*65
    sep_tableau = ("-"*34) + ("-"*7).in_span(class:'cell_col')+("-"*24)

    celm = "  MOY  ".in_span(class:'cell_col')
    pages = "       pages       ".in_span(class:'cell_col')
    delim_pages = ("-"*19).in_span(class:'cell_col')

    tableau_stats << sep_tableau_bords
    tableau_stats << "|#{' '*26}|" + (' '*19).in_span(class:'cell_col') + "|        |       |"
    tableau_stats << "| LIVRE".ljust(27) + "|#{     pages    }| signes | files |"
    tableau_stats << "| ".ljust(27)      + "|#{ delim_pages  }|        |       |"
    tableau_stats << "| ".ljust(27)      + "| min |#{celm}| max |        |       |"
    tableau_stats << sep_tableau

    curseur_nombre_pages = Cnarration::LIVRES.collect do |livre_id, dbook|
      arr_book = pages_per_book[livre_id]
      book_name = livre_humain livre_id
      # Pour le nombre de pages et de caractères
      nombre_fichiers   = 0
      nombre_pages_max  = 0
      nombre_pages_min  = 0
      nombre_pages_moy  = 0
      nombre_signes   = 0
      unless arr_book.nil?
        nombre_fichiers = arr_book.count
        arr_book.each do |hpage|
          ipage = Cnarration::Page::get(hpage[:id])
          nombre_pages_max += ipage.nombre_pages_1500
          nombre_pages_min += ipage.nombre_pages_2000
          nombre_pages_moy += ipage.nombre_pages_1750
          nombre_signes += ipage.nombre_signes
        end
      end
      nombre_pages_min = nombre_pages_min.to_i.to_s.rjust(4)
      nombre_pages_max = nombre_pages_max.to_i.to_s.rjust(4)
      nombre_pages_moy = nombre_pages_moy.to_i.to_s.rjust(4).in_span(class:'bold')
      nombre_signes   = nombre_signes.to_s.rjust(7)
      nombre_fichiers = nombre_fichiers.to_s.rjust(6)

      celmoy = "|"+" #{nombre_pages_moy}  ".in_span(class:'cell_col')+"|"
      tableau_stats << "| " + "#{book_name}".ljust(25) + "|#{nombre_pages_min} #{celmoy}#{nombre_pages_max} |#{nombre_signes} |#{nombre_fichiers} |"

      # Pour le nombre de fichiers
      nb_reel = arr_book.nil? ? 0 : arr_book.count
      curseur  = increments_curseur( nb_reel, nombre_max_pages_per_book )
      "| #{book_name}".ljust(25) + "|" + "#{curseur}"
    end.join("\n")

    tableau_stats << sep_tableau_bords
    tableau_stats = "\n" + tableau_stats.join("\n") + "\n"


    # On retourne le texte résultat
    tableau_stats
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
    return "" if niveau.to_i == 0
    Cnarration::NIVEAUX_DEVELOPPEMENT[niveau.to_i][:hname]
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

  def pages
    @pages ||= Cnarration::table_pages.select(where: "options LIKE '1%'")
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
    (nombre_signes.to_f / signes_per_page).round(2)
  end

  def nombre_signes
    @nombre_signes ||= content_epured.length
  end

  # Le contenu du fichier, épuré des commentaires et autres
  # textes pour administrateur, pour comptage de la longueur
  def content_epured
    @content_epured ||= begin
      c = content.gsub(/<\!--(.*?)--\>/,'')
      c.gsub!(/<adminonly>(.*?)<\/adminonly>/,'')
      c
    end
  end

end #/Page
end #/Cnarration
