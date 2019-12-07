=begin

  Ce module offre des méthodes pratiques pour les tests d'intégration,
  toutes les URLS simplifiée.

  Pour définir si les tests doivent avoir lieu online ou offline :

    set_offline
    set_online

  Pour charger ce module, ajouter en haut de la feuille de test :

      require_integration_support

=end

# ---------------------------------------------------------------------
#
#     MÉTHODES POUR LES TESTS
#
# ---------------------------------------------------------------------

def home_page
  test_base_url
end
def signup_page
  test_base_url + BOA.rel_signup_path
end
def signin_page
  test_base_url + BOA.rel_signin_path
end


# ---------------------------------------------------------------------
#
#     MÉTHODES FONCTIONNELLES
#
# ---------------------------------------------------------------------

def test_base_url
  'http://' +
  (test_offline? ? 'localhost/WriterToolbox/' : 'www.laboiteaoutilsdelauteur.fr/')
end
