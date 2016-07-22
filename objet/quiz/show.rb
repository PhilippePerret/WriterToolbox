# encoding: UTF-8
=begin

  Module permettant l'affichage du quiz

=end
site.require_module 'quiz'

class ::Quiz

  # def initialize id
  #   id != 0 || super(id)
  # end

  def output
    if id.nil? || id == 0
      output_on_error :id_nil
    elsif suffix_base.nil?
      output_on_error :suffix_base_nil
    elsif !enable?
      output_on_error :unable
    else
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

# Le quiz courant, défini par les paramètres de l'url,
# s'ils sont bien définis.
def quiz
  @quiz ||= site.objet
end
