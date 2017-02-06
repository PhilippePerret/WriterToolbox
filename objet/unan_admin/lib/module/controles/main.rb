# encoding: UTF-8
=begin

  Contrôle du programme UNAN
  --------------------------
  Ce module permet de checker les erreurs possibles dans la
  définition du programme. Il a été initié pour empêcher d'utiliser
  deux fois la même page de cours dans la définition des works.

=end
class UnanAdmin
class Control
class << self

  # Méthode principale qui lance le controle
  def run
    # On passe en revue les différents contrôles à effectuer
    [
      'unicite_utilisation_pages_cours'
    ].each do |control|
      run_controle control
    end
  end

  # Méthode principale qui affiche le résultat du controles
  def output
    'Contrôle du programme UNAN'.in_h3 +
    @messages.join('')
  end

  # Pour le suivi des messages
  def log message
    @messages ||= Array.new
    message.start_with?('<') || message = message.in_div
    @messages << message
  end

  # ---------------------------------------------------------------------

  def run_controle ctrl
    log "--> #{ctrl}"
    send(ctrl.to_sym)
    log "&lt;-- #{ctrl}"
  end

end #/<< self
end #/Control
end #/UnanAdmin
