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
  scenario "Sans autres données, c'est le quiz par défaut qui s'affiche" do
    test 'Sans autres données, c’est le quiz par défaut qui s’affiche'
    visite_route 'quiz/show'
    la_page_a_pour_titre 'Quizzzz !'
    la_page_naffiche_pas 'Houps ! Questionnaire inconnu…'
  end
  scenario 'Pas de questionnaire si le paramètre `qdbr` est mauvais (pas de base)' do
    test 'Pas de questionnaire si le paramètre qdbr est mauvais.'
    visite_route 'quiz/show?qdbr=mauvaisesuffixbase'
    la_page_a_pour_titre 'Quizzzz !'
    la_page_affiche 'Houps ! Questionnaire inconnu…'
    la_page_affiche('Base de données inexistante avec le suffixe fourni') if offline?
  end

  scenario 'Avec seulement le suffix de base, c’est le questionnaire courant qui s’affixe' do
    test 'S’il y a seulement le suffix de la base, on affiche le questionnaire courant.'
    dquiz = table_quiz_biblio.get(where: "options LIKE '1%'")
    # S'il n'y a aucun quiz en quiz courant, on met le quiz test
    if dquiz.nil?
      dquiz = table_quiz_biblio.get(1)
      table_quiz_biblio.update(1, {options: dquiz[:options].set_bit(0, 1) })
    end
    visite_route 'quiz/show?qdbr=biblio'
    la_page_a_pour_titre 'Quizzzz !'
    la_page_a_pour_soustitre dquiz[:titre]
    la_page_a_le_formulaire 'form_quiz'
  end

  scenario 'Avec toutes les données, le quiz voulu s’affiche' do
    test 'Avec les bonnes données, le bon quiz s’affiche si c’est un abonné.'

    # On fait de benoit un abonné
    benoit.set_subscribed

    quiz_id = 1
    # Les données du quiz
    dquiz = table_quiz_biblio.get( quiz_id )
    dqs = table_questions_biblio.select(where: "id IN (#{dquiz[:questions_ids].split(' ').join(', ')})")
    # On en fait un hash pour les récupérer plus facilement
    dquestions = Hash.new
    dqs.each do |dq|
      dquestions.merge!( dq[:id] => dq)
    end

    identify_benoit
    visite_route "quiz/#{quiz_id}/show?qdbr=biblio"
    la_page_a_pour_titre 'Quizzzz !'
    la_page_a_pour_soustitre dquiz[:titre]

    # On contrôle que tout est bien affiché
    la_page_a_la_balise 'div', class: 'quiz'

    # Il doit y avoir un div pour la description du questionnaire
    la_page_a_la_balise 'div', in: 'div.quiz', id: 'quiz_description', text: dquiz[:description],
      success: "la page contient le div de description du quiz"

    prefname = "q#{dquiz[:id]}r"
    expect(page).to have_tag('form', with: {class: 'quiz'}) do

      with_tag 'input', with: {type: 'hidden', name: 'quiz[time]'}

      dquiz[:questions_ids].split(' ').each do |qid|

        qid = qid.to_i
        dquestion = dquestions[qid]
        class_css_reponses = ['r']

        # Un DIV pour la question
        with_tag 'div', with: {class: 'question'}
        # Un DIV pour la question proprement dite
        with_tag 'div', with: {class: 'q', id: "q-#{qid}-question"}, text: /#{Regexp.escape dquestion[:question]}/
        # Le UL contenant les réponses
        class_css_reponses << dquestion[:type][2]
        with_tag 'ul', with: {class: class_css_reponses.join(' ')}
        type_checkbox = dquestion[:type][1] == 'c'
        reponses = JSON.parse(dquestion[:reponses])
        expect(reponses).not_to be_empty
        reponses.to_sym.each_with_index do |dreponse, ireponse|
          if type_checkbox
            with_tag 'input', with: {type: 'checkbox', name: "#{prefname}[rep#{qid}_#{ireponse}]"}
          else # type radio
            with_tag 'input', with: {type: 'radio', name: "#{prefname}[rep#{qid}]", value: "#{ireponse}"}
          end
          with_tag 'label', text: /#{Regexp.escape dreponse[:lib]}/
        end
      end # /fin boucle questions
    end

  end
end
