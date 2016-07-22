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
    dqs = table_questions_biblio.select(where: "id IN (#{dquiz[:questions_ids].split(' ').join(', ')})")
    # On en fait un hash pour les récupérer plus facilement
    dquestions = Hash.new
    dqs.each do |dq|
      dquestions.merge!( dq[:id] => dq)
    end

    visite_route 'quiz/1/show?qdbr=biblio'
    expect(page).to have_tag('h1', text: /Quizzzz \!/)
    expect(page).to have_tag('h2', text: /#{Regexp::escape dquiz[:titre]}/)

    # On contrôle que tout est bien affiché
    expect(page).to have_tag('div', with: {class: 'quiz'})

    # Il doit y avoir un div pour la description du questionnaire
    expect(page).to have_tag('div', with: {class: 'quiz'}) do
      with_tag 'div', with: {class: 'quiz_description'}, text: /#{Regexp.escape dquiz[:description]}/
    end

    expect(page).to have_tag('form', with: {class: 'quiz'}) do
      dquiz[:questions_ids].split(' ').each do |qid|

        qid = qid.to_i
        dquestion = dquestions[qid]
        class_css_reponses = ['r']




        # Un DIV pour la question
        with_tag 'div', with: {class: 'question'}
        # Un DIV pour la question proprement dite
        with_tag 'div', with: {class: 'q', id: "q-#{qid}"}, text: /#{Regexp.escape dquestion[:question]}/
        # Le UL contenant les réponses
        class_css_reponses << dquestion[:type][2]
        with_tag 'ul', with: {class: class_css_reponses.join(' ')}
        type_checkbox = dquestion[:type][1] == 'c'
        reponses = JSON.parse(dquestion[:reponses])
        expect(reponses).not_to be_empty
        reponses.to_sym.each_with_index do |dreponse, ireponse|
          if type_checkbox
            with_tag 'input', with: {type: 'checkbox', name: "reponse-#{qid}-#{ireponse}"}
          else # type radio
            with_tag 'input', with: {type: 'radio', name: "reponse-#{qid}", value: "#{ireponse}"}
          end
          with_tag 'label', text: /#{Regexp.escape dreponse[:lib]}/
        end
      end # /fin boucle questions
    end

  end
end
