=begin
Noter que pour le moment les préférences ne sont valables
que pour le programme UN AN UN SCRIPT mais je pense qu'il serait bon
de tout passer sur RestSite :
  1. la table 'variables' avec son fonctionnement particulier
  2. le module 'preferences.rb' qui contient les méthodes préférences
=end
site.require_objet 'unan'
describe 'Préférences de l’utilisateur' do

  before(:all) do
    @user = create_user( current:true, unanunscript:true)
    # puts "@user.id = #{@user.id.inspect}"
  end

  let(:user) { @user }

  def get_in_table key, as_real_value = true
    hres = user.table_variables.get(where:{name: "#{key}"})
    return nil if hres.nil?
    if as_real_value
      user.var_value_to_real(hres)
    else
      hres
    end
  end

  # User#set_preference
  describe 'User#set_preference' do
    it 'répond' do
      expect(user).to respond_to :set_preference
    end
    it 'permet d’enregistrer une préférence string' do
      user.set_preference :test__pref, "valeur pref"
      expect(get_in_table "pref_test__pref").to eq "valeur pref"
    end
    it 'permet d’enregistrer une préférence booléenne' do
      user.set_preference :test_boolean, true
      expect(get_in_table "pref_test_boolean").to eq true
      user.set_preference :test_valeur_false, false
      expect(get_in_table "pref_test_valeur_false").to eq false
    end
    it 'met la préférence dans @preferences' do
      user.set_preference :test_in_instvar => "dans la variable d'instance ?"
      checked = user.instance_variable_get('@preferences')
      expect(checked).to have_key :test_in_instvar
      expect(checked[:test_in_instvar]).to eq "dans la variable d'instance ?"
    end
  end

  describe 'User#set_preferences' do
    it 'répond' do
      expect(user).to respond_to :set_preferences
    end
    it 'permet de définir plusieurs préférences d’un coup' do
      dataprefs = {
        "test_multi_un"     => true,
        "test_multi_deux"   => false,
        "test_multi_trois"  => "Bonjour"
      }
      user.set_preferences( dataprefs )
      dataprefs.each do |key, expected|
        checked = get_in_table("pref_#{key}", true)
        expect(checked).to eq expected
      end
    end
    it 'met les propriété dans @preferences' do
      dataprefs = {
        "test_multi2_un"      => "Bonjour",
        "test_multi2_deux"    => true,
        :test_multi2_trois    => false
      }
      user.set_preferences( dataprefs )
      checked = user.instance_variable_get('@preferences')
      dataprefs.each do |key, expected|
        expect(checked[key.to_sym]).to eq expected
      end
    end

    it 'update ou insert automatiquement' do
      user.set_preference :pour_update => true
      expect(get_in_table("pref_pour_update")).to eq true
      dataprefs = {
        "multi3_un"   => 12,
        :multi3_deux  => false,
        :pour_update  => false
      }
      user.set_preferences dataprefs
      user.instance_variable_set('@table_variables', nil)
      expect(get_in_table("pref_pour_update")).to eq false
    end
  end

  describe 'User#preference' do
    it 'répond' do
      expect(user).to respond_to :preference
    end
    it 'retourne nil si la préférence n’existe pas et sans valeur par défaut' do
      expect(user.preference(:badescriptiondepref)).to eq nil
    end
    it 'retourne la valeur par défaut si la préférence n’existe pas' do
      expect(user.preference(:badescpref, :inexistant)).to eq :inexistant
    end
    it 'retourne la préférence si elle existe' do
      texte = "Un texte #{Time.now}"
      user.set_preference(:prefget1 => texte)
      user.instance_variable_set('@preferences', Hash.new)
      expect(user.instance_variable_get('@preferences')).not_to have_key "pref_prefget1"
      expect(user.preference :prefget1).to eq texte
      expect(user.instance_variable_get('@preferences')).to have_key :prefget1
    end
  end

  # Pour obtenir toutes les préférences d'un coup
  describe 'User#preferences' do
    it 'répond' do
      expect(user).to respond_to :preferences
    end
    it 'retourne toutes les préférences' do
      # On commence par vider les préférences
      user.table_variables.delete(where:"name LIKE 'pref_%'")
      prefs = user.preferences
      expect(prefs).to be_empty
      dataprefs = {
        "allprefs_un"     => 1,
        :allprefs_deux    => "DEUX",
        :allprefs_trois   => true
      }
      user.set_preferences dataprefs
      all = user.instance_variable_get('@preferences')
      expect(all).to have_key :allprefs_deux
      user.instance_variable_set('@preferences', Hash.new)
      all = user.instance_variable_get('@preferences')
      expect(all).not_to have_key :allprefs_deux
      # On a bien vidé tout
      res = user.preferences
      expect(res).to have_key :allprefs_deux
      expect(res).to have_key :allprefs_un
      expect(res).to have_key :allprefs_trois
      dataprefs.each do |k, v|
        expect(res[k.to_sym]).to eq v
      end
    end
  end
end
