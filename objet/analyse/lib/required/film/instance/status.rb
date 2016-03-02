# encoding: UTF-8
class FilmAnalyse
class Film

  # Retourne true si l'utilisateur courant est
  # autorisé à voir l'analyse du film courant
  def consultable?
    # Un administrateur ou un analyse réel peuvent toujours
    # consulter les analyses, quel que soit leur stade
    # d'avancement.
    return true if user.admin? || user.real_analyste?
    # Pour les autres utilisateurs, il faut que l'analyse
    # soit au moins lisible pour qu'ils puissent la consulter

    # Si l'analyse n'a besoin d'aucun privilège, elle est
    # toujours visible
    return true if !need_signedup? && !need_subscribed?

    return true if need_subscribed? && user.subscribed?

    return true if need_signedup? && user.identified?

    # Dans tous les autres cas, l'utilisateur n'a pas le
    # droit de consulter cette analyse.
    return false
  end

end #/Film
end #/FilmAnalsye
