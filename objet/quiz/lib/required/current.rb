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
    # TODO Il faut gérer ici tous les cas possibles
    # On essaie de prendre le questionnaire si les données sont
    # fournies
    # On doit voir si l'user courant peut voir le questionnaire
    # qu'il veut voir.
    # En premier dernier recours, on doit afficher le questionnaire
    # courant.
    # En tout dernier recours, c'est-à-dire sans questionnaire
    # courant, on prend le dernier quiz créé qui n'est pas en fabrication
    # et on
    # TODO : Il faut utiliser un bit d'option pour indiquer que le
    # quiz est en fabrication
    # TODO : IL FAUT UN SYSTÈME qui définisse automatiquement le dernier
    # quiz fabriqué comme quiz courant lorsque ce dernier n'est pas
    # défini. Et on avertit l'administration de cette opération.
    if site.route.objet_id.nil?
      ::Quiz.current
    else
      site.objet
    end || raise('LE QUIZ NE DOIT JAMAIS ÊTRE NUL.')
  end
end
