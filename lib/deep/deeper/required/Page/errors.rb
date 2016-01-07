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

  # {SuperFile} Dossier contenant la vue à afficher en
  # cas d'erreur de section sans identification
  # Pour prendre soit la vue standard soit la vue personnalisée
  # Cf. RefBook > Protection.md
  def folder_error_unless_identified
    @folder_error_unless_identified ||= begin
      pfolder = site.folder_view + 'page'
      if (pfolder + 'error_unless_identified.erb').exist?
        pfolder
      else
        # Sinon le fichier par défaut
        site.folder_deeper_view + 'page'
      end
    end
  end
  # {SuperFile} Dossier contenant la vue à afficher
  # en cas d'erreur de tentative d'atteinte de
  # section administrateur.
  # Pour prendre soit la vue standard soit la vue personnalisée
  # Cf. RefBook > Protection.md
  def folder_error_unless_admin
    @folder_error_unless_admin ||= begin
      pfolder = site.folder_view + 'page'
      if (pfolder + 'error_unless_admin.erb').exist?
        pfolder
      else
        # Sinon le fichier par défaut
        site.folder_deeper_view + 'page'
      end
    end
  end
end
