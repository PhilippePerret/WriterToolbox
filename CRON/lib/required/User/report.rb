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


  def titre_rapport
    @titre_rapport ||= "Rapport du #{NOW.as_human_date(true, false, ' ')}"
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




    safed_log "    = retard   = #{retard}"
    safed_log "    = retards  = #{auteur.program.retards}"
    safed_log "    = frequence ? #{frequence.inspect}"


    # Le message principal
    mess = data_messages[retard][stade_programme]
    # L'ajout du message de fréquence
    mess += data_messages[frequence][stade_programme] if frequence != nil


    # On retourne le message après avoir corrigé certaines
    # variables dynamique, à commencer par le pseudo.
    return (mess % {
      pseudo: auteur.pseudo,
      f_ier:  auteur.f_ier
    }).in_div(id:'message_general', class: class_message)
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
