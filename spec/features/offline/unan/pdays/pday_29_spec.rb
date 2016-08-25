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

    require './CRON2/lib/procedure/un_an_un_script/duser_extension.rb'
    duser = DUser.new(benoit.id)
    duser.marque_fini_les_works_avec_reusable_quiz
    puts "Lancement de la méthode du cron job qui s'occupe de ça"

    hw = benoit.table_works.select(where: {abs_work_id: 24}).first
    expect(hw[:status]).to eq 9
    success 'Le travail du quiz du 27e jour a été marqué achevé'


  end
end
