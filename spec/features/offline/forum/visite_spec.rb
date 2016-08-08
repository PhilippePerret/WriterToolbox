=begin
  Test d'une visite complète du forum par un user normal, c'est-à-dire
  non identifié.
=end

TITRE_FORUM       = 'Le Forum'
TITRE_LIEN_FORUM  = 'Le forum'
feature "Visite du forum par un user non identifié (Marc)" do
  scenario "Marc peut rejoindre l'accueil du forum et le trouver conforme" do
    test 'Marc peut rejoindre l’accueil du forum et le trouver conforme'
    visit_route 'site/home'
    click_link 'OUTILS'
    click_link(TITRE_LIEN_FORUM, match: :first)

    puts "Marc trouve le bon titre de section"
    la_page_a_pour_titre TITRE_FORUM
    puts "Marc trouve le bon titre de sous-section"
    la_page_a_pour_soustitre 'Accueil'
    {
      # 'Vos préférences' => 'user/preferences?in=forum',
      'Soumettre' => 'sujet/question?in=forum',
      'Messages'  => 'post/list?in=forum',
      'Sujets'    => 'sujet/list?in=forum'
    }.each do |titre, href|
      la_page_a_le_lien( titre, { href: href } )
    end

    puts "Marc ne trouve pas d'onglet “Vos préférences”"
    la_page_napas_le_lien 'Vos préférences'
  end

  scenario 'Marc, non identifié, peut rejoindre les différentes parties' do
    test 'Marc, non identifié, peut rejoindre les différentes parties'
    visite_route 'forum/home'
    click_link 'Soumettre'
    la_page_a_pour_titre TITRE_FORUM
    la_page_a_pour_soustitre "Question/sujet"

    la_page_a_le_lien 'Messages', href: 'post/list?in=forum'
    click_link 'Messages'
    la_page_a_pour_titre TITRE_FORUM
    la_page_a_pour_soustitre "Messages"
    la_page_a_une_liste 'posts'

    la_page_a_le_lien 'Sujets', href: 'sujet/list?in=forum'
    click_link 'Sujets'
    la_page_a_pour_titre TITRE_FORUM
    la_page_a_pour_soustitre "Sujets"
    la_page_a_une_liste 'ul_sujets'

  end
  scenario 'Marc ne peut pas rejoindre la partie Vos Préférences, même en forçant l’adresse' do
    visite_route 'user/preferences?in=forum'
    la_page_napas_pour_titre TITRE_FORUM
    la_page_a_pour_titre 'Identification'
  end

  scenario 'Benoit, un inscrit, trouve une page d’accueil conforme' do
    identify_benoit
    visite_route 'forum/home'

    la_page_a_pour_titre TITRE_FORUM
    shot 'benoit-identified-accueil'
    la_page_a_pour_soustitre 'Accueil'
    la_page_a_le_lien 'Vos préférences'
  end
end
