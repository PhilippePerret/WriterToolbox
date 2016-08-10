=begin
  Module de test des listes de quiz
=end
feature "Liste des quiz" do
  before(:all) do
    site.require_objet 'quiz'
  end
  scenario 'Un visiteur quelconque peut rejoindre la liste des quiz depuis l’accueil' do
    visit_home
    expect(page).to have_link 'OUTILS'
    click_link 'OUTILS'
    expect(page).to have_tag('h1', text: /Outils d'écriture/)
    puts "Il rejoint la liste des outils"
    within('div#tools_quick_list') do
      expect(page).to have_link 'Les quizzzz'
    end
    puts "On trouve le lien bouton dans l'accès rapide aux outils"
    within('dl') do
      expect(page).to have_link 'Les quizzzz'
    end
    puts "Il trouve un lien bouton dans la liste détaillée des outils"
    puts "Il clique le lien Quizzzz"
    within('div#tools_quick_list') do
      click_link 'Les quizzzz'
    end

    expect(page).to have_tag('h1', text: /Quizzzz/)
    puts "Il rejoint l'accueil des quiz (le quiz courant)"
    expect(page).to have_link('Tous les quizzzz')
    puts "Il trouve un lien pour rejoindre la liste des quiz"
    click_link 'Tous les quizzzz'
    expect(page).to have_tag('h2', text: /Tous les quizzzz/)
    expect(page).to have_tag('ul', with: {id: 'quizes'})

  end
  scenario 'Un visiteur quelconque trouve une liste conforme à son niveau' do
    visite_route "quiz/list"
    expect(page).to have_css('ul#quizes')
    expect(page).to have_tag('ul#quizes') do
      allquiz = site.dbm_table(:cold, 'quiz').select()
      expect(allquiz).not_to be_empty

      Quiz.allquiz.each do |hq|
        Quiz.suffix_base= hq.suffix_base
        with_tag 'li', with:{id: "quiz-#{hq.suffix_base}-#{hq.id}", class: 'li_quiz'} do
          with_tag 'span', with: {class: 'qtitre'}, text: /#{Regexp.escape hq.titre}/
          with_tag 'span', with: {class: 'cdate'}, text: hq.created_at.as_human_date(true, false, '')
          # Le div pour la description
          unless hq.description.nil?
            desc = hq.description[0..20]
            with_tag 'div', with: {class: 'qdescription'}, text: /#{Regexp.escape desc}/
          end
          # Le lien pour le tenter
          with_tag 'a', with: {href: "quiz/#{hq.id}/show?qdbr=#{hq.suffix_base}"}, text: /Le tenter/
          if hq.data_generales
            # Dernière date de jeu
            hqg = hq.data_generales
            with_tag 'span', with: {class: 'pdate'}, text: hqg[:updated_at].as_human_date(true, false, '')
            with_tag 'span', with: {class: 'count'}, text: hqg[:count].to_s
            with_tag 'span', with: {class: 'nmax'}, text: hqg[:note_max].to_f.to_s
            with_tag 'span', with: {class: 'nmoy'}, text: hqg[:moyenne].to_f.to_s
            with_tag 'span', with: {class: 'nmin'}, text: hqg[:note_min].to_f.to_s
          end
        end
      end # Fin de boucle sur tous les quiz (avec résultat)
    end
  end
  scenario 'Un visiteur quelconque ne peut pas rejoindre un autre quiz que le dernier' do
    visite_route 'quiz/list'
    currentq = Quiz.current
    # On prend le premier quiz qui n'est pas un quiz courant
    autreq = nil
    Quiz.allquiz.each do |hq|
      if hq.id != currentq.id
        autreq = hq
        break
      end
    end
    # On ne peut faire ce test que s'il y a plusieurs quiz
    unless autreq.nil?
      expect(page).to have_css("li#quiz-#{autreq.suffix_base}-#{autreq.id} span.qlink")
      within("li#quiz-#{autreq.suffix_base}-#{autreq.id} span.qlink") do
        expect(page).to have_link "Le tenter"
        click_link "Le tenter"
      end
      expect(page).to have_content("ce quiz n'est pas le quiz du jour")
      expect(page).to have_content("vous n'êtes pas abonné")
      expect(page).to have_content('seuls les abonnés ont accès à tous les quiz')
    end
  end

  scenario 'Un abonné peut rejoindre un autre quiz que le dernier' do
    upwd = "monpasseword"
    u = create_user(password: upwd, subscriber: true)
    $users_2_destroy << u.id
    identify mail: u.mail, password: upwd
    visite_route 'quiz/list'
    currentq = Quiz.current
    # On prend le premier quiz qui n'est pas un quiz courant
    autreq = nil
    Quiz.allquiz.each do |hq|
      if hq.id != currentq.id
        autreq = hq
        break
      end
    end
    # On ne peut faire ce test que s'il y a plusieurs quiz
    unless autreq.nil?
      within("li#quiz-#{autreq.suffix_base}-#{autreq.id} span.qlink") do
        click_link "Le tenter"
      end
      expect(page).to have_tag('form#form_quiz')
      expect(page).not_to have_content("ce quiz n'est pas le quiz du jour")
      expect(page).not_to have_content("vous n'êtes pas abonné")
      expect(page).not_to have_content('seuls les abonnés ont accès à tous les quiz')
    end
  end

  scenario "Un administrateur peut éditer le questionnaire" do
    currentq = Quiz.current
    # On prend le premier quiz qui n'est pas un quiz courant
    autreq = nil
    Quiz.allquiz.each do |hq|
      if hq.id != currentq.id
        autreq = hq
        break
      end
    end
    unless autreq.nil?

      identify_phil
      visite_route 'quiz/list'
      expect(page).to have_tag("li#quiz-#{autreq.suffix_base}-#{autreq.id} span.qlink") do
        with_tag 'a', with: {href: "quiz/#{autreq.id}/edit?qdbr=#{autreq.suffix_base}"}, text: 'Éditer'
      end
      within("li#quiz-#{autreq.suffix_base}-#{autreq.id} span.qlink") do
        click_link "Éditer"
      end
      expect(page).to have_tag('form#edition_quiz')

    end
  end
end
