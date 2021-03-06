=begin

  TEST TRÈS COMPLET (cf. ci-dessous)

  Module pour contrôler le calcul du questionnaire.

  Pour ce faire, on prend le questionnaire 1 sur "quiz_biblio".

  Ce test teste autant l'interface que le calcul lui-même :
  On sélectionne des réponses et on estime le résultat retourné.

  Il teste aussi que les résultats soient enregistrés s'il s'agit
  d'un utilisateur enregistré.

  Le visiteur se rend aussi sur son profil pour voir que le questionnaire
  a été listé et il clique sur son nom pour le revoir affiché.

=end

feature "Vérification des calculs du quiz" do

  # Ces données questions doivent être modifiées si le
  # questionnaire test est modifié.
  #
  # Rappel : le questionnaire test est le questionnaire 1 de la
  # base 'boite-a-outils_quiz_biblio'
  #
  def data_questions
    @data_questions ||= begin
      {
        10 => {
          good: 'Troisième réponse de première question (bonne)',
          index_good: 2,
          bad:  'Deuxième réponse de première question',
          index_bad: 1,
          points: 10,
          points_bad: 0,
        type: :radio
        },
        11 => {
          good: 'Première réponse deuxième question (bonne)',
          index_good: 0,
          bad:  'Deuxième réponse deuxième question',
          index_bad: 1,
          points: 20,
          points_bad: 0,
          type:  :radio
        },
        12 => {
          good: ['Deuxième choix bon', 'Quatrième choix bon'],
          index_good: [1,3],
          bad:  ['Premier choix', 'Quatrième choix bon'],
          index_bad: [0,3],
          points:     15,
          points_bad: 5,
          type:  :checkbox
        }
      }
    end
  end


  def remplir_quiz hreps = nil
    hreps ||= Hash.new
    points_max  = 0
    points_user = 0
    bads_ids = hreps[:bads] || Array.new

    within('form.quiz') do
      # Définir les identifiants des questions qui seront justes
      # et celles qui seront fausses
      data_questions.each do |qid, qdata|
        points_max += qdata[:points]
        as_bad = bads_ids.include?(qid)
        points_user += as_bad ? qdata[:points] : qdata[:points_bad]
        page.execute_script("UI.scrollTo('div#question-#{qid}',100)")
        within("div#question-#{qid}") do
          if qdata[:type] == :radio
            choose(qdata[as_bad ? :bad : :good])
          else
            (qdata[as_bad ? :bad : :good]).each do |rep|
              check(rep)
            end
          end
        end
      end
      shot 'before-submit-reponses'
      click_button 'Soumettre le quiz'
    end
    return [points_max, points_user]
  end


  def table_quiz_biblio
    @table_quiz_biblio ||= site.dbm_table('quiz_biblio', 'quiz')
  end
  def table_questions_biblio
    @table_questions_biblio ||= site.dbm_table('quiz_biblio', 'question')
  end
  def table_resultats_biblio
    @table_resultats_biblio ||= site.dbm_table('quiz_biblio', 'resultats')
  end

  before(:all) do
    # Il faut prendre le questionnaire courant pour le remettre en
    # fin de processus
    # et mettre le premier en quiz courant
    @dquiz_courant = table_quiz_biblio.select(where: "options LIKE '1%'").first
    if @dquiz_courant.nil?
      @dquiz_courant = table_quiz_biblio.select.first
      table_quiz_biblio.update(@dquiz_courant[:id], options: @dquiz_courant[:options].set_bit(0,1))
    end
    @quiz_courant_id = @dquiz_courant[:id]

    @dquiz_un = table_quiz_biblio.get(1)
    opts = @dquiz_un[:options]
    opts[0] = '1'
    table_quiz_biblio.update(1, options: opts)

    # Pour conserver les users à détruire
    $users2destroy = Array.new

  end
  after(:all) do
    begin
      # Remettre le quiz courant
      table_quiz_biblio.update(@quiz_courant_id, {options: @dquiz_courant[:options]})
      # On force toujours la remise à 0 (même en cas d'erreur, quand
      # le premier bit a été laissé à 1 par erreur au cours d'un test précédent)
      opts = @dquiz_un[:options]
      opts[0] = '0'
      table_quiz_biblio.update(1, options: opts)
    rescue Exception => e
      puts "ERREUR : #{e.message}"
      puts e.backtrace.join("\n")
    end
    begin
      if $users2destroy.count > 0
        site.dbm_table(:hot, 'users').delete(where: "id IN (#{$users2destroy.join(', ')})")
      end
    rescue Exception => e
      puts "ERREUR : #{e.message}"
      puts e.backtrace.join("\n")
    end
  end

  scenario 'Quand l’utilisateur ne soumet aucune réponse' do
    visite_route 'quiz/1/show?qdbr=biblio'
    la_page_a_pour_titre 'Quizzzz !'
    la_page_a_le_formulaire 'form_quiz-1'
    la_page_a_la_balise 'input', in: 'form#form_quiz-1', type: 'submit', value: 'Soumettre le quiz',
      success: 'Le quiz possède un bouton pour le soumettre.'
    within('form#form_quiz-1') do
      click_button 'Soumettre le quiz'
    end
    # === Test ===
    expect(page).to have_content('Voyons ! Il faut remplir le quiz, pour obtenir une évaluation !')
  end

  scenario 'Quand l’utilisateur ne soumet pas toutes les réponses' do
    visite_route 'quiz/1/show?qdbr=biblio'
    expect(page).to have_css('h1', text: 'Quizzzz !')
    within('form#form_quiz-1') do
      # On sélectionne une première réponse
      choose('Deuxième réponse de première question')
      click_button 'Soumettre le quiz'
    end

    # === Test ===
    expect(page).to have_content('Il faut répondre à toutes les questions, pour obtenir une évaluation intéressante.')
  end

  scenario 'Quand l’user soumet toutes les réponses justes' do
    visite_route 'quiz/1/show?qdbr=biblio'
    expect(page).to have_css('h1', text: 'Quizzzz !')
    data_form = Hash.new
    data_questions.each do |qid, qdata|
      case qdata[:good]
      when Array
        qdata[:good].each_with_index do |val, ival|
          data_form.merge!(
            "--- #{qid}:#{ival} ---" => {value: val, type: qdata[:type], in: "div#question-#{qid}"}
          )
        end
      else
        data_form.merge!(
          "--- #{qid} ---" => {value: qdata[:good], type: qdata[:type], in: "div#question-#{qid}"}
        )
      end
    end
    benoit.remplit_le_formulaire('form_quiz-1').
      avec(data_form).
      et_le_soumet('Soumettre le quiz')

    la_page_a_pour_titre QUIZ_MAIN_TITRE
    shot 'apres-bonne-soumission'

    # La note est 20/20
    expect(page).to have_tag('span', text: '20/20')
  end

  scenario 'Quand l’user ne soumet pas toutes les questions justes' do
    visite_route 'quiz/1/show?qdbr=biblio'
    la_page_a_pour_titre QUIZ_MAIN_TITRE

    # Mauvaise réponses, toutes les autres seront considérées
    # comme vrai, ce qui permet d'ajouter d'autres questions
    # sans souci ici.
    bads_ids = [11]
    points_max, points_user = remplir_quiz(bads: bads_ids)

    # Vérification de la note finale
    note = ((points_user.to_f / points_max) * 20).round(1)
    expect(note.to_i).not_to eq 20
    puts "points_max : #{points_max}"
    puts "points_user : #{points_user}"
    puts "note : #{note}"
    expect(page).to have_tag('span', with: {id: 'note_finale'}, text: "#{note}/20")

    # Les bonnes réponses doivent être mises en exergue
    within('form#form_quiz-1') do
      data_questions.each do |qid, qdata|
        qoid = "question-#{qid}"
        if qdata[:type] == :radio
          bindex = qdata[:index_good]
          liid = "q-#{qid}-r-#{bindex}"
          # Si c'est la réponse choisi par l'utilisateur, c'est la classe
          # 'good', sinon, c'est la classe 'goodbad'
          css = bads_ids.include?(qid) ? 'goodbad' : 'good'
          expect(page).to have_tag('li', with:{id: liid, class: css})
        else
          # Pour des checkboxes
          # C'est un peu plus compliqué car il peut y avoir
          bons_index = qdata[:index_good]
          bons_index.instance_of?(Array) || bons_index = [bons_index]

          if bads_ids.include?(qid)
            # Quand c'est une mauvaise liste de checkbox choisis
            # par l'user

            # Liste des réponses de l'user (il peut y en avoir des bonnes
            # et des mauvaises)
            userchoix = qdata[:index_bad]
            goodreps  = qdata[:index_good]

            goodreps.each do |bindex|
              isgoodchoix = userchoix.include?(bindex)
              css = isgoodchoix ? 'good' : 'goodbad'
              liid = "q-#{qid}-r-#{bindex}"
              expect(page).to have_tag('li', with:{id: liid, class: css})
            end
          else
            # Quand c'est une liste de checkbox qui ont bien été
            # choisis par l'user
            bons_index.each do |bindex|
              liid = "q-#{qid}-r-#{bindex}"
              expect(page).to have_tag('li', with:{id: liid, class: 'good'})
            end
          end
        end
      end
    end
  end

  scenario 'Un user non inscrit n’enregistre pas ses résultats' do
    count_init = table_resultats_biblio.count
    visite_route "quiz/1/show?qdbr=biblio"
    points_max, points_user = remplir_quiz
    expect(page).to have_tag('span', with: {id: 'note_finale'}, text: '20/20')
    expect(table_resultats_biblio.count).to eq count_init
  end

  scenario 'Un user inscrit enregistre ses résultats' do
    start_time = Time.now.to_i - 1

    # Un user inscrit mais non abonné
    benoit.set_simple_inscrit

    # Au cas où, on détruit tous les questionnaires de cet
    # utilisateur
    table_resultats_biblio.delete(where: "user_id = #{benoit.id}")

    # On prend le nombre actuel de questionnaires
    count_init = table_resultats_biblio.count

    # On identifie l'user
    identify_benoit

    # Il rejoint son profil et ne trouve pas de questionnaires
    visite_route "user/#{benoit.id}/profil"
    expect(page).to have_tag('fieldset#fs_quizes') do
      shot 'user-in-profil-before-quiz'
      with_tag('p', text: /#{Regexp.escape 'Vous n’avez aucun questionnaire enregistré.'}/)
    end

    # Il rejoint le questionnaire
    visite_route "quiz/1/show?qdbr=biblio"
    la_page_a_pour_titre QUIZ_MAIN_TITRE

    # === Benoit remplit le questionnaire ===
    points_max, points_user = remplir_quiz
    expect(page).to have_tag('span', with: {id: 'note_finale'}, text: '20/20')

    shot 'after-submit-quiz'

    # --- Test ---
    # Son résultat a été enregistré
    expect(table_resultats_biblio.count).to eq count_init + 1
    # Le résultat a été enregistré avec les bonnes valeurs
    hres = table_resultats_biblio.select(order: 'created_at DESC', limit: 1).first
    expect( hres[:created_at] ) .to be > start_time
    expect( hres[:user_id] )    .to eq benoit.id
    expect( hres[:quiz_id] )    .to eq 1
    expect( hres[:note] )       .to eq 20.0

    # Son questionnaire apparait dans la liste des questionnaires de son
    # profil
    visite_route "user/#{benoit.id}/profil"
    expect(page).to have_tag('h1', text: 'Votre profil')
    shot 'user-profil-after-quiz'
    expect(page).to have_tag('fieldset', with: {id: 'fs_quizes'}) do
      with_tag 'li', with: {class: 'quiz'}
      with_tag 'a', with: {href: "quiz/#{hres[:quiz_id]}/reshow?qdbr=biblio"}, text: /#{Regexp.escape @dquiz_un[:titre]}/
    end

    # Quand il veut revoir son questionnaire, un message lui dit qu'il ne
    # peut pas le faire, avec un lien pour s'abonner.
    click_link( @dquiz_un[:titre] )
    la_page_a_pour_titre 'Quizzzz !'
    shot 'user-in-reshow-quiz'
    la_page_affiche 'En qualité de simple utilisateur inscrit, vous ne pouvez pas consulter vos quiz précédents.'
  end

  scenario 'Un user abonné enregistre ses résultats et peut revoir son résultat' do
    start_time = Time.now.to_i - 1

    # Un user inscrit mais non abonné
    benoit.set_subscribed

    # Au cas où, on détruit tous les questionnaires de benoit
    table_resultats_biblio.delete(where: "user_id = #{benoit.id}")

    # On prend le nombre actuel de questionnaires
    count_init = table_resultats_biblio.count

    # Benoit s'identifie
    identify_benoit

    # Il rejoint son profil et ne trouve pas de questionnaires
    puts "Benoit visite son profil"
    visite_route "user/#{benoit.id}/profil"
    la_page_a_la_balise 'p', text: 'Vous n’avez aucun questionnaire enregistré.', in: 'fieldset#fs_quizes',
      success: 'Sur son profil, Benoit n’a aucun questionnaire enregistré.'

    # Il rejoint le questionnaire
    puts "Benoit rejoint questionnaire #1 de biblio."
    visite_route "quiz/1/show?qdbr=biblio"
    la_page_a_pour_titre 'Quizzzz !'
    la_page_napas_derreur
    shot 'benoit-after-submit-quiz'

    # === On remplit le questionnaire ===
    points_max, points_user = remplir_quiz
    la_page_a_la_balise 'span', id: 'note_finale', text: '20/20',
      success: "La page affiche la note de 20/20 pour Benoit."


    # --- Test ---
    # Son résultat a été enregistré
    expect(table_resultats_biblio.count).to eq count_init + 1
    # Le résultat a été enregistré avec les bonnes valeurs
    hres = table_resultats_biblio.select(order: 'created_at DESC', limit: 1).first
    expect( hres[:created_at] ) .to be > start_time
    expect( hres[:user_id] )    .to eq benoit.id
    expect( hres[:quiz_id] )    .to eq 1
    expect( hres[:note] )       .to eq 20.0

    # Son questionnaire apparait dans la liste des questionnaires de son
    # profil
    puts "Benoit retourne sur son profil"
    visite_route "user/#{benoit.id}/profil"
    la_page_a_pour_titre 'Votre profil'
    la_page_napas_derreur
    shot 'subscriber-profil-after-quiz'
    expect(page).to have_tag('fieldset', with: {id: 'fs_quizes'}) do
      with_tag 'li', with: {class: 'quiz'}
      with_tag 'a', with: {href: "quiz/#{hres[:quiz_id]}/reshow?qdbr=biblio"}, text: /#{Regexp.escape @dquiz_un[:titre]}/
    end

    # Quand il veut revoir son questionnaire, un message lui dit qu'il ne
    # peut pas le faire, avec un lien pour s'abonner.
    puts "Benoit clique le lien pour voir son questionnaire."
    within('fieldset#fs_quizes'){click_link( @dquiz_un[:titre] )}
    la_page_a_pour_titre QUIZ_MAIN_TITRE
    la_page_napas_derreur
    shot 'user-in-reshow-quiz'
    la_page_napas_le_message 'En qualité de simple utilisatrice inscrite, vous ne pouvez pas consulter vos quiz précédents'

    la_page_a_le_formulaire 'form_quiz-1'
  end
end
