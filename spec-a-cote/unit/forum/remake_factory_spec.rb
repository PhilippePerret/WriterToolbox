describe 'Juste pour refabriquer les données de test' do

  # Lancer ce test pour détruire `./database/data/forum.db` et
  # ensuite actualiser toutes les données de messages

  def database_forum
    @database_forum ||= SuperFile::new("./database/data/forum.db")
  end

  before(:all) do

    # # DÉCOMMENTER CES DEUX LIGNES POUR ACTUALISER LES DONNÉES FORUM
    # database_forum.remove if database_forum.exist?
    # ForumSpec::make_gel_forum_with_messages(100, 30)


  end

  it 'a créé la base pour le forum du site' do
    expect(database_forum).to be_exist
  end

end
