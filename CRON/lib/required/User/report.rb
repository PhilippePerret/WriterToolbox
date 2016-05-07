# encoding: UTF-8
=begin

UN AN UN SCRIPT

TODO: Ce module et la classe User::Report (user.report) doit être
utilisée pour construire un rapport à l'user qui sera :
  * envoyé par mail si c'est le début de la journée
  * affiché dans le bureau de l'auteur

=end
class User

  def report
    @report ||= UAUSReport::new(self)
  end

# ---------------------------------------------------------------------
#   Class User::Report
# ---------------------------------------------------------------------
class UAUSReport
  class << self

    # {Array of String} Messages qui devront être envoyés
    # à l'administration
    attr_reader :messages_administration

    # Pour ajouter un message à envoyer à l'administration
    # @syntaxe :    User::UAUSReport::warn_admin <message>
    def warn_admin mess
      @messages_administration ||= Array::new
      @messages_administration << mess
    end

    # S'il y a des messages à transmettre à l'administration
    # il faut le faire

  end # / << self

  # {User} Auteur qui possède le rapport courant
  attr_reader :auteur


  def initialize auteur
    @auteur = auteur
  end

  # ---------------------------------------------------------------------
  #   Raccourcis
  # ---------------------------------------------------------------------
  def pseudo; @pseudo ||= auteur.pseudo end

  # Instance Unan::Program::CurPDay du programme de
  # ce rapport.
  # Noter que des données supplémentaires existent, comme
  # la variable `avertissements` qui contient les avertissements par
  # niveau (de 1 à 6)
  def cur_pday
    @cur_pday ||= auteur.program.cur_pday
  end

  # Envoi du rapport par mail
  def send_by_mail
    auteur.send_mail(
      subject:        "Rapport journalier du #{NOW.as_human_date(true, false, ' ')}",
      message:        introduction + built_report,
      formated:       true,
      force_offline:  true # même offline, on envoie le rapport
    )
  end

  def introduction
    c = String::new
    (c << welcome)                rescue nil
    (c << avertissements_serieux) rescue nil
    (c << avertissements_mineurs) rescue nil
    (c << nombre_points)          rescue nil
    return c
  end

  def welcome
    <<-HTML
