# encoding: UTF-8
=begin

  Module permettant l'affichage du quiz

=end

class ::Quiz

  # def initialize id
  #   id != 0 || super(id)
  # end

  # Méthode principale appelée pour afficher le
  # questionnaire
  def output
    if id.nil? || id == 0
      output_on_error :id_nil
    elsif suffix_base.nil?
      output_on_error :suffix_base_nil
    elsif !enable?
      output_on_error :unable
    else
      # Il faut ajouter les javascripts du dossier js/user et les css
      # du dossier css/user
      # Il faut ajouter les javascripts du dossier js et les css
      # du dossier css
      page.add_javascript Dir["#{Quiz.folder_lib}/js/user/**/*.js"]
      page.add_css Dir["#{Quiz.folder_lib}/css/user/**/*.css"]
      build
    end
  end

  def output_on_error err
    err =
      case err
      when :id_nil
        "Humm… Sans identifiant, impossible d'afficher un quiz !"
      when :suffix_base_nil
        "Humm… Sans base pour le quiz, impossible de l'afficher !"
      when :unable
        mess_mini = '(seuls les abonnés ont accès à tous les quiz)'.in_span(class: 'small')
        "Houps ! Désolé mais ce quiz n'est pas le quiz du jour et vous n'êtes pas abonné #{mess_mini}"
      end
    "#{err}".in_div(class: 'air warning')
  end

  # Retourne true si l'user peut consulter le quiz.
  #
  # Il peut le consulter si :
  #   - c'est le quiz courant (options[x] à 1)
  #   - c'est un user abonné
  def enable?
    user.authorized? || self.current?
  end

end

case param(:operation)
when 'evaluate_quiz'
  # On passe par ici quand on soumet le quiz
  quiz.evaluate
end
