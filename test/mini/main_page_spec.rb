# encoding: UTF-8
=begin

  Fichier-test qui se charge de vérifier que les principales
  pages se chargent toujours bien et contiennent les éléments
  minimum.

=end
test_route "" do
  # description "Avec l'url de base, on atteind une PAGE D'ACCUEIL CONFORME"

  # Commun à toute les pages
  # TODO: Peut-être faut-il faire une méthode `is_page_conforme` qui
  # se chargerait de vérifier ces éléments qu'on retrouve partout
  html.has_tags(['section#header', 'section#content', 'section#footer'])
  # Typique de la page d'accueil
  html.has_tags(['section#hot_news', ['section#hot_news div.blocactu', {count:6}]])

  html.has_tags([
    ['a', {text:"S'inscrire",   href:BOA.rel_signup_path, strict:true}],
    ['a', {text:"S'identifier", href:BOA.rel_signin_path, strict:true}]
    ])
end