<p>Bonjour #{pseudo},</p>
<p class='small italic'>Veuillez trouver ci-dessous le rapport de votre travail sur le programme UN AN UN SCRIPT de <a href="#{site.distant_url}">#{site.name}</a>.</p>
    HTML
  end
  # ---------------------------------------------------------------------
  #   Construction de la section des avertissements (introduction)
  # ---------------------------------------------------------------------

  def avertissements_serieux
    return "" if nombre_avertissements_serieux == 0
    s = nombre_avertissements_serieux > 1 ? 's' : ''
    c = "Attention, #{pseudo} vous avez #{nombre_avertissements_serieux} avertissement#{s} sérieux à prendre en compte"
    s = nombre_avertissements_mineurs > 1 ? 's' : ''
    c = " (et #{nombre_avertissements_mineurs} avertissement#{s} mineur#{s})."
    c.in_div(class:'warning air')
  end
  # Retourne le code pour les avertissements mineurs.
  # Noter que rien n'est affiché s'il y a des avertissements sérieux
  def avertissements_mineurs
    return "" if nombre_avertissements_serieux > 0
    s = nombre_avertissements_mineurs > 1 ? 's' : ''
    "Notez, #{pseudo}, que vous avez #{nombre_avertissements_mineurs} avertissement#{s} mineur#{s}."
  end

  def nombre_avertissements
    @nombre_avertissements ||= cur_pday.avertissements[:total]
  end
  def nombre_avertissements_serieux
    @nombre_avertissements_serieux ||= cur_pday.avertissements[:greater_than_four]
  end
  def nombre_avertissements_mineurs
    @nombre_avertissements_mineurs ||= nombre_avertissements - nombre_avertissements_serieux
  end

  def nombre_points
    "Votre compte actuel de points est : #{auteur.program.points}".in_div(id:'div_nombre_points')
  end

  # ---------------------------------------------------------------------
  #   Méthodes de construction du rapport
  # ---------------------------------------------------------------------

  # Construction du rapport de l'état des lieux de l'auteur
  # RETURN Le code HTML du rapport construit
  def built_report
    css + (
      "Rapport du #{NOW.as_human_date(true, false, ' ')}".in_h2 +
      section_travaux_overtimed   +
      section_nouveaux_travaux    +
      section_travaux_poursuivis
    ).in_section(id:'unan_inventory')
  end

  # Traite une liste de travaux par type.
  # +kliste+ est le nom de la méthode qui définit les travaux,
  # par exemple :nouveaux pour les nouveaux ou :overtimed pour
  # les travaux en dépassement. Cette méthode est une méthode
  # de `Unan::Program::CurPDay` qui retourne une liste d'instances
  #
  # C'est la méthode qui est utilisée pour traiter toutes les
  # listes de travaux, nouveaux, poursuivis ou en dépassement
  # ci-dessous.
  #
  def traite_liste_travaux kliste
    safed_log "Traitement de la liste #{kliste.inspect}"
    max_depassement = 0
    liste_tous_travaux = [:task, :page, :quiz, :forum].collect do |ltype|
      cur_pday.send(kliste, ltype).collect do |wdata|

        titre = wdata[:titre]

        data_type = Unan::Program::AbsWork::TYPES[wdata[:type_w]]
        if data_type.nil?
          safed_log "# PROBLÈME DE TYPE : :type_w non défini ou introuvable dans #{wdata.inspect}"
        else
          titre = "#{data_type[:hname]} : “#{titre}”"
        end

        dep   = wdata[:depassement]
        reste = wdata[:reste]
        max_depassement = dep if dep != nil && dep > max_depassement
        info_end = if reste == 0
          "Ce travail doit être effectué aujourd'hui".in_div(class:'orange')
        elsif reste > 1
          "Travail à effectuer dans les #{reste} jours.".in_div(class:'blue')
        elsif reste == 1
          "Ce travail doit être effectué aujourd'hui ou demain".in_div
        elsif dep > 1
          "Travail en dépassement de #{dep} jours.".in_div(class:'warning')
        elsif dep == 1
          "Petit dépassement d'un jour.".in_div(class:'warning')
        end
        # Construction de la ligne pour ce travail
        (titre + info_end).in_li(class: wdata[:css])
      end.join
    end.join.in_ul(id:"liste_travaux_#{kliste}", class:'liste_travaux')

    alerte_depassement(max_depassement) +
    liste_tous_travaux
  end

  # TODO: Gérer aussi le nombre de dépassement pour avoir un
  # message qui dépendra vraiment de chaque cas.

  # Retourne le message à afficher au-dessus de toutes les listes
  # de travaux en fonction de LA PLUS GRANDE VALEUR DE DÉPASSEMENT
  # +max_overtime+ {Fixnum} de 0 à 6
  def alerte_depassement max_overtime
    safed_log "    max overtime = #{max_overtime}"
    return "" if max_overtime == 0
    # Nombre d'avertissements par niveau 1 à 6
    av = cur_pday.avertissements
    nombre_un = av[1].count
    nombre_de = av[2].count
    nombre_tr = av[3].count
    nombre_qu = av[4].count
    nombre_ci = av[5].count
    nombre_si = av[6].count
    nombre_total = av[:total]

    nombre_unde = nombre_un + nombre_de
    nombre_trqu = nombre_tr + nombre_qu
    nombre_cisi = nombre_ci + nombre_si

    badness  = 0
    badness += 5 * nombre_unde
    badness += 10 * nombre_trqu
    badness += 20 * nombre_cisi

    # Le message dépend aussi du stade où en est l'auteur,
    # différent si c'est au début du programme ou à la fin
    stade_programme = if cur_pday.indice < 100
      :debut
    elsif cur_pday.indice <= 260
      :milieu
    elsif cur_pday.indice > 260
      :fin
    end

    # La variable "retard" sera enregistrée dans la données
    # "retards" du programme
    # retard : 0
    aucun_retard = (nombre_unde + nombre_trqu + nombre_cisi) == 0
    # 1
    seulement_petits_retards  = nombre_unde > 0 && (nombre_trqu + nombre_cisi) == 0  # 1
    # 2
    beaucoup_petits_retards   = nombre_unde > 10
    # 3
    trop_de_petits_retards    = nombre_unde > 20
    # 4
    seulement_moyens_retards  = nombre_cisi == 0
    # 5
    beaucoup_moyens_retards   = nombre_trqu > 10
    # 6
    trop_de_moyens_retards    = nombre_trqu > 20
    # 7
    de_gros_retards           = nombre_cisi > 0
    # 8
    beaucoup_gros_retards     = nombre_cisi > 10
    # 9
    trop_de_gros_retards      = nombre_cisi > 20

    retard = case true
    when nombre_cisi > 20 then 9
    when nombre_cisi > 10 then 8
    when nombre_cisi > 0  then 7
    when nombre_trqu > 20 then 6
    when nombre_trqu > 10 then 5
    when nombre_trqu > 0  then 4
    when nombre_unde > 20 then 3
    when nombre_unde > 10 then 2
    when nombre_unde > 0  then 1
    else 0
    end

    # Enregistrement de la valeur de retard dans le
    # programme de l'auteur
    retards = (auteur.program.retards || "").split('')
    retards[cur_pday.indice] = retard
    retards = retards.join('') # utilisé aussi plus bas
    auteur.program.set(retards: retards)

    safed_log "    = retard   = #{retard}"
    safed_log "    = retards  = #{auteur.program.retards}"

    # Si le retard est conséquent, le signaler à l'administration
    if retard > 6
      message_retard = <<-ERB
