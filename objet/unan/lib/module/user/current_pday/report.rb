# encoding: UTF-8
=begin

  Extension à la classe User::CurrentPDay pour construire le mail
  "quotidien" de l'auteur suivant le programme UN AN UN SCRIPT

=end
class User
class CurrentPDay

  # = main =
  #
  # Produit le code du mail qui doit être envoyé à l'auteur
  #
  def mail_quotidien

  end

  # Retourne le code HTML complet du rapport
  def report
    introduction + built_report
  end

  def introduction
    c = ''
    c << welcome
    # (c << avertissements_serieux) rescue nil
    # (c << avertissements_mineurs) rescue nil
    # (c << titre_rapport.in_h2)    rescue nil
    # (c << numero_jour_programme)  rescue nil
    # (c << nombre_points)          rescue nil
    # (c << css)                    rescue nil
    return c
  end

  def built_report
    c = ''
    # (c << message_general)              rescue nil
    c << section_travaux_overrun
    c << section_travaux_unstarted
    # (c << section_nouveaux_travaux)     rescue nil
    # (c << section_travaux_poursuivis)   rescue nil
    c << section_liens
    c.in_section(id:'unan_inventory')
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

    c.in_fieldset(id: 'fs_works_overrun', legend: 'Travaux en dépassement')
  end

  def section_travaux_unstarted
    return '' if uworks_unstarted.count == 0
    c = ''

    c.in_fieldset(id: 'fs_works_unstarted', legend: 'Travaux à démarrer')
  end

  # ---------------------------------------------------------------------
  #   Textes types
  # ---------------------------------------------------------------------
  def welcome
    SuperFile.new(_('texte/welcome.erb')).deserb( self )
  end

  def section_liens
    SuperFile.new(_('texte/section_liens.erb'))
  end

  # ---------------------------------------------------------------------
  #   Méthodes utilitaires
  # ---------------------------------------------------------------------

  def url_bureau_unan
    @url_bureau_unan ||= "#{site.distant_url}/bureau/home?in=unan"
  end

  def bind; binding() end

end #/CurrentPDay
end #/User
