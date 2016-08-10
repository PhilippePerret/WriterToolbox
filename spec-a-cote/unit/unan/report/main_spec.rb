=begin

  Méthode principale pour tester le programme UN AN UN SCRIPT

  Ce module-ci permet surtout de faire des essais divers sans
  les classer encore.

=end
describe 'Données actuelles' do
  it 'on peut atteindre la données des programmes' do
    data = site.dbm_table(:unan, 'programs').select
    expect(data).to be_instance_of Array
    prog = data.first
    expect(prog).to be_instance_of Hash
    [:id, :auteur_id, :current_pday, :current_pday_start
    ].each do |k|
      expect(prog).to have_key k
    end
  end
end
