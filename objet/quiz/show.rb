# encoding: UTF-8
=begin

  Module permettant l'affichage du quiz

=end
site.require_module 'quiz'


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
      page.add_javascript Dir["#{site.folder_module}/quiz/js/user/**/*.js"]
      page.add_css Dir["#{site.folder_module}/quiz/css/user/**/*.css"]
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

  # Suffix du nom de la base
  #
  # IL est contenu dans la variable qdbr (qui signifie "q" pour "quiz",
  # "db" pour "database" et "r" pour relname, le nom relatif, sans 'quiz'
  # et sans la racine des bases de données — 'boite-a-outils' pour le BOA)
  def suffix_base
    @suffix_base ||= begin
      sb = param(:qdbr).nil_if_empty
      if SiteHtml::DBM_TABLE.database_exist?("boite-a-outils_quiz_#{sb}")
        sb
      else
        nil
      end
    end
  end
end

# Utile quand aucun questionnaire n'est défini, on crée une
# instance NoQuiz pour la mettre dans `quiz` pour gérer facilement
# l'affichage, sans conditions
class NoQuiz
  def output
    'Houps ! Questionnaire inconnu… :-('.in_div(class: 'big air warning') +
    (OFFLINE ? "(#{Quiz.error})".in_p(class: 'tiny') : '')
  end
end


# Le quiz courant, défini par les paramètres de l'url,
# s'ils sont bien définis.
#
# Différents cas peuvent se produire :
#   Cas 1 - Aucun ID dans l'url
#     =>  Pas d'objet_id pour la route,
#     Si qdbr est défini dans les paramètres
#       =>  On prend le questionnaire courant
#     Sinon
#       => Une erreur fatale
#   Cas 2 - Un ID dans l'url mais qui n'existe pas
#     => On crée l'instance, mais elle dira que le questionnaire
#       n'existe pas.
#   Cas 3 - Un ID valide dans l'URL
#     Tout est normal.
def quiz
  @quiz ||= begin
    if site.route.objet_id.nil?
      q = ::Quiz.current
      if q.nil?
        NoQuiz.new
      else
        q
      end
    else
      site.objet
    end
  end
end

case param(:operation)
when 'evaluate_quiz'
  # On passe par ici quand on soumet le quiz
  quiz.evaluate
end
