# encoding: UTF-8
=begin

  Test de l'affichage d'un quiz quelconque

  Pour le moment, puisqu'il n'existe que le quiz sur le scénodico,
  on utilise celui-là.

=end
feature "Test de l'affichage d'un quiz/questionnaire" do
  scenario "Pas d'affichage si la vue est appelée sans toutes les données requises" do
    visite_route 'quiz/show'
    expect(page).to have_tag('h1', text: 'Quizzzz !')
    expect(page).to have_message('Houps ! Questionnaire inconnu…')
  end
  scenario 'Pas de questionnaire si le paramètre `qdbr` est mauvais (pas de base)' do
    visite_route 'quiz/show?qdbr=mauvaisesuffixbase'
    expect(page).to have_tag('h1', text: 'Quizzzz !')
    expect(page).to have_message('Houps ! Questionnaire inconnu…')
  end

  scenario 'Avec les bonnes données, le quiz s’affiche' do

    # Les données du quiz
    dquiz = site.dbm_table(:quiz_biblio, 'quiz').get(1)
    dquestions = site.dbm_table(:quiz_biblio, 'questions').select(where: "id IN (#{dquiz[:questions_ids].split(' ').join(', ')})")

    visite_route 'quiz/1/show?qdbr=biblio'
    expect(page).to have_tag('h1', text: 'Quizzzz !')
    expect(page).to have_tag('h2', text: /#{Regexp::escape dquiz[:titre]}/)
  end
end
