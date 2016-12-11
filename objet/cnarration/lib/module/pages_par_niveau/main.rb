# encoding: UTF-8
=begin

  Module permettant d'afficher les pages par niveau de
  développement.

=end
class Cnarration
class << self

  # = main =
  #
  # Retourne le code HTML de la liste de toutes les pages classées par
  # niveau de développement.
  #
  # Retourne le code pour l'affichage des pages par niveau de
  # développement
  def pages_par_niveau_developpement
    @pages_par_niveau_sorted = pages_per_niveau.sort_by{|n, a| n}

    # On récupère les valeurs utiles pour faire un affichage qui donne
    # tout de suite une idée des valeurs
    data_per_niveau       = Hash.new
    nombre_total_fichiers = 0
    max_fichiers = 0
    @pages_par_niveau_sorted.each do |niveau, arr|
      count = arr.count
      data_per_niveau.merge!(
        niveau => {nombre: count}
      )
      # Le nombre le plus grand de fichiers
      count < max_fichiers || max_fichiers = count
      nombre_total_fichiers += count
    end

    # max_fichiers doit correspondre à 20 points-curseur
    # Donc nombre_fichiers * 20 / max_fichiers doit donner le nombre de
    # points-curseur pour chaque catégorie
    coef_max_fichier = 80.0 / max_fichiers

    # On construit l'affichage
    affichage = String.new
    iniveau = -1
    @pages_par_niveau_sorted.each do |niveau, arr|

      iniveau += 1

      # debug "iniveau = #{iniveau} / niveau = #{niveau}::#{niveau.class}"
      # Un niveau sans page
      while iniveau != niveau
        affichage << "#{'0'.in_span(class: 'fright small')}Niveau #{iniveau} : #{niveau_humain(iniveau)}".
          in_h4(style: 'color:#999;font-style:italic;font-weight:normal;')
        iniveau += 1
        # debug "iniveau = #{iniveau} / niveau = #{niveau}::#{niveau.class}"
      end

      data_niveau = data_per_niveau[niveau]
      nombre_fichiers = data_niveau[:nombre]
      nombre_points   = (nombre_fichiers * coef_max_fichier).to_i
      nombre_points > 0 || nombre_points = 1

      curseur = ("#{nombre_fichiers} " + '•'*nombre_points).in_span(class: 'fright small')
      ul_id = "ul_pages_niveaux_#{niveau}"

      affichage +=
        "#{curseur}Niveau #{niveau} : #{niveau_humain(niveau)}".in_a(onclick: "$('ul##{ul_id}').toggle()").in_h4 +
        arr.collect do |hpage|
          (
            div_boutons(hpage) +
            "[#{hpage[:id]}] #{hpage[:titre]} (#{livre_humain hpage[:livre_id]})"
          ).in_li(class:'hover')
        end.join.in_ul(id: ul_id, display: false)
    end
    return affichage
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
    niv = niveau.to_s == 'a' ? 'a' : niveau.to_i
    Cnarration::NIVEAUX_DEVELOPPEMENT[niv][:hname]
  rescue Exception => e
    debug e
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
        h.merge!(niveau => Array.new) unless h.key?(niveau)
        h[niveau] << hpage
      end
      h
    end
  end

end #/<< self
end #/Cnarration
