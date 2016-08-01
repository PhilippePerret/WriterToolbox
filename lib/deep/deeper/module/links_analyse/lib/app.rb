# encoding: UTF-8
=begin
  Définitions propre à l'application

  Notamment la méthode TestedPage#valide? qui détermine comment
  on considère qu'une page est valide.

=end
# Pour tester le programme, limiter le nombre de routes
# testées
# Mettre à NIL pour les tester toutes.
NOMBRE_MAX_ROUTES_TESTED = nil

# Pour tester onlin ou offline
TEST_ONLINE = false # false => test local

# Mettre à TRUE pour que la boucle s'interrompe à la première
# erreur rencontrée
FAIL_FAST = true

# Mettre à TRUE pour voir les routes collectées sur chaque page au
# fil de l'analyse
SHOW_ROUTES_ON_TESTING = false

# Route de démarrage du test
#
# Par défaut, c'est 'site/home'
#
# Pour essayer une unique route, par exemple une route qui pose problème
# Mais penser qu'il faut indiquer ici la route de la page qui contient
# le lien qui pose problème, pas le lien lui-même.
# Par exemple, en créant ce test, la route http://www.laboiteaoutilsdelauteur.fr
# posait problème — oui, je sais, un comble — mais c'est la page
# scenodico/251/show qui la contenait, donc c'est elle qu'il fallait que
# je mette en seule page à tester
# Régler aussi NOMBRE_MAX_ROUTES_TESTED ci-dessus pour limiter le test, mais
# penser à laisser un nombre assez grand pour comprendre la route à tester à
# l'intérieur de la page s'il y en a beaucoup avant.
# ROUTE_START = 'scenodico/251/show'


# ---------------------------------------------------------------------

class TestedPage

  # Return TRUE si l'url testée est valide, au niveau de son
  # contenu, ou FALSE dans le cas contraire, en mettant de @errors
  # toutes les erreurs éventuelles
  #
  # Définit toutes les erreurs rencontrées
  #
  def check_if_valide
    # Éléments qu'on doit forcément trouver dans la page
    [
      'section#header', 'section#content', 'section#footer',
      'section#left_margin'
    ].each do |tag|
      if self.matches?(tag)
        true
      else
        error "TAG INTROUVABLE : #{tag}"
      end

    end #/fin de loop sur tous les éléments de base à trouver


    # === MESSAGE ERREUR ===
    # Voir si la page contient un message d'erreur, dans
    # une balise flash
    if self.matches?('div#flash div', with: {class: 'error'})
      nokogiri.css('div#flash div.error').each do |message_erreur|
        error "MESSAGE ERREUR TROUVÉ : #{message_erreur.inner_html}"
      end
    end

    # === TEXTE INDIQUANT UNE ROUTE INTROUVABLE ===
    if self.matches?('h1', text: 'Erreur 404')
      messages_erreur = Array.new
      nokogiri.css('section#content div.air.warning').each do |meserr|
        messages_erreur << meserr.inner_html
      end
      error "ERREUR 404 : #{messages_erreur.join(', ')}"
    end

    return @errors.count == 0
  end

end
