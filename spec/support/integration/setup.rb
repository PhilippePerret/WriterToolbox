=begin

  Ajouter en haut des feuilles de test :

    require_integration_support

  Pour définir si les tests doivent avoir lieu online ou offline :

  set_offline
  set_online

=end

# ---------------------------------------------------------------------
#
#     MÉTHODES POUR LES TESTS
#
# ---------------------------------------------------------------------

def set_offline # défaut
  @test_online = false
end
def set_online
  @test_online = true
end


# ---------------------------------------------------------------------
#
#     MÉTHODES FONCTIONNELLES
#
# ---------------------------------------------------------------------

def test_offline?
  @test_online ||= false
  !@test_online
end
