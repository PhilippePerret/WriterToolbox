# encoding: UTF-8
=begin

UN AN UN SCRIPT

=end
require 'yaml'

# Pour les féminines, qu'il faut ajouter à la classe user
# Noter que c'est nécessaire ici pour tenir compte des différents
# auteurs traités.
# require File.join(RACINE,'lib/deep/deeper/required/divers/feminines.rb')

class User

  # include ModuleFeminines

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
      message:        assemblage_rapport,
      formated:       true,
      signature:      false, # signature inutile
      force_offline:  true # même offline, on envoie le rapport
    )
  end

  def assemblage_rapport
    introduction +
    built_report
  end

  def introduction
    c = String::new
    (c << welcome)                rescue nil
    (c << avertissements_serieux) rescue nil
    (c << avertissements_mineurs) rescue nil
    (c << titre_rapport.in_h2)    rescue nil
    (c << numero_jour_programme)  rescue nil
    (c << nombre_points)          rescue nil
    (c << css)                    rescue nil
    return c
  end

  def titre_rapport
    @titre_rapport ||= "Rapport du #{NOW.as_human_date(true, false, ' ')}"
  end

  # Construction du rapport de l'état des lieux de l'auteur
  # RETURN Le code HTML du rapport construit
  def built_report
    c = String::new
    (c << message_general)              rescue nil
    (c << section_travaux_overtimed)    rescue nil
    (c << section_travaux_non_started)  rescue nil
    (c << section_nouveaux_travaux)     rescue nil
    (c << section_travaux_poursuivis)   rescue nil
    (c << section_liens)                rescue nil
    c.in_section(id:'unan_inventory')
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
    c = "Attention, #{pseudo} vous avez #{nombre_avertissements_serieux} alerte#{s} sérieuse#{s} à prendre en compte"
    s = nombre_avertissements_mineurs > 1 ? 's' : ''
    c = " (et #{nombre_avertissements_mineurs} alerte#{s} mineure#{s})."
    c.in_div(class:'warning air')
  end
  # Retourne le code pour les avertissements mineurs.
  # Noter que rien n'est affiché s'il y a des avertissements sérieux
  def avertissements_mineurs
    return "" if nombre_avertissements_serieux > 0 || nombre_avertissements_mineurs == 0
    safed_log "nombre_avertissements_mineurs : #{nombre_avertissements_mineurs.inspect}::#{nombre_avertissements_mineurs.class}"
    s = nombre_avertissements_mineurs > 1 ? 's' : ''
    "Notez, #{pseudo}, que vous avez #{nombre_avertissements_mineurs} alerte#{s} mineure#{s}.".in_span(class:'warning')
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
  def numero_jour_programme
    "Vous êtes dans votre <strong>#{cur_pday.indice}<sup>e</sup> jour-programme</strong>".in_div
  end

  # ---------------------------------------------------------------------
  #   Méthodes de construction du rapport
  # ---------------------------------------------------------------------

  def section_liens
    <<-HTML
<fieldset>
  <legend>Liens utiles</legend>
  <ul class='small'>
    <li><a href="#{url_bureau_unan}">Rejoindre votre bureau</a></li>
    <li><a href="#{url_bureau_unan}&cong=preferences">Régler vos préférences</a></li>
    <li><a href="#{url_bureau_unan}&cong=aide">Aide pour le programme</a></li>
  </ul>
