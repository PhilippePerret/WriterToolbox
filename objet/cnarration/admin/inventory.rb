# encoding: UTF-8
=begin

Module séparé permettant d'établir un état des lieux de
la collection au niveau des pages principalement.

=end
class Cnarration
class << self

  # Retourne le code pour l'affichage des données statistiques
  # générales
  def donnees_statistiques
    separator = "\n\n#{'-'*50}\n\n"
    nombre_max_pages_per_book = pages_per_book.collect{|bid,barr|barr.count}.max
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
    separator +
    "=== Nombre de pages par livres ===\n\n" +
    Cnarration::LIVRES.collect do |livre_id, dbook|
      arr_book = pages_per_book[livre_id]
      nb_reel = arr_book.nil? ? 0 : arr_book.count
      curseur  = increments_curseur( nb_reel, nombre_max_pages_per_book )
      "#{livre_humain livre_id}".ljust(25) + "|" + "#{curseur}"
    end.join("\n")
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
end #/Cnarration
