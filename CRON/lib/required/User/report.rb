# encoding: UTF-8
=begin

UN AN UN SCRIPT

TODO: Ce module et la classe User::Report (user.report) doit être
utilisée pour construire un rapport à l'user qui sera :
  * envoyé par mail si c'est le début de la journée
  * affiché dans le bureau de l'auteur

=end
require 'yaml'

# Pour les féminines, qu'il faut ajouter à la classe user
# Noter que c'est nécessaire ici pour tenir compte des différents
# auteurs traités.
require File.join(RACINE,'lib/deep/deeper/required/divers/feminines.rb')

class User

  include ModuleFeminines

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
    return "" if nombre_avertissements_serieux > 0 || nombre_avertissements_mineurs == 0
    safed_log "nombre_avertissements_mineurs : #{nombre_avertissements_mineurs.inspect}::#{nombre_avertissements_mineurs.class}"
    s = nombre_avertissements_mineurs > 1 ? 's' : ''
    "Notez, #{pseudo}, que vous avez #{nombre_avertissements_mineurs} avertissement#{s} mineur#{s}.".in_span(class:'warning')
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
      message_general +
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

    liste_tous_travaux
  end

  # TODO: Gérer aussi le nombre de dépassement pour avoir un
  # message qui dépendra vraiment de chaque cas.

  # Retourne le message à afficher au-dessus de toutes les listes
  # de travaux en fonction de LA PLUS GRANDE VALEUR DE DÉPASSEMENT
  # +max_overtime+ {Fixnum} de 0 à 6
  def message_general

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

    # Le message dépend aussi du stade où en est l'auteur,
    # différent si c'est au début du programme ou à la fin
    stade_programme = if cur_pday.indice < 100
      :debut
    elsif cur_pday.indice <= 260
      :milieu
    elsif cur_pday.indice > 260
      :fin
    end

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
    retards_as_array = (auteur.program.retards || "").split('')
    retards_as_array[cur_pday.indice] = retard
    retards = retards_as_array.collect{|r| r.nil? ? '0': r}.join('') # utilisé aussi plus bas
    auteur.program.set(retards: retards)

    # Est-ce un accident ? Compter le nombre de fois où
    # l'auteur est passé au même niveau ou au-dessus pour
    # déterminer le pourcentage de retard
    # Noter que ça peut être également un accident de n'avoir
    # aucun retard ;-) si l'auteur en a toujours eu.
    #
    # Cette procédure n'est faite que si l'auteur est
    # depuis plus d'un mois dans son programme.
    if cur_pday.indice > 30 && retard > 0
      nombre_retards_egal_ou_sup = 0
      nombre_retards = retards_as_array.count
      retards.split('').each do |r|
        r = r.to_i
        nombre_retards_egal_ou_sup += 0 if r >= retard
      end

      pct_retards_egaux_ou_sup = ((nombre_retards_egal_ou_sup.to_f / nombre_retards) * 100).to_i

      frequence = case true
      when pct_retards_egaux_ou_sup < 10  then :accident
      when pct_retards_egaux_ou_sup < 30  then :rare
      when pct_retards_egaux_ou_sup < 50  then :frequent
      when pct_retards_egaux_ou_sup < 70  then :souvent
      else :systematique
      end
    else
      # Trop tôt ou pas de retard
      frequence = nil
    end

    safed_log "    = retard   = #{retard}"
    safed_log "    = retards  = #{auteur.program.retards}"
    safed_log "    = frequence ? #{frequence.inspect}"

    # Si le retard est conséquent, le signaler à l'administration
    if retard > 6
      message_admin_retard = <<-ERB
<div class='warning'>DÉPASSEMENT TROP CONSÉQUENT DE #{auteur.pseudo} (##{auteur.id}) :</div>
<pre>
      Retard aujourd'hui  : #{retard}
      Données des retards : #{retards}
      Jour-programme      : #{auteur.program.current_pday}
</pre>
      ERB
      Cron::Admin::report << message_admin_retard
    end

    # Le message principal
    mess = data_messages[retard][stade_programme]
    # L'ajout du message de fréquence
    mess += data_messages[frequence][stade_programme] if frequence != nil

    # On retourne le message après avoir corrigé certaines
    # variables dynamique, à commencer par le pseudo.
    return mess % {
      pseudo: auteur.pseudo,
      f_ier:  auteur.f_ier
    }
  end

  # Grande table contenant les messages en fonction du retard
  # et du fait qu'on se trouve au début, au milieu ou à la fin
  # du programme.
  def data_messages
    @data_messages ||= YAML::load_file(_('messages_retards.yaml'))
  end

  def section_nouveaux_travaux
    return "Aucun nouveau travail.".in_p if nombre_nouveaux == 0
    c = String::new
    c << "Nouveaux travaux (#{nombre_nouveaux})".in_h3
    c << traite_liste_travaux( :nouveaux )
    return c
  end
  def nombre_nouveaux
    @nombre_nouveaux ||= cur_pday.nouveaux(:all).count
  end

  def section_travaux_poursuivis
    return "Aucun travail à poursuivre.".in_p if nombre_poursuivis == 0
    c = String::new
    c << "Travaux à poursuivre (#{nombre_poursuivis})".in_h3
    c << traite_liste_travaux( :poursuivis )
    return c
  end
  def nombre_poursuivis
    @nombre_poursuivis ||= cur_pday.poursuivis(:all).count
  end

  def section_travaux_overtimed
    return "" if nombre_overtimed == 0
    c = String::new
    c << "Travaux en dépassement".in_h3
    c << traite_liste_travaux( :overtimed )
    return c
  end
  def nombre_overtimed
    @nombre_overtimed ||= cur_pday.overtimed(:all).count
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
