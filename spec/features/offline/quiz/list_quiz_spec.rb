=begin
  Module de test des listes de quiz
=end
feature "Liste des quiz" do
  before(:all) do
    site.require_objet 'quiz'
  end

  def get_autre_quiz
    currentq = Quiz.get_current_quiz
    autreq = nil
    Quiz.allquiz.each do |q|
      return q if q.id != currentq.id
    end
  end

  scenario 'Un visiteur quelconque peut rejoindre la liste des quiz depuis l’accueil' do
    test 'Un visiteur quelconque peut rejoindre la liste des quiz depuis l’accueil'
    visit_home
    la_page_a_le_lien 'OUTILS'
    puts "Le visiteur clique le lien OUTILS"
    click_link 'OUTILS'
    la_page_a_pour_titre 'Outils d\'écriture'
    la_page_a_le_lien 'Les quizzzz', in: 'div#tools_quick_list',
      success: "Un lien dans la liste rapide conduit à la liste des quiz"
    la_page_a_le_lien 'Les quizzzz', in: 'dl',
      success: "Un lien dans la liste complète des outils conduit à la liste des quiz."
    within('div#tools_quick_list'){click_link 'Les quizzzz'}
    puts "Le visiteur clique le lien 'Les quizzzz'"

    # === VÉRIFICATION ===
    la_page_a_pour_titre 'Quizzzz !'
    la_page_a_le_lien 'Tous les quizzzz'
    click_link 'Tous les quizzzz'
    la_page_a_pour_titre 'Quizzzz !'
    la_page_a_pour_soustitre 'Tous les quizzzz'
    la_page_a_la_liste 'quizes', class: 'quiz_list'
    la_page_napas_la_balise 'h3', text: 'Questionnaires hors-liste'
    la_page_napas_la_liste 'quizes_hors_liste', class: 'quiz_list'
  end

  scenario 'Tous les quiz sont affichés pour un administrateur' do
    test 'Pour un administrateur, tous les quiz sont affichés'
    identify_phil
    click_link 'OUTILS'
    la_page_a_le_lien 'Les quizzzz', in: 'div#tools_quick_list',
      success: "Un lien dans la liste rapide conduit à la liste des quiz"
    la_page_a_le_lien 'Les quizzzz', in: 'dl',
      success: "Un lien dans la liste complète des outils conduit à la liste des quiz."
    within('div#tools_quick_list'){click_link 'Les quizzzz'}
    la_page_a_pour_titre 'Quizzzz !'
    la_page_a_le_lien 'Tous les quizzzz'
    click_link 'Tous les quizzzz'
    la_page_a_pour_titre 'Quizzzz !'
    la_page_a_la_balise 'h3', text: 'Questionnaires hors-liste'
    la_page_a_la_liste 'quizes_hors_liste', class: 'quiz_list'
  end

  scenario 'Un visiteur quelconque ne peut pas rejoindre un autre quiz que le dernier' do
    test 'Un visiteur quelconque ne peut pas visiter un autre quiz que le quiz courant'

    curreq = Quiz.get_current_quiz
    autreq = get_autre_quiz
    visite_route 'quiz/list'
    la_page_a_le_lien 'Le tenter', in: "li#quiz-#{autreq.suffix_base}-#{autreq.id}"
    within("li#quiz-#{autreq.suffix_base}-#{autreq.id}") do
      click_link 'Le tenter'
    end
    la_page_a_pour_titre 'Quizzzz !'
    la_page_napas_pour_soustitre autreq.titre
    la_page_a_pour_soustitre curreq.titre
    la_page_a_l_erreur 'Seuls les abonnés peuvent exécuter le questionnaire demandé.'
  end

  scenario 'Un abonné peut rejoindre un autre quiz que le courant' do
    test 'Un abonné peut rejoindre le quiz qu’il désire'
    curreq = Quiz.get_current_quiz
    autreq = get_autre_quiz

    benoit.set_subscribed
    identify_benoit
    visite_route 'quiz/list'

    la_page_a_le_lien 'Le tenter', in: "li#quiz-#{autreq.suffix_base}-#{autreq.id}"
    within("li#quiz-#{autreq.suffix_base}-#{autreq.id}") do
      click_link 'Le tenter'
    end
    la_page_a_pour_titre 'Quizzzz !'
    la_page_a_pour_soustitre autreq.titre
    la_page_napas_derreur
  end

  scenario "Un visiteur quelconque ne peut pas éditer un questionnaire" do
    test 'Un visiteur quelconque ne peut pas éditer un questionnaire'

    curq = Quiz.get_current_quiz

    visite_route 'quiz/list'

    la_page_napas_le_lien 'Éditer', in: "li#quiz-#{curq.suffix_base}-#{curq.id}"

  end

  scenario 'Un visiteur quelconque ne peut pas forcer l’édition d’un quiz' do
    test 'Un visiteur quelconque ne peut pas forcer l’édition d’un quiz'
    visite_route 'quiz/10/edit?qdbr=biblio'
    la_page_napas_pour_titre 'Quizzzz !'
    la_page_a_pour_titre 'Identification'
  end

  scenario 'Un abonné ne peut pas éditer un questionnaire' do
    test 'Un abonné ne peut pas éditer un questionnaire'

    curq = Quiz.get_current_quiz

    benoit.set_subscribed
    identify_benoit
    visite_route 'quiz/list'

    la_page_napas_le_lien 'Éditer', in: "li#quiz-#{curq.suffix_base}-#{curq.id}"

  end

  scenario 'Un visiteur abonné ne peut pas forcer l’édition d’un quiz' do
    test 'Un visiteur abonné ne peut pas forcer l’édition d’un quiz'
    benoit.set_subscribed
    identify_benoit
    visite_route 'quiz/10/edit?qdbr=biblio'
    sleep 1
    la_page_napas_le_formulaire 'edition_quiz'
  end

  scenario 'Un administrateur peut éditer un questionnaire' do
    test 'Un administrateur peut éditer un questionnaire'

    curq = Quiz.get_current_quiz

    identify_phil
    visite_route 'quiz/list'

    la_page_a_le_lien 'Éditer', in: "li#quiz-#{curq.suffix_base}-#{curq.id}"

  end

  scenario 'Un administrateur peut forcer l’édition d’un quiz par la route' do
    test 'Un administrateur peut forcer l’édition d’un quiz par la route'
    identify_phil
    visite_route 'quiz/10/edit?qdbr=biblio'
    la_page_a_le_formulaire 'edition_quiz'
  end

end
