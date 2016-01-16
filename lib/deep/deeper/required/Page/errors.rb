# encoding: UTF-8
=begin

Méthodes de gestion des erreurs

=end

# La classe d'erreur pour les erreurs non fatales mais qui doivent
# interrompre quand même le programme
# @usage
#     raise NonFatalError::new("le message", "la/redirec/tion")
#
class NonFatalError < StandardError
  attr_reader :redirection
  def initialize message, redirection = ''
    @message      = message
    @redirection  = redirection
  end
end

class Page

  # Pour avoir accès à l'erreur dans la page grâce à : page.error
  attr_accessor :error


  def error_non_fatale err
    self.error = err
    Vue::new('error_non_fatale', folder_error_for('non_fatale'), site).output
  end

  # {StringHTML} Retourne le code HTML à afficher lorsque
  # l'utilisateur essaie de rejoindre une section qui
  # nécessite une identification.
  # Rappel : protégé par raise_unless_identified
  def error_unless_identified
    Vue::new('error_unless_identified', folder_error_for('unless_identified'), site).output
  end
  # {StringHTML} Retourne le code HTML à afficher lorsque
  # l'utilisateur essaie de rejoindre une section qui
  # nécessite d'être administrateur du site.
  # Rappel : protégé par raise_unless_admin
  def error_unless_admin
    Vue::new('error_unless_admin', folder_error_for('unless_admin'), site).output
  end
  # Rappel : pour une protection par `raise_unless( <condition> )`
  def error_unless_condition
    Vue::new('error_unless_condition', folder_error_for('unless_condition'), site).output
  end

  attr_accessor :message_error_not_owner
  def error_unless_owner message
    message ||= "Vous n'êtes pas le propriétaire de cette section du site, vous ne pouvez donc pas y pénétrer."
    self.message_error_not_owner = message
    Vue::new('error_unless_owner', folder_error_for('unless_owner'), site).output
  end

  def folder_error_for suffix
    pfolder = site.folder_view + 'page'
    if (pfolder + "error_#{suffix}.erb").exist?
      pfolder
    else
      # Sinon le dossier du fichier par défaut
      site.folder_deeper_view + 'page'
    end
  end
end
