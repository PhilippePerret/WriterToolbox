# encoding: UTF-8
=begin

  Module principal pour la construction d'une timeline_scenes
  Cf. le mode d'emploi (dans __Dev__)

=end
class FilmAnalyse

  TIMELINE_WIDTH = 100 # On compte en pourcentages, maintenant

class << self

  # Construit le code de la timeline à partir des données +args+ et
  # les enregistre dans un fichier.
  #
  # +args+ définit notamment la propriété :data_scenes qui contient
  # les données des scènes.
  # args[:data_scenes] est un Array dont chaque élément est un Hash
  # qui doit définir les propriétés suivantes :
  #   :time (le temps en seconds) ou :horloge
  #   :resume {String} ('fin' pour le dernier temps)
  #   :numero {Fixnum} Numéro de la scène
  # Propriétés optionnelles
  #   :duree    La durée en secondes
  #
  # Pour définir le fichier, +args+ doit définir :
  #   Soit la propriété :path du path du fichier 'timeline_scenes.htm'
  #   Soit la propriété :folder du path du dossier dans lequel mettre
  #   le fichier 'timeline_scenes.htm'
  #
  def build_timeline_scenes args

    liste_scenes = args[:data_scenes]

    # Deux corrections peuvent être à faire :
    #   1. Les temps ont été donnés en :horloge
    #   2. Les durées n'ont pas été fournies
    #
    # Note : On traite les listes à l'envers pour pouvoir
    # affecter les durées plus facilement
    current_time = nil
    liste_scenes = liste_scenes.reverse.collect do |hscene|

      # Transformation de l'horloge en temps s'il le
      # faut.
      if hscene.key?(:horloge) && !hscene.key?(:time)
        s, m, h = hscene[:horloge].split(':').reverse
        hscene[:time] = s.to_i + m.to_i * 60 + h.to_i * 3600
      end

      hscene[:duree] ||= begin
        # Sauf si la durée est déjà définie
        unless current_time.nil?
          # Donc sauf pour la première scène
          # Noter qu'on passe les scènes en ordre inverse, i.e.
          # de la dernière à la première, donc le `current_time`
          # est le temps de la scène suivante qui est passée avant
          current_time - hscene[:time]
        end
      end

      current_time = hscene[:time]

      # Pour la collecte
      hscene
    end.reverse
      # Il faut remettre les scènes dans le bon ordre, puisqu'elles
      # ont été inversées pour la durée.

    # Retrait de dernier élément (si marque fin) et
    # calcul de la durée du film
    #
    # Si la dernière donnée n'a pas de résumé, ou que ce résumé
    # est "FIN" ou "fin" ou ressemblant, alors c'est simplement
    # la marque du temps de fin. On retire cette "scène" pour
    # ne pas l'afficher
    #
    # La durée du film
    # Soit le dernier élément est la marque de la durée et l'on
    # prend son temps pour connaitre la durée du film, soit on
    # met une valeur par défaut de 30 secondes pour la durée
    # de la dernière scène.
    last_resume = liste_scenes[-1][:resume]
    @duree_film =
      if last_resume.nil? || last_resume.nil_if_empty == nil || last_resume.downcase == 'fin'
        thelast = liste_scenes.pop
        thelast[:time]
      else
        liste_scenes[-1][:time] + 30
      end

    # La suite des couleurs qui seront employées pour les blocs
    # de scènes.
    @background_colors = ['F00', '0F0', '00F', 'FF0', '0FF', 'F0F', '555']
    @nombre_background_colors = @background_colors.count

    # Le path du fichier final qu'on va créer
    #
    html_file = args[:path] ||= begin
      File.join(args[:folder], 'timeline_scenes.htm')
    end
    File.unlink html_file if File.exist? html_file

    main_id = 'timeline_scenes'
    tl_css  = 'timeline'

    code_timeline =
      "<div id='#{main_id}' data-film-duree='#{@duree_film}' style='display:none'>" +
        "<div class='#{tl_css}-h'>" +
          horizontal_timeline(liste_scenes) +
        '</div>' +
        '<div style="clear:both"></div>' +
        "<div class='#{tl_css}-v'>" +
          verticale_timeline( liste_scenes ) +
        '</div>' +
        boutons_navigation_selection +
        bouton_fermeture +
        calque_pfa +
        boutons_pfa +
      '</div>'

    # On enregistre le code fabriqué dans le fichier voulu
    File.open(html_file, 'wb'){|f| f.write code_timeline }

  end

  def bouton_fermeture
    '<a id="timeline_scenes_close_btn" href="javascript:void(0)" onclick="Scenes.close_timeline()">Fermer</a>'
  end

  # Les boutons pour naviguer dans la sélection de
  # scènes. Cette palette n'est affichée que s'il y a
  # plusieurs scènes
  def boutons_navigation_selection
    '<div id="timeline_scenes_boite_navigation_selection" style="display:none">' +
      '<a id="btn_prev_scene_timeline" href="javascript:void(0)" onclick="$.proxy(Scenes,\'select_prev\')()">◀︎</a>' +
      '<span id="numero_scene_courante">---</span>' +
      '<a id="btn_next_scene_timeline" href="javascript:void(0)" onclick="$.proxy(Scenes,\'select_next\')()">▶︎</a>' +
    '</div>'
  end

  def horizontal_timeline liste_scenes
    current_left = 0
    liste_scenes.collect do |hscene|
      width = duree_to_width hscene[:duree]
      bgcolor = @background_colors[hscene[:numero] % @nombre_background_colors]
      style   = "left:#{current_left.round(2)}%;width:#{width}%;background-color:##{bgcolor}"
      current_left += width
      "<div id='sch-#{hscene[:numero]}' data-time='#{hscene[:time]}' class='sc' onclick='sv(#{hscene[:numero]})' style='#{style}'></div>"
    end.join('')
  end
  def s2h s
    hr  = s / 3600
    r   = s % 3600
    mn = r / 60
    sc = r % 60
    h = "#{hr}:#{mn.to_s.rjust(2,'0')}:#{sc.to_s.rjust(2,'0')}"
  end
  def verticale_timeline liste_scenes
    current_time = 0
    liste_scenes.each_with_index.collect do |hscene, index_scene|
      horloge_current_time = s2h current_time
      # puts "#{horloge_current_time} : #{current_time}"
      # Le prochain temps
      # Il ne faut pas le mettre après le code ci-dessous puiqu'on
      # est dans un collect
      current_time += hscene[:duree]
      "<div id='scv-#{hscene[:numero]}' class='sc'>" +
      (
        "<span class='n'>#{index_scene + 1}</span>" +
        "<span class='t'>#{horloge_current_time}</span>" +
        "<span class='r'>#{hscene[:resume]}</span>"
      ) +
      '</div>'
    end.join('')
  end


  # Retourne l'offset 'left' en fonction du time de la scène
  def time_to_left t
    (t.to_f * coef_time_to_pixels).round(2)
  end
  # Retourne le with de la scène en fonction de sa durée
  def duree_to_width d
    r = d.to_f * coef_time_to_pixels
    r > 0.1 || r = 0.1
    # r > 4 || ( r = 4 )
    r.round(2)
  end
  # Coeffician.
  #   temps * coef_time_to_pixels = pixels
  def coef_time_to_pixels
    @coef_time_to_pixels ||= TIMELINE_WIDTH.to_f / @duree_film
  end

  def this_folder
    @this_folder ||= File.dirname(__FILE__)
  end

end #/<< self
end #/FilmAnalyse
