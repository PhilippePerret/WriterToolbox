# encoding: UTF-8
=begin

  Test de l'affichage d'un quiz quelconque

  Pour le moment, puisqu'il n'existe que le quiz sur le scénodico,
  on utilise celui-là.

=end
feature "Test de l'affichage d'un quiz/questionnaire" do
  def table_quiz_biblio
    @table_quiz_biblio ||= site.dbm_table('quiz_biblio', 'quiz')
  end
  def table_questions_biblio
    @table_questions_biblio ||= site.dbm_table(:quiz_biblio, 'questions')
  end
  scenario "Pas d'affichage si la vue est appelée sans toutes les données requises" do
    visite_route 'quiz/show'
    expect(page).to have_tag('h1', text: /Quizzzz \!/)
    expect(page).to have_content('Houps ! Questionnaire inconnu…')
    # En offline on a un message supplémentaire
    if offline?
      expect(page).to have_content('Suffixe de base non fourni')
    end
  end
  scenario 'Pas de questionnaire si le paramètre `qdbr` est mauvais (pas de base)' do
    visite_route 'quiz/show?qdbr=mauvaisesuffixbase'
    expect(page).to have_tag('h1', text: /Quizzzz \!/)
    expect(page).to have_content('Houps ! Questionnaire inconnu…')
    if offline?
      expect(page).to have_content('Base de données inexistante avec le suffixe fourni')
    end
  end

  scenario 'Avec seulement le suffix de base, c’est le questionnaire courant qui s’affixe' do
    dquiz = table_quiz_biblio.get(where: "options LIKE '1%'")
    visite_route 'quiz/show?qdbr=biblio'
    expect(page).to have_tag('h1', text: /Quizzzz \!/)
    expect(page).to have_tag('h2', text: /#{Regexp.escape dquiz[:titre]}/)
    expect(page).to have_tag('form#form_quiz')
  end

  scenario 'Avec toutes les données, le quiz voulu s’affiche' do

    # Les données du quiz
    dquiz = table_quiz_biblio.get(1)
    dquestions = table_questions_biblio.select(where: "id IN (#{dquiz[:questions_ids].split(' ').join(', ')})")

    visite_route 'quiz/1/show?qdbr=biblio'
    expect(page).to have_tag('h1', text: /Quizzzz \!/)
    expect(page).to have_tag('h2', text: /#{Regexp::escape dquiz[:titre]}/)
  end
end
