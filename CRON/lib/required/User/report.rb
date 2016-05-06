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
      subject:        "Rapport journalier du #{NOW.as_human_date}",
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
      safed_log " - ltype = #{ltype.inspect}"
      safed_log "   cur_pday.send(kliste, ltype) = #{cur_pday.send(kliste, ltype).inspect}"
      cur_pday.send(kliste, ltype).collect do |wdata|

        titre = wdata[:titre]

        data_type = Unan::Program::AbsWork::TYPES[wdata[:type_w]]
        if data_type.nil?
          safed_log "# PROBLÈME DE TYPE : :type_w non défini ou introuvable dans #{wdata.inspect}"
        else
          titre = "#{data_type[:hname]} : “#{titre}”"
        end

        alerte = if wdata[:depassement].nil?
          ""
        else
          dep = wdata[:depassement]
          max_depassement = dep if dep > max_depassement
          if dep > 1
            "Travail en dépassement de #{dep} jours."
          else
            "Petit dépassement d'un jour."
          end.in_div(class:'warning')
        end
        # Construction de la ligne pour ce travail
        (titre + alerte).in_li(class: wdata[:css])
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
    return "" if max_overtime == 0
    case max_overtime
    when 1 then "Petit dépassement"
    when 2 then ""
    when 3 then ""
    when 4 then ""
    when 5 then ""
    when 6 then ""
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
    <<-CSS
<style type="text/css">
.small {font-size: 11pt}
.italic{font-style: italic}
section#unan_inventory{font-size:13pt}
section#unan_inventory ul.liste_travaux{
  border: 1px dashed blue;
}
/* Spécialement pour la liste des travaux en dépassement */
section#unan_inventory ul#liste_travaux_overtimed {
  color: red;
}
</style>
    CSS
  end

end #/Report
end #/User
