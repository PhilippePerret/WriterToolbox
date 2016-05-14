# encoding: UTF-8
=begin

  Fichier-test qui se charge de vérifier que les principales
  pages se chargent toujours bien et contiennent les éléments
  minimum.

=end
test_route "" do
  description "Avec l'url de base, on atteind une page d'accueil conforme"

  # Commun à toute les pages
  # TODO: Peut-être faut-il faire une méthode `is_page_conforme` qui
  # se chargerait de vérifier ces éléments qu'on retrouve partout
  html.has_tags(['section#header', 'section#content', 'section#footer'])
  # Typique de la page d'accueil
  html.has_tags(['section#hot_news', ['section#hot_news div.blocactu', {count:5}]])
end