<div class='warning'>DÉPASSEMENT TROP CONSÉQUENT DE #{auteur.pseudo} (##{auteur.id}) :</div>
<pre>
      Retard aujourd'hui  : #{retard}
      Données des retards : #{retards}
      Jour-programme      : #{auteur.program.current_pday}
</pre>
      ERB
      Cron::Admin::report << message_retard

    end

    # Message retourné
    if trop_de_gros_retards
      "Franchement, vous feriez mieux de jeter l'éponge et de laisser votre place à quelqu'un de plus motivé que vous…"
    elsif beaucoup_gros_retards
      "Je ne sais plus quoi faire pour vous motiver, mais vous semblez avoir lâcher l'affaire. C'est vraiment dommage."
    elsif de_gros_retards
      case stade_programme
      when :debut
        "Si vous comptez parvenir au bout du chemin, il serait temps de vous reprendre en main."
      when :milieu
        "Vous avez déjà accompli un bon bout du chemin, il est encore temps de vous reprendre."
      when :fin
        "Franchement, ça serait dommage de renoncer alors que vous avez fait le plus gros du travail, non ?"
      end
    elsif trop_de_moyens_retards
    elsif beaucoup_moyens_retards
    elsif seulement_moyens_retards
    elsif beaucoup_petits_retards
    elsif seulement_petits_retards
    else
      case stade_programme
      when :debut
        "Vous êtes à jour de tous vos travaux, c'est excellent."
      when :milieu
        "Bravo, nous sommes déjà bien avancés dans le programme mais vous êtes à jour de vos travaux."
      when :fin
        "Excellent ! Vous tenez merveilleusement bien le rythme."
      end
    end
  end

  def section_nouveaux_travaux
    return "Aucun nouveau travail".in_p if nombre_nouveaux == 0
    c = String::new
    c << "Nouveaux travaux (#{nombre_nouveaux})".in_h3
    c << traite_liste_travaux( :nouveaux )
    return c
  end
  def nombre_nouveaux
    @nombre_nouveaux ||= cur_pday.nouveaux(:all).count
  end

  def section_travaux_poursuivis
    return "Aucun travail à poursuivre".in_p if nombre_poursuivis == 0
    c = String::new
    c << "Travaux à poursuivre (#{nombre_poursuivis})".in_h3
    c << traite_liste_travaux( :poursuivis )
    return c
  end
  def nombre_poursuivis
    @nombre_poursuivis ||= cur_pday.poursuivis(:all).count
  end

  def section_travaux_overtimed
    return message_felicitations if nombre_overtimed == 0
    c = String::new
    c << "Travaux en dépassement".in_h3
    c << traite_liste_travaux( :overtimed )
    return c
  end
  def nombre_overtimed
    @nombre_overtimed ||= cur_pday.overtimed(:all).count
  end

  def message_felicitations
    "Bravo, #{pseudo}, vous n'avez aucun travail en retard, c'est un très bon boulot !".in_p(class:'blue')
  end

  # CSS à ajouter au rapport (noter qu'il servira aussi bien pour
  # le mail que pour )
  def css
    "<style type='text/css'>#{SuperFile::new(_('report.css')).read}</style>"
  rescue Exception => e
    safed_log "    # Impossible de charger la feuille de style pour le mail rapport."
    ""
  end
end #/Report
end #/User
