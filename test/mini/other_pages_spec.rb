# encoding: UTF-8

# verbose

test_route "admin/dashboard" do
  description "Un user quelconque ne peut pas atteindre le tableau de bord administration"
  html.inspect
  html.has_error "Section réservée à l'administration."
end

test_route "forum/home" do
  description "Un user quelconque peut atteindre le forum"
  responds
  html.has_title('Forum')
end

test_route "" do
  description "La page d'accueil contient un lien vers les outils"
  html.has_link("tool/list")
end
test_route "tool/list" do
  description "La liste des outils est conforme"
  non_fatal
  responds
  html.has_link("unan/home", text: "Le Programme “Un An Un Script”", count: 3)
  html.has_link("analyse/home", text: "Les Analyses de films", count: 3)
  # Une erreur volontaire :
  html.has_link("bad/link", text: "Pour générer une erreur et poursuivre")
  html.has_link("calculateur/main", text: "Le Calculateur de structure", count: 3)
  html.has_link("video/home", text: "Didacticiels-vidéo", count: 3)
  html.has_link("cnarration/home", text: "La collection Narration", count: 3)
  html.has_link("facture/main", text: "Facture d’auteur")
  html.has_link("forum/home", text: "Le Forum", count: 3)
  html.has_link("scenodico/home", text: "Le Scénodico", count: 3)
  html.has_link("filmodico/home", text: "Le Filmodico", count: 3)
end
