# encoding: UTF-8
=begin

Méthodes de gestion des erreurs

=end
class Page
  # {StringHTML} Retourne le code HTML à afficher lorsque
  # l'utilisateur essaie de rejoindre une section qui
  # nécessite une identification.
  # Rappel : protégé par raise_unless_identified
  def error_unless_identified
    Vue::new('error_unless_identified', folder_error_unless_identified, site).output
  end
  # {StringHTML} Retourne le code HTML à afficher lorsque
  # l'utilisateur essaie de rejoindre une section qui
  # nécessite d'être administrateur du site.
  # Rappel : protégé par raise_unless_admin
  def error_unless_admin
    Vue::new('error_unless_admin', folder_error_unless_admin, site).output
  end
  # Rappel : pour une protection par `raise_unless( <condition> )`
  def error_unless_condition
    Vue::new('error_unless_condition', folder_error_unless_condition, site).output
  end

  attr_accessor :message_error_not_owner
  def error_unless_owner message
    message ||= "Vous n'êtes pas le propriétaire de cette section du site, vous ne pouvez donc pas y pénétrer."
    self.message_error_not_owner = message
    Vue::new('error_unless_owner', folder_error_unless_owner, site).output
  end

  # {SuperFile} Dossier contenant la vue à afficher en
  # cas d'erreur de section sans identification
  # Pour prendre soit la vue standard soit la vue personnalisée
  # Cf. RefBook > Protection.md
  def folder_error_unless_identified
    @folder_error_unless_identified ||= folder_error_for('identified')
  end

  # {SuperFile} Dossier contenant la vue à afficher
  # en cas d'erreur de tentative d'atteinte de
  # section administrateur.
  # Pour prendre soit la vue standard soit la vue personnalisée
  # Cf. RefBook > Protection.md
  def folder_error_unless_admin
    @folder_error_unless_admin ||= folder_error_for('admin')
  end

  def folder_error_unless_condition
    @folder_error_unless_condition ||= folder_error_for('condition')
  end

  def folder_error_unless_owner
    @folder_error_unless_owner ||= folder_error_for('owner')
  end

  def folder_error_for suffix
    pfolder = site.folder_view + 'page'
    if (pfolder + "error_unless_#{suffix}.erb").exist?
      pfolder
    else
      # Sinon le dossier du fichier par défaut
      site.folder_deeper_view + 'page'
    end
  end
end
