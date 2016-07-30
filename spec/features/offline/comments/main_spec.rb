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
    visite_route 'article/1/show'
    expect(page).to have_tag('h1', text: /Le Blog de la Boite/)
    expect(page).to have_tag('section#page_comments')
    expect(page).to have_tag('h4', text: /Vos commentaires sur cette page/)
  end
  scenario 'un visiteur non inscrit ne peut pas déposer de commentaire' do
    visite_route 'site/test'
    expect(page).to have_tag('section#page_comments')
    expect(page).not_to have_tag('form#form_page_comments')
  end

  scenario 'un visiteur inscrit et identifié peut déposer un commentaire' do

    start_time = Time.now.to_i - 1
    table_page_comments.delete(where: {user_id: 2})
    count_init = table_page_comments.count

    identify_benoit
    visite_route 'site/test'
    expect(page).to have_tag('section#page_comments')
    expect(page).to have_tag('form#form_page_comments') do
      with_tag( 'textarea', with: {name: 'pcomments[comment]', id: 'pcomments_comment'})
      with_tag( 'input', with: {type: 'submit', value: 'Publier'})
    end
    dcomment = {
      comment: "Le commentaire du #{Time.now}"
    }
    within('form#form_page_comments') do
      fill_in('pcomments[comment]', with: dcomment[:comment])
      click_button 'Publier'
    end
    puts "Benoit a entré un nouveau commentaire"

    # --- On vérifie ---

    # Un message confirme à Benoit que son commentaire a été
    # pris en compte
    expect(page).to have_notice("Merci #{benoit.pseudo} pour votre commentaire. Il sera validé très prochainement.")
    puts "Un message lui annonce que son message sera publié"

    expect(page).not_to have_css('form#form_page_comments')
    puts "Le formulaire n'apparait plus dans la page."

    # Le commentaire a dû être enregistré
    expect(table_page_comments.count).to be count_init + 1
    dcom = table_page_comments.select(where: "created_at > #{start_time}").first
    expect(dcom).not_to eq nil
    expect(dcom[:user_id]).to eq benoit.id
    expect(dcom[:comment]).to eq dcomment[:comment]
    # Il doit avoir 0 en premier bit d'options (non validé)
    expect(dcom[:options][0]).to eq '0'
    puts "Le message a bien été enregistré, avec les bonnes valeurs."

    # Un ticket permet à l'administrateur de valider le commentaire
    # par mail
    dticket = site.dbm_table(:hot, 'tickets').select(where: "created_at > #{start_time}").first
    expect(dticket).not_to eq nil
    puts "Il y a un ticket fourni"
    codeticket = dticket[:code]
    expect(codeticket).to include "Page::Comments.valider_comment(#{dcom[:id]})"
    puts "Le ticket contient le bon code"

    # L'administrateur a été averti par mail
    expect(phil).to have_mail(
      sent_after:   start_time,
      subject:      'Dépôt d’un nouveau commentaire',
      message:      [
        benoit.pseudo, "Commentaire ##{dcom[:id]}", "à valider",
        "?tckid=#{dticket[:id]}"
      ]
    )
    puts "Un message d'avertissement a été envoyé à l'administrateur"


  end


end
