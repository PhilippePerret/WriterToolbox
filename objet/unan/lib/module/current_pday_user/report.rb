# encoding: UTF-8
=begin

  Extension à la classe User::CurrentPDay pour construire le mail
  "quotidien" de l'auteur suivant le programme UN AN

=end
module CurrentPDayClass
  class CurrentPDay

  # Retourne le code HTML complet du rapport
  #
  # C'est le texte qui sera transmis à l'auteur suivant
  # le programme.
  #
  def rapport_complet
    styles_css + introduction + built_report
  end
  alias :whole_report :rapport_complet


  def styles_css
    '<style type="text/css">' +
      SuperFile.new(_('texte/report.css')).read +
    '</style>'
  end

  def introduction
    c = ''
    c << welcome
    c << titre_rapport
    c << avertissements
    c << cadre_chiffres
    return c
  end

  def built_report
    c = ''
    c << message_general
    c << section_travaux_overrun
    c << section_travaux_unstarted
    c << section_nouveaux_travaux
    c << section_travaux_poursuivis
    c << section_liens
    c.in_section(id:'unan_inventory')
  end

  # ---------------------------------------------------------------------
  #   MÉTHODES DE CONSTRUCTION
  # ---------------------------------------------------------------------

  def titre_rapport
    "Rapport de travail UN AN<br>#{NOW.as_human_date(false, false, ' ')}".in_h2
  end
  # Le cadre contenant le nombre de point et l'indice
  # du jour programme.
  def cadre_chiffres
    c = ''
    c << numero_jour_programme
    c << numero_jour_reel
    c << nombre_points
    c << message_note_generale
    c.in_div(id: 'cadre_chiffres').in_div(class: 'center')
  end

  # ---------------------------------------------------------------------
  #   Sections des travaux
  #
  #   Des fieldsets qui listent les travaux
  #
  # ---------------------------------------------------------------------

  def section_travaux_overrun
    # On retourne un string vide s'il n'y a aucun travail en
    # retard.
    return '' if uworks_overrun.count == 0
    c = ''
    c << texte_type('explications_overrun').in_div(class: 'explication')
    c << traite_liste_travaux(uworks_overrun, :overrun)
    c.in_fieldset(id: 'fs_works_overrun', class: 'fs_works', legend: "Travaux en dépassement (#{uworks_overrun.count})")
  end

  def section_travaux_unstarted
    return '' if aworks_unstarted.count == 0
    c = ''
    c << texte_type('explications_unstarted').in_div(class: 'explication')
    c << traite_liste_travaux(aworks_unstarted, :unstarted)
    c.in_fieldset(id: 'fs_works_unstarted', class: 'fs_works', legend: "Travaux à démarrer (#{aworks_unstarted.count})")
  end

  def section_nouveaux_travaux
    return '' if aworks_ofday.count == 0
    c = ''
    c << texte_type('explications_new').in_div(class: 'explication')
    c << traite_liste_travaux(aworks_ofday, :new)
    c.in_fieldset(id: 'fs_new_works', class: 'fs_works', legend: "Nouveaux travaux (#{aworks_ofday.count})")
  end

  def section_travaux_poursuivis #goon
    return '' if uworks_goon.count == 0
    c = ''
    c << texte_type('explications_goon').in_div(class: 'explication')
    c << traite_liste_travaux(uworks_goon, :goon)
    c.in_fieldset(id: 'fs_poursuivis', class: 'fs_works', legend: "Travaux poursuivis (#{uworks_goon.count})")
  end

  # ---------------------------------------------------------------------
  #   Textes types
  # ---------------------------------------------------------------------
  def welcome
    texte_type 'welcome'
  end

  def section_liens
    texte_type 'section_liens'
  end

  # ---------------------------------------------------------------------
  # Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  # Retourne un texte déserbé du dossier ./texte de ce dossier
  def texte_type faffixe
    SuperFile.new(_("texte/#{faffixe}.erb")).deserb(self)
  end

  # Méthode qui reçoit une liste de travaux tels que formée par
  # le module `lists` (c'est-à-dire les listes aworks_unstarted, etc.)
  # et qui retourne un UL contenant les travaux classés par type avec
  # un titre.
  #
  # Rappel : +liste+ est un Array de Hash où chaque Hash contient
  # au minimum :
  #   :awork_id     ID du travail absolu
  #   :uwork_id     ID du travail de l'auteur
  #   :pday         Le jour-programme du travail (son début)
  # D'autres valeurs peuvent se trouver dans le hash, par exemple :
  #   :since        Un travail non démarré aurait dû l'être depuis ce
  #                 nombre de jours.
  #   :reste        Un travail qui se poursuit doit être achevé à ce
  #                 moment-là.
  #   :overrun      Le nombre de jours-programme de dépassement.
  #
  # Le +ltype+ détermine le type de travail, parmi :
  #   :new            Nouveaux travaux
  #   :goon           Travail qui se poursuit
  #   :overrun        En dépassement de temps
  #   :unstarted      Non démarrés
  #
  def traite_liste_travaux liste, ltype = nil

    # La liste des travaux, qu'on va classer par type (page
    # de cours, tâche, etc.)
    liste_by_type = Hash.new

    (liste || []).each do |hw|

      # # TODO À mettre plus tard, si c'est nécessaire, car il me semble
      # # que :id dans :hw correspond à :awork_id
      # hw[:awork_id] ||= hw[:id]

      # On prend toujours les données du travail absolu
      args = {colonnes: [:titre, :type_w]}
      if hw[:awork_id] == nil
        # Une erreur qui se produit suivant au cours du cron-job et qu'il
        # faut détailler un peu plus
        mess_err =
          begin
            <<-HTML
            <pre>
              PROBLÈME TRAITEMENT TRAVAUX (#{self.class}#traite_liste_travaux)
              Auteur : #{auteur.pseudo} (##{auteur.id})
              Type travail traité (ltype) : #{ltype}
              Donnée de l'élément de liste (hw) : #{hw.inspect}
            </pre>
            HTML
          rescue Exception => e
            "Impossible de construire le message d'erreur : #{e.message}" +
            "hw = #{hw.inspect}"
          end
        site.send_mail_to_admin(
          subject: "PROBLÈME DANS LE TRAITEMENT DES TRAVAUX",
          formated: true,
          message:  mess_err
        )
        next
      else
        awork = Unan.table_absolute_works.get(hw[:awork_id], args)
      end

      # On ajoute la propriété :awork qui permettra de retrouver
      # au moins le titre.
      hw.merge! awork: awork

      # On doit classer les travaux par type pour un meilleur
      # affichage.
      # +type_w+ va être égal à :task, :page, :quiz ou :forum
      type_w = Unan::Program::AbsWork::TYPES[awork[:type_w]][:type]

      liste_by_type.key?(type_w) || liste_by_type.merge!(type_w => [])
      liste_by_type[type_w] << hw
    end

    # Maintenant que les travaux sont classés par type, on peut
    # faire l'affichage.
    liste_by_type.collect do |typew, arr_hw|
      Unan::Program::AbsWork::TYPES_TO_TITRE[typew].in_div(class: 'listew_titre') +
      arr_hw.collect do |hw|
        # Ajout en fonction du type de liste (nombre de jours de
        # dépassement, nombre de jours restants, etc.)
        ajout =
        case ltype
        when :overrun
          " (<strong>#{jours_real hw[:overrun]} de dépassement</strong>)"
        when :goon
          " (reste #{jours_real hw[:reste]})"
        when :unstarted
          " (depuis <strong>#{jours_real hw[:since]}</strong>)"
        else
          ''
        end
        # La rangée LI finale
        ('<span class="tiret">-</span>' + hw[:awork][:titre] + ajout).in_li(class: 'work')
      end.join('')
    end.join('').in_ul(class: 'listw', id: "listw-#{ltype}")
  end

  # ---------------------------------------------------------------------
  #   Méthodes utilitaires
  # ---------------------------------------------------------------------

  # Reçoit un nombre de jours-programme et retourne un
  # nombre de jours réels, avec les heures approximatives
  def jours_real jprogs
    # DURÉE_RÉELLE = DURÉE_PROGRAMME.to_f / coefficiant_duree
    rj = (jprogs.to_f / program.coefficient_duree).round(2)
    nombre_jours, portion_jour = rj.to_s.split('.')
    s_jour = nombre_jours.to_i > 1 ? 's' : ''
    portion_jour = portion_jour.to_i
    if portion_jour == 0
      "#{nombre_jours} jour#{s_jour}"
    elsif portion_jour < 10 # 0 à 11
      if nombre_jours.to_i > 1
        "un peu plus de #{nombre_jours} jour#{s_jour}"
      else
        "un peu plus d'1 jour"
      end
    elsif portion_jour < 35 # 10 à 35
      "#{nombre_jours} jour#{s_jour} 1/4"
    elsif portion_jour < 65 # 35 à 65
      "#{nombre_jours} jour#{s_jour} et demi"
    elsif portion_jour < 85 #
      "#{nombre_jours} jour#{s_jour} 3/4"
    else
      "presque #{nombre_jours + 1} jours"
    end
  end


  def url_bureau_unan
    @url_bureau_unan ||= "#{site.distant_url}/bureau/home?in=unan"
  end

  def bind; binding() end

end #/CurrentPDay
end #/module CurrentPDayClass
