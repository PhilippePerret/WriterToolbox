# encoding: UTF-8
=begin

  Module utilisé par tous les modules show, edit, etc.

  Sert principalement à connaitre le quiz courant.

=end

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
    q =
      if site.route.objet_id.nil?
        ::Quiz.current
      else
        site.objet
      end
    q != nil || raise('LE QUIZ NE DEVRAIT JAMAIS POUVOIR ÊTRE NUL.')
    q
  end
end
