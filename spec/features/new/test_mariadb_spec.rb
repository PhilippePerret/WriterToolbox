=begin

  Ce test est censé tester qu'on utilise bien d'autres bases de données
  pour exécuter les tests.

=end
describe "Pour un test" do

  # Dans tous les cas, on remettra toutes les données après
  # ces tests.
  after(:all) do
    reset_db_after_test
  end


  context 'En initialisant complètement les bases' do
    before(:all) do
      init_db_for_test
    end
    after(:all) do
      reset_db_after_test
    end
    it 'détruit tous les utilisateurs sauf Phil' do
      expect(User.table.select(2)[0]).to eq nil
      u = User.table.select(1)[0]
      expect(u).not_to eq nil
      expect(u[:pseudo]).to eq 'Phil'
    end
    it 'détruit la table cnarration.narration qui contient la définition des pages narration' do
      res = site.dbm_base_execute('cnarration', 'SHOW TABLES;')
      expect(res).to be_empty
    end
  end

  context 'En n’initialisant pas la base cnarration' do
    before(:all) do
      init_db_for_test(except: ['cnarration'])
    end
    after(:all) do
      reset_db_after_test
    end

    it 'conserve la table cnarration.narration qui contient la définition des pages narration' do
      res = site.dbm_base_execute('cnarration', 'SHOW TABLES;')
      # puts "res = #{res.inspect}"
      expect(res).to include( {:"Tables_in_boite-a-outils_cnarration"=>"narration"})
    end
  end

end
