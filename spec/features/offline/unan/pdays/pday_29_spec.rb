=begin

  Jour-programme 29
  -----------------
  * Le quiz pour évaluer les projets, au départ, ne doit pas être terminé, mais
    l'arrivée dans le bureau le met automatiquement à terminé

=end
feature "29e jour-programme" do
  before(:all) do
    reset_auteur_unan benoit
    benoit.set_pday_to(29, {
      # On marque achevés les travaux jusqu'au 24e jour-programme
      # Il faut surtout que les travaux du jour 25 ne soient pas
      # marqués terminés
      complete_upto: 24,
      start_upto: 27
      })
  end
  scenario 'Le travail du quiz d’évaluation des projets se met à fini' do

    expect(benoit.program.current_pday).to eq 29
    success 'Benoit se trouve bien au jour-programme 27'

    hw = benoit.table_works.select(where: {abs_work_id: 24}).first
    expect(hw[:status]).not_to eq 9
    success 'Le travail du quiz du 27e jour est bien marqué inachevé'

    identify_benoit
    la_page_a_pour_soustitre UNAN_SOUS_TITRE_BUREAU
    
    hw = benoit.table_works.select(where: {abs_work_id: 24}).first
    expect(hw[:status]).to eq 9
    success 'Le travail du quiz du 27e jour a été marqué achevé'


  end
end
