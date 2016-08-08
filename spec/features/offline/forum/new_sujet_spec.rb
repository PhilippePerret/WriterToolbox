# encoding: UTF-8
=begin

  Test de la création (réussie ou non) d'un nouveau sujet pour le forum
=end
feature "Création d'un nouveau sujet" do
  before(:all) do
    forum_remove_all
  end

  scenario "Un visiteur quelconque ne peut pas créer un nouveau sujet" do
    test 'Un visiteur quelconque ne peut pas créer un nouveau sujet'
    visite_route 'forum/home'
    click_link 'Soumettre'
    la_page_a_pour_soustitre 'Question/sujet'
    la_page_napas_le_formulaire 'form_nouveau_sujet'
    la_page_napas_le_menu 'question_categorie'
    la_page_affiche "vous devez être inscrit pour pouvoir poser une question"
  end
  scenario 'Un visiteur inscrit ne peut pas créer un nouveau sujet' do
    start_time = NOW - 1
    test 'Un visiteur inscrit sans grade peut créer une nouveau sujet non validé'
    opts = benoit.options.set_bit(1, 0)
    benoit.set(options: opts)
    identify_benoit
    visite_route 'forum/home'
    click_link 'Soumettre'
    la_page_a_pour_soustitre 'Question/sujet'
    la_page_a_le_formulaire 'form_nouveau_sujet'
    # === Test ===
    question = "Une question du #{Time.now}"
    dform = {
      'question_question' => { value: question }
    }
    benoit.remplit_le_formulaire(page.find('form#form_nouveau_sujet')).
      avec(dform).
      et_le_soumet('Soumettre')
    # === Vérification ===
    le_forum_a_le_sujet(question)
    le_sujet_forum(question).napas_de_messages
    le_sujet_forum(question).nestpas_valided
    phil.a_recu_un_mail(
      sent_after: start_time,
      subject:    "Nouveau sujet"
    )
  end
  scenario 'Un inscript possédant le grade suffisant (5) peut créer un sujet' do
    test 'Un inscrit possédant le grade suffisant (5) peut créer un nouveau sujet'
    # D'abord, on donne à benoit le grade suffisantes
    start_time = NOW - 1
    opts = benoit.options.set_bit(1, 5)
    benoit.set(options: opts)
    identify_benoit
    visite_route 'forum/home'
    la_page_a_le_lien 'Soumettre'
    click_link 'Soumettre'
    la_page_a_pour_soustitre 'Question/sujet'
    la_page_a_le_formulaire 'form_nouveau_sujet'
    la_page_a_le_menu 'question_categorie', in: 'form#form_nouveau_sujet'
    @nouvelle_question = "Une nouvelle question du #{Time.now}"
    dataform = {
      'question_question' => {value: @nouvelle_question}
    }
    on_remplit_le_formulaire(page.find('form#form_nouveau_sujet')).
      avec(dataform).
      et_le_soumet('Soumettre')

    # === Vérification ===
    le_forum_a_le_sujet(@nouvelle_question)
    le_sujet_forum(@nouvelle_question).napas_de_messages
    le_sujet_forum(@nouvelle_question).est_valided
    phil.a_recu_un_mail(
      sent_after: start_time,
      subject:    "Nouveau sujet"
    )
  end
end
