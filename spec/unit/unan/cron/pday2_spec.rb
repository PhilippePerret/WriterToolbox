=begin

  Test du travail du CRON job pour un auteur qui passe au
  second jour

=end
describe 'Cron job, passage au deuxième jour du programme' do
  before(:all) do
    benoit.set_auteur_unanunscript(pday: 1)
  end
end
