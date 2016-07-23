=begin

  Module pour contrôler le calcul du questionnaire.

  Pour ce faire, on prend le questionnaire 1 sur le scénodico, dans
  la base "quiz_biblio".

  Ce test teste autant l'interface que le calcul lui-même :
  On sélectionne des réponses et on estime le résultat retourné.
=end
feature "Vérification des calculs du quiz" do
  def table_quiz_biblio
    @table_quiz_biblio ||= site.dbm_table('quiz_biblio', 'quiz')
  end
  def table_questions_biblio
    @table_questions_biblio ||= site.dbm_table('quiz_biblio', 'question')
  end

  before(:all) do
    # Il faut prendre le questionnaire courant pour le remettre en
    # fin de processus
    # et mettre le premier en quiz courant
    @dquiz_courant = table_quiz_biblio.select(where: "options LIKE '1%'").first
    @quiz_courant_id = @dquiz_courant[:id]
    puts "@quiz_courant_id = #{@quiz_courant_id.inspect}"

    @dquiz_un = table_quiz_biblio.get(1)
    opts = @dquiz_un[:options]
    opts[0] = '1'
    table_quiz_biblio.update(1, options: opts)

  end
  after(:all) do
    # Remettre le quiz courant
    puts "@quiz_courant_id à remettre = #{@quiz_courant_id.inspect}"
    puts "Options du quiz ##{@quiz_courant_id} remises à : #{@dquiz_courant[:options].inspect}"
    table_quiz_biblio.update(@quiz_courant_id, {options: @dquiz_courant[:options]})
    puts "Options du quiz #1 remises à #{@dquiz_un[:options].inspect}"
    table_quiz_biblio.update(1, options: @dquiz_un[:options])
  end

  scenario 'Quand l’utilisateur ne soumet aucune réponse' do
    visite_route 'quiz/1/show?qdbr=biblio'
    expect(page).to have_css('h1', text: 'Quizzzz !')
    expect(page).to have_tag('form#form_quiz') do
      with_tag 'input', with: {type: 'submit', value: 'Soumettre le quiz'}
    end
    within('form#form_quiz') do
      click_button 'Soumettre le quiz'
    end
    # === Test ===
    expect(page).to have_content('Voyons ! Il faut remplir le quiz, pour obtenir une évaluation !')
  end

  scenario 'Quand l’utilisateur ne soumet pas toutes les réponses' do
    visite_route 'quiz/1/show?qdbr=biblio'
    expect(page).to have_css('h1', text: 'Quizzzz !')
    within('form#form_quiz') do
      # On sélectionne une première réponse
      choose('Il faut répondre à toutes les questions, pour obtenir une évaluation intéressante.')
      click_button 'Soumettre le quiz'
    end

    # === Test ===
    expect(page).to have_content('Voyons ! Il faut remplir le quiz, pour obtenir une évaluation !')
  end

  scenario 'Quand l’user soumet toutes les réponses' do
    pending "à implémenter"
  end
end
