=begin

  Module de test principal de commentaires

=end
feature "Commentaires sur une page (Comments)" do

  before(:each) do
    # On détruit tous les commentaires de benoit à chaque
    # test pour ne pas avoir de problème
    # NON : ÇA POSE PLEIN DE PROBLÈME AILLEURS, DONC l'employer
    # au cas par cas.
    # table_page_comments.delete(where: {user_id: 2})
  end

  def table_page_comments
    @table_page_comments ||= site.dbm_table(:cold, 'page_comments')
  end

  scenario "Un visiteur quelconque trouve la section des commentaires" do
    test 'Un visiteur quelconque trouve la section des commentaires dans une page quelconque'
    visite_route 'article/1/show'
    la_page_a_pour_titre 'Le Blog de la Boite'
    la_page_a_la_section 'page_comments',
      success: "La section des commentaires de page existe."
    la_page_a_la_balise 'h4', text: 'Vos commentaires sur cette page',
      success: "La section des commentaires a le bon titre"
  end
  scenario 'un visiteur non inscrit ne peut pas déposer de commentaire' do
    test 'Un simple visiteur ne peut pas déposer de commentaire de page'
    visite_route 'site/test'
    la_page_a_la_section 'page_comments',
      success: "La page contient la section des commentaires de page"
    la_page_napas_le_formulaire 'form_page_comments',
      success: "Le visiteur ne trouve pas le formulaire de commentaire."
  end

  scenario 'un visiteur inscrit et identifié peut déposer un commentaire' do

    test 'Un visiteur inscrit peut déposer un commentaire'
    start_time = Time.now.to_i - 1
    table_page_comments.delete(where: {user_id: 2})
    count_init = table_page_comments.count

    identify_benoit
    visite_route 'site/test'
    la_page_a_la_section 'page_comments',
      success: "Le visiteur identifié trouve la section des commentaires de page."
    la_page_a_le_formulaire 'form_page_comments'
    la_page_a_la_balise 'textarea', in: 'form#form_page_comments', name: 'pcomments[comment]', id: 'pcomments_comment'
    la_page_a_la_balise 'input', in: 'form#form_page_comments', type: 'submit', value: 'Publier'
    dcomment = {
      'pcomments[comment]' => {value: "Le commentaire du #{Time.now}"}
    }
    benoit.remplit_le_formulaire(page.find('form#form_page_comments')).
      avec(dcomment).
      et_le_soumet('Publier')
    puts "Benoit a entré un nouveau commentaire"

    # --- On vérifie ---

    # Un message confirme à Benoit que son commentaire a été
    # pris en compte
    la_page_a_le_message "Merci #{benoit.pseudo} pour votre commentaire. Il sera validé très prochainement."
    la_page_napas_le_formulaire 'form_page_comments',
      success: "Le formulaire pour entrer un commentaire n'est plus affiché."

    # Le commentaire a dû être enregistré
    expect(table_page_comments.count).to be count_init + 1
    dcom = table_page_comments.select(where: "created_at > #{start_time}").first
    expect(dcom).not_to eq nil
    expect(dcom[:user_id]).to eq benoit.id
    expect(dcom[:comment]).to eq dcomment['pcomments[comment]'][:value]
    # Il doit avoir 0 en premier bit d'options (non validé)
    expect(dcom[:options][0]).to eq '0'
    success "Le message a bien été enregistré, avec les bonnes valeurs."

    # Un ticket permet à l'administrateur de valider le commentaire
    # par mail
    dticket = site.dbm_table(:hot, 'tickets').select(where: "created_at > #{start_time}").first
    expect(dticket).not_to eq nil
    success "Un ticket a été fourni pour valider le commentaire directement."
    codeticket = dticket[:code]
    expect(codeticket).to include "Page::Comments.valider_comment(#{dcom[:id]})"
    success "Le ticket contient le bon code à exécuter."

    # L'administrateur a été averti par mail
    data_mail = {
      success: "Un mail d'avertissement a été envoyé à l'administrateur",
      sent_after:   start_time,
      subject:      'Dépôt d’un nouveau commentaire',
      message:      [
        benoit.pseudo, "Commentaire ##{dcom[:id]}", "à valider",
        "?tckid=#{dticket[:id]}"
      ]
    }
    phil.a_recu_le_mail data_mail

  end


end