</fieldset>
    HTML
  end

  def url_bureau_unan
    @url_bureau_unan ||= "#{site.distant_url}/bureau/home?in=unan"
  end

  # Traite toutes les listes de travaux par type
  #
  # +kliste+ est le nom de la méthode qui définit les travaux,
  # par exemple :nouveaux pour les nouveaux ou :overtimed pour
  # les travaux en dépassement. Cette méthode est une méthode
  # de `Unan::Program::CurPDay` qui retourne une liste d'instances
  #
  # C'est la méthode qui est utilisée pour traiter toutes les
  # listes de travaux, nouveaux, poursuivis ou en dépassement
  # ci-dessous.
  #
  # La liste finale est composée ainsi :
  #     - Titre du type (tâche, page, quiz ou forum)
  #       - travail 1
  #       - travail 2
  #       ...
  #       - travail N
  #     - Titre du type
  #       - travail 1
  #       - travail 2
  #     etc.
  #
  def traite_liste_travaux kliste
    safed_log "Traitement de la liste #{kliste.inspect}"
    max_depassement = 0
    liste_tous_travaux = [:task, :page, :quiz, :forum].collect do |ltype|

      # La liste des travaux (Array de Hash)
      #
      liste_travaux = cur_pday.send(kliste, ltype)

      # S'il n'y a aucun travail de ce type, on peut s'en
      # retourner pour passer au type suivant
      next if liste_travaux.empty?

      # Le titre sous-section, en fonction du type (tâche,
      # page, etc.)
      titre_sous_section =
      case kliste
      when :unstarted
        case ltype
        when :task  then "Tâches à démarrer"
        when :page  then "Cours à marquer “vus”"
        when :forum then "Actions Forum prendre en compte"
        end
      else
        case ltype
        when :task  then "Tâches à accomplir"
        when :page  then "Pages de cours à lire ou relire"
        when :quiz  then "Questionnaires à remplir"
        when :forum then "Actions Forum à faire"
        end
      end

      sous_lis = liste_travaux.sort_by{|wdata| wdata[:reste]}.collect do |wdata|

        titre = wdata[:titre]

        dep   = wdata[:depassement]
        reste = wdata[:reste]
        max_depassement = dep if dep != nil && dep > max_depassement
        info_end = if reste == 0
          "Ce travail doit être effectué aujourd'hui".in_span(class:'orange')
        elsif reste > 1
          "Travail à effectuer dans les #{reste} jours.".in_span(class:'blue')
        elsif reste == 1
          "Ce travail doit être effectué aujourd'hui ou demain".in_span
        elsif dep > 1
          "Travail en dépassement de #{dep} jours.".in_span(class:'warning')
        elsif dep == 1
          "Petit dépassement d'un jour.".in_div(class:'warning')
        end.in_div(class:'info_end')

        # Construction de la ligne pour ce travail
        (titre + info_end).in_li(class: wdata[:css])

      end.join

      (
        titre_sous_section.in_span(class:'sous_titre_section') +
        sous_lis.in_ul
      ).in_li


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

    # FRÉQUENCE DES RETARDS
    #
    # S'il y a un problème, est-ce un accident ou l'auteur est-il
    # coutumier du fait ? Compter le nombre de fois où
    # l'auteur est passé au même niveau ou au-dessus pour
    # déterminer le pourcentage de retard
    #
    # Noter que ça peut être également un accident de n'avoir
    # aucun retard ;-) si l'auteur en a toujours eu.
    #
    # Cette procédure n'est faite que si l'auteur est
    # depuis plus d'un mois dans son programme. Elle est inutile
    # avant car ça produirait des résultats aberrants comme, par
    # exemple, des valeurs de 100% lorsqu'il n'a qu'un jour de
    # programme dans les pattes.
    #
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
    if retard > 3
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

    class_message = case true
    when retard == 0  then 'blue'
    when retard < 4   then 'paleblue'
    when retard < 7   then 'orange'
    else 'red'
    end

    # On retourne le message après avoir corrigé certaines
    # variables dynamique, à commencer par le pseudo.
    return (mess % {
      pseudo: auteur.pseudo,
      f_ier:  auteur.f_ier
    }).in_div(id:'message_general', class: class_message)
  end

  # Grande table contenant les messages en fonction du retard
  # et du fait qu'on se trouve au début, au milieu ou à la fin
  # du programme.
  def data_messages
    @data_messages ||= YAML::load_file(_('messages_retards.yaml'))
  end

  # Section avec la liste des travaux qui auraient dû
  # être démarrés mais qui ne l'ont pas été.
  # Note :
  #   - Les travaux du jour ne sont pas considérés par unstarted_by_type
  #   - Les questionnaires ne sont pas considérés
  def section_travaux_non_started
    return "" if nombre_unstarted == 0
    c = String::new
    c << "Travaux à prendre en compte (#{nombre_unstarted})".in_legend(class:'red')
    c << explication_travaux_non_started
    c << traite_liste_travaux( :unstarted )
    c.in_fieldset(class:'fs_liste_travaux')
  end
  def nombre_unstarted
    @nombre_unstarted ||= cur_pday.unstarted.count
  end
  def explication_travaux_non_started
    dunewworks = nombre_nouveaux > 1 ? "des #{nombre_nouveaux} nouveaux travaux" : "du nouveau travail"
    sonteux = nombre_nouveaux > 1 ? "sont eux" : "est lui"
    "(notez que ces travaux, qui auraient dû être “démarrés” ou marqués “vus”, ne tiennent pas compte #{dunewworks} qui #{sonteux} aussi à prendre en considération)".in_div(class:'small red')
  end

  def section_nouveaux_travaux
    return "Aucun nouveau travail.".in_p if nombre_nouveaux == 0
    c = String::new
    c << "Nouveaux travaux (#{nombre_nouveaux})".in_legend
    c << traite_liste_travaux( :nouveaux )
    return c.in_fieldset(class:'fs_liste_travaux')
  end
  def nombre_nouveaux
    @nombre_nouveaux ||= cur_pday.nouveaux.count
  end

  def section_travaux_poursuivis
    return "Aucun travail à poursuivre.".in_p if nombre_poursuivis == 0
    c = String::new
    c << "Travaux à poursuivre (#{nombre_poursuivis})".in_legend
    c << traite_liste_travaux( :poursuivis )
    return c.in_fieldset(class:'fs_liste_travaux')
  end
  def nombre_poursuivis
    @nombre_poursuivis ||= cur_pday.poursuivis.count
  end

  def section_travaux_overtimed
    return "" if nombre_overtimed == 0
    c = String::new
    c << "Travaux en dépassement".in_legend
    c << traite_liste_travaux( :overtimed )
    return c.in_fieldset(class:'fs_liste_travaux')
  end
  def nombre_overtimed
    @nombre_overtimed ||= cur_pday.overtimed.count
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
