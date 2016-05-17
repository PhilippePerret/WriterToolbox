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

DATA_PAGES_OUTILS = {
  "unan/home"     => {title: "Le programme “Un An Un Script”"},
  "analyse/home"  => {title: "Les Analyses de films"},
  "calculateur/main"  => {title: "Le Calculateur de structure"},
  "video/home"  => {title: "Les Didacticiels-vidéo"},
  "cnarration/home"  => {title: "La collection Narration"},
  "facture/main"  => {title: "La Facture d’auteur"},
  "forum/home"  => {title: "Le Forum"},
  "scenodico/home"  => {title: "Le Scénodico"},
  "filmodico/home"  => {title: "Le Filmodico"}
}


test_route "tool/list" do
  description "La liste des outils est conforme"
  non_fatal
  responds
  DATA_PAGES_OUTILS.each do |route, droute|
    html.has_link(route, text: droute[:title], count: 3)
  end
end

# On teste que chaque page de chaque outil soit atteignable et
# présente une page conforme.
DATA_PAGES_OUTILS.each do |route, droute|
  test_route route do
    description "La route #{route} conduit à la page “#{droute[:title]}”"
    responds
    html.has_title(droute[:title])
  end
end
