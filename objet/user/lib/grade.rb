# encoding: UTF-8
=begin
Extension de la class User gérant les grades d'utilisateur
Note : Pour le moment, ces grades ne servent que pour le forum

Le GRADE correspond au deuxième bit des options (options[1]). Plus
il est élevé, plus l'utilisateur possède de privilège.

=end
class User
  GRADES = {
    # Note par rapport aux privilèges forum : ils sont additionnés, donc
    # par exemple le privilège du 3 reprend toujours les privilèges des
    # 0, 1 et 2
    # Si la description commence par "!!!", elle ne sera ajoutée que pour
    # ce grade.
    0 => {hname:"Padawan de l'écriture",  privilege_forum:"!!!lire les posts publics"},
    1 => {hname:"Simple auditeur",        privilege_forum:"lire tous les posts"},
    2 => {hname:"Auditeur patient",       privilege_forum:"noter les posts"},
    3 => {hname:"Apprenti surveillé",     privilege_forum:"!!!écrire des réponses qui seront modérées"},
    4 => {hname:"Simple rédacteur",       privilege_forum:"répondre librement aux posts"},
    5 => {hname:"Rédacteur",              privilege_forum:"initier un sujet"},
    6 => {hname:"Rédacteur émérite",      privilege_forum:"supprimer des messages"},
    7 => {hname:"Rédacteur confirmé",     privilege_forum:"clore un sujet"},
    8 => {hname:"Maitre rédacteur",       privilege_forum:"supprimer des sujets"},
    9 => {hname:"Expert d'écriture",      privilege_forum:"bannir des utilisateurs"}
  }

  # {String} Grade forum de l'utilisateur au format humain
  def grade_humain
    @grade_humain ||= GRADES[grade][:hname]
  end
  # {Fixnum} Grade forum de l'user en nombre de 0 à 9
  def grade
    @grade ||= options[1].to_i
  end

  # Met le grade de l'use à +new_grade+
  def set_grade new_grade
    @grade = new_grade
    set_option(1, new_grade)
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
