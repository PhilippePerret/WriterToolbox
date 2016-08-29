# encoding: UTF-8
=begin

  Module utilisé par tous les modules show, edit, etc.

  Sert principalement à connaitre le quiz courant.

=end

# Le quiz courant, défini par les paramètres de l'url,
# s'ils sont bien définis.
#
# À présent, c'est toujours le quiz courant qui est
# utilisé.
# TODO Il faudra juste surveiller que ça fonctionne
# bien avec l'édition.
#
def quiz
  @quiz ||= Quiz.current
end
