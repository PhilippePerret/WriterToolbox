site.require_objet 'unan'
describe 'Gestion des variables' do
  # Rappel : les variables sont enregistrées dans une table
  # de nom `variables` dans la table personnelle d'un user
  # inscrit au programme Un AN UN SCRIPT

  before(:all) do
    @user = User::get(2)
    # L'user doit être inscrit au programme un an un script
    expect(@user).to be_unanunscript
  end

  after(:all) do
    # On détruit de la table toutes les variables qui commencent
    # par "test__" (deux traits plats)
    nb_init = @user.table_variables.count( where: "name LIKE 'test__%'" )
    @user.table_variables.delete( where: "name LIKE 'test__%'" )
    nb_after = @user.table_variables.count( where: "name LIKE 'test__%'" )
    expect(nb_after).to eq 0
  end

  def get_variable_in_table var_name
    @user.table_variables.get(where: "name = '#{var_name}'")
  end

  let(:user) { @user }

  describe '#set_var' do
    it 'répond' do
      expect(user).to respond_to :set_var
    end
    it 'permet de définir une variable, en deux arguments' do
      val = "Une valeur #{Time.now}"
      user.set_var("test__variable", val)
      checked = get_variable_in_table "test__variable"
      expect(checked).not_to eq nil
      expect(checked[:name]).to eq "test__variable"
      expect(checked[:type]).to eq 0
      expect(checked[:value]).to eq val
    end
    it 'permet de définir une variable avec un argument Hash' do
      val = Time.now.to_i
      user.set_var("test__avec_argument_hash", val)
      checked = get_variable_in_table "test__avec_argument_hash"
      expect(checked).not_to eq nil
      expect(checked[:name]).to eq "test__avec_argument_hash"
      expect(checked[:type]).to eq 1
      expect(checked[:value]).to eq val.to_s
    end
  end

  describe '#get_var' do
    it 'répond' do
      expect(user).to respond_to :get_var
    end
    it 'permet de récupérer une valeur enregistrée' do
      user.set_var("test__pour_get_var", {un: "hash"})
      checked = user.get_var("test__pour_get_var")
      expect(checked).not_to eq nil
      expect(checked).to be_instance_of Hash
      expect(checked[:un]).to eq "hash"
    end
  end

  describe '#set_vars' do
    it 'répond' do
      expect(user).to respond_to :set_vars
    end
    it 'permet de définir plusieurs variables d’un coup' do
      data = {
        "test__multi_un_fixnum"    => {value: 12, type: 1, value_saved: "12"},
        "test__multi_deux_string"  => {value: "un string à #{Time.now}", type: 0},
        "test__multi_trois_bool"   => {value: false, type: 7, value_saved:"0"}
      }
      data2save = Hash::new
      data.each{|vn, vd| data2save.merge!(vn => vd[:value])}
      user.set_vars data2save
      data.each do |var_name, var_data|
        checked = get_variable_in_table(var_name)
        expect(checked).not_to eq nil
        expect(checked[:value]).to eq (var_data[:value_saved] || var_data[:value])
        expect(checked[:type]).to eq var_data[:type]
      end
    end
  end

  describe '#get_vars' do
    before(:all) do
      # On enregistre des variables pour pouvoir les lire
      @data = {
        "test__getvars_string" => {value: "#{Time.now} pour voir", type:0},
        "test__getvars_fixnum" => {value: 11, type: 1, saved_value: "11"},
        "test__getvars_bool"   => {value: true, type:7, saved_value: "1"},
        "test__getvars_hash"   => {value:{un:"Hash"}, type:4}
      }
      @data.each do |var_name, var_data|
        @user.set_var(var_name, var_data[:value])
      end
    end
    it 'répond' do
      expect(user).to respond_to :get_vars
    end
    context 'sans 2e argument (donc as_real_value à false)' do
      it 'retourne les valeurs telles que dans la table' do
        res = user.get_vars(@data.keys)
        @data.each do |var_name, var_data|
          expect(res).to have_key var_name
          res_var = res[var_name]
          expect(res_var).to be_instance_of Hash
          expect(res_var[:value]).to eq (var_data[:saved_value] || var_data[:value])
          expect(res_var[:type]).to eq var_data[:type]
        end
      end
    end
    context 'avec as_real_value à false (2e argument)' do
      it 'retourne les valeurs brutes enregistrées (un hash)' do
        res = user.get_vars(@data.keys, as_real_value = false)
        @data.each do |var_name, var_data|
          expect(res).to have_key var_name
          res_var = res[var_name]
          expect(res_var).to be_instance_of Hash
          expect(res_var[:value]).to eq (var_data[:saved_value] || var_data[:value])
          expect(res_var[:type]).to eq var_data[:type]
        end
      end
    end
    context 'avec as_real_value à true (2e argument)' do
      it 'retourne les valeurs réelles' do
        res = user.get_vars(@data.keys, as_real_value = true)
        @data.each do |var_name, var_data|
          expect(res).to have_key var_name
          res_var = res[var_name]
          expect(res_var).to eq var_data[:value]
        end
      end
    end
  end

  describe 'les types enregistrables' do
    describe 'un string' do
      it 'est enregistré correctement' do
        string = "Mon string le #{Time.now}"
        user.set_var("test__type_string", string)
        expect(user.get_var("test__type_string")).to eq string
      end
    end

    describe 'un fixnum' do
      it 'est enregistré correctement' do
        fixnum = Time.now.to_i
        user.set_var("test__type_fixnum", fixnum)
        expect(user.get_var("test__type_fixnum")).to eq fixnum
      end
    end

    describe 'un array' do
      it 'est enregistré correctement' do
        now = Time.now.to_i
        array = [now, 12, "pour voir"]
        user.set_var("test__type_array" => array)
        res = user.get_var("test__type_array")
        expect(res).to be_instance_of Array
        array.each do |el|
          expect(res).to include el
        end
      end
    end

    describe 'un booléen' do
      it 'enregistre true et false' do
        user.set_var("test__type_true", true)
        user.set_var("test__type_false" => false)
        expect(user.get_var("test__type_true")).to eq true
        hintable = get_variable_in_table("test__type_false")
        expect(user.var_value_to_real(hintable)).to eq false
        expect(user.get_var("test__type_false")).to eq false
      end
    end

    describe 'un hash' do
      it 's’enregistre comme hash' do
        user.set_var("test__type_hash" => {un: "Hash", deux: [1,2,3]})
        res = user.get_var("test__type_hash")
        expect(res).to be_instance_of Hash
        expect(res).to have_key :un
        expect(res).to have_key :deux
        expect(res[:un]).to eq "Hash"
        expect(res[:deux]).to eq [1,2,3]
      end
    end

    describe 'valeur nil' do
      it 's’enregistre correctement' do
        user.set_var("test__type_nil" => nil)
        expect(user.get_var("test__type_nil")).to eq nil
      end
    end
  end

end
