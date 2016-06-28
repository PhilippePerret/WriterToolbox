# encoding: UTF-8
=begin

Pour le suivi des auteurs du programme UN AN UN SCRIPT

=end
raise_unless_admin
class CalUnan
  # Largeur d'un jour à l'écran, en pixels
  DAY_WIDTH   = 25 + 2
  DAY_HEIGHT  = 40 + 4

class << self

  # Liste qui contient le nombre d'auteur par
  # pday, pour les décaler un peu lors de leur affichage
  attr_reader :nombre_auteurs_per_pday

  # Positionne les auteurs du programme
  def positionne_auteurs
    @nombre_auteurs_per_pday = Array.new(266, 0)
    drequest = {
      where:     'options LIKE "1%"',
      colonnes: [:auteur_id]
    }
    Unan.table_programs.select(drequest).collect do |hprog|
      auteur = User.new(hprog[:auteur_id])
      debug "auteur position : #{auteur.cal_position.inspect} (jour #{auteur.program.current_pday})"
      a = auteur.avatar
      @nombre_auteurs_per_pday[auteur.pday] += 1
      a # pour le collect
    end.join(' ')
  end

  # Dessin du calendrier
  def draw_cal
    c = String.new
    ijour = 0
    9.times do |lemois|
      m = ''
      30.times do |lejour|
        ijour += 1
        break if ijour > 266
        m << ijour.to_s.in_div(class:'cday')
      end
      c += m.in_div(class: 'cmonth')
    end

     return c
  end
end #/<< self
end

class User

  # Retourne le code pour placer l'avatar
  def avatar
    left  = (cal_position[1] - 1) * CalUnan::DAY_WIDTH
    top   = cal_position[0] * CalUnan::DAY_HEIGHT

    # Rectification en fonction du nombre d'auteurs qui se
    # trouvent sur le même jour-programme
    left += CalUnan.nombre_auteurs_per_pday[pday] * 4
    top  += CalUnan.nombre_auteurs_per_pday[pday] * 4

    # La position du div des infos dépend de la position
    # left
    valign_infos = cal_position[1] > 19 ? 'gauche' : 'droite'
    halign_infos = cal_position[0] > 4  ? 'dessus' : 'dessous'

    "<span style='left:#{left}px;top:#{top}px;background-color:##{color_background}' class='#{femme? ? 'fille' : 'garcon'}'>" +
      (pseudo || 'inconnu').in_span(class: 'pseudo') +
      div_infos(valign_infos, halign_infos) +
    '</span>'
  end

  def line_info intitule, valeur, css = nil
    (
      valeur.to_s.in_span(class: 'fright') +
      "#{intitule} : ".in_span
    ).in_div(class: css)
  end
  def div_infos(valign_infos, halign_infos)
    # return ""
    @div_infos ||= begin
      c = ''
      c << picto
      c << (pseudo || 'inconnu').in_div(class: 'pseudo')
      c << line_info('Rythme', program.rythme)
      c << line_info('Jour-programme', pday)
      c << line_info('Points', points)
      c << '<hr />'
      # Informations réservées à l'administrateur
      if user.admin?
        c << line_info('Documents en cours', current_pday.uworks_undone.count)
        c << line_info('Non démarrés', nombre_unstarted, nombre_unstarted > 0 ? 'red' : nil)
        c << line_info('En dépassement', nombre_overrun, nombre_overrun > 0 ? 'red' : nil)
      end
      c.in_div(class: "infos #{valign_infos} #{halign_infos}")
    end
  end

  # Couleur générale de fond en fonction de l'état
  # de l'auteur
  def color_background
    @color_background ||= begin
      case true
      when bad_state < 5  then '99FF00'
      when bad_state < 10 then 'CCCC66'
      when bad_state < 20 then 'FF9900'
      else 'FF3333'
      end
    end
  end

  # État "mauvais" en fonction des dépassements et des travaux
  # non démarrés
  def bad_state
    @bad_state ||= begin
      bad_state = 0
      if nombre_overrun > 30
        bad_state += 15
      elsif nombre_overrun > 20
        bad_state += 10
      elsif nombre_overrun > 10
        bad_state += 5
      end
      if nombre_unstarted > 30
        bad_state += 14
      elsif nombre_unstarted > 20
        bad_state += 10
      elsif nombre_unstarted > 10
        bad_state += 6
      end
      bad_state
    end
  end

  # Nombre de dépassement
  # Pour l'inscription dans les infos mais aussi pour déterminer
  # s'il doit être marqué en difficulté
  def nombre_overrun
    @nombre_overrun ||= current_pday.uworks_overrun.count
  end
  # Nombre des non démarrés
  # (idem que pour les dépassements)
  def nombre_unstarted
    @nombre_unstarted ||= current_pday.aworks_unstarted.count
  end

  def picto
    @picto ||= begin
      "<img src='./view/img/pictos/#{femme? ? 'femme' : 'homme'}.png' class='avatar' />"
    end
  end

  # Retourne un Array qui contient en première valeur
  # la rangée et en seconde valeur la colonne
  # [RANGÉE, COLONNE]
  def cal_position
    @cal_position ||= begin
      debug "##{id} (#{pseudo}) : jour #{pday}"
      m = pday / 30
      j = pday % 30
      [m, j]
    end
  end

  def pday
    @pday ||= begin
      if id == 2
        68
      else
        program.current_pday
      end
    end
  end

end
