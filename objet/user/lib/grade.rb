# encoding: UTF-8
=begin
Extension de la class User gérant les grades d'utilisateur
Note : Pour le moment, ces grades ne servent que pour le forum

Le GRADE correspond au deuxième bit des options (options[1]). Plus
il est élevé, plus l'utilisateur possède de privilège.

=end
class User

  # {String} Grade forum de l'utilisateur au format humain
  def grade_humain
    @grade_humain ||= GRADES[grade][:hname]
  end

  # {String} Liste humaine des privilèges de l'auteur
  def privileges_forum
    (grade < 4 ? "seulement " : "") +
    (0..grade).collect do |igrade|
      str = GRADES[igrade][:privilege_forum]
      # On doit passer les privilèges commençant par "!!!" si ce ne
      # sont pas les privilèges du user courant
      if str.start_with?('!!!')
        (igrade != grade) ? nil : str[3..-1]
      else
        str
      end
    end.compact.pretty_join
  end
end
