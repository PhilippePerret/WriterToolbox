describe 'Options de l’user' do
  before(:all) do
    @user = create_user
  end
  let(:user) { @user }

  describe 'Méthode #options' do
    it { expect(user).to respond_to :options }
  end
  describe '#admin?' do
    it { expect(user).to respond_to :admin? }
  end
  describe '#super?' do
    it { expect(user).to respond_to :super? }
  end
  describe '#manitou?' do
    it { expect(user).to respond_to :manitou? }
  end

  def set_bit_admin_user value
    opts = @user.options
    opts[0] = value.to_s
    @user.instance_variable_set('@options', opts)
  end

  describe "Par grade" do
    context 'avec un simple user' do
      before(:all) do
        set_bit_admin_user(0)
      end
      it 'n’est pas admin' do
        expect(user).not_to be_admin
      end
      it 'n’est pas super' do
        expect(user).not_to be_super
      end
      it 'n’est pas grand manitou' do
        expect(user).not_to be_manitou
      end
    end
    context 'avec un simple administrateur' do
      before(:all) do
        set_bit_admin_user(1)
      end
      it 'est admin' do
        expect(user).to be_admin
      end
      it 'n’est pas super' do
        expect(user).not_to be_super
      end
      it 'n’est pas grand manitou' do
        expect(user).not_to be_manitou
      end
    end
    context 'avec un simple super' do
      before(:all) do
        set_bit_admin_user(3)
      end
      it 'est admin' do
        expect(user).to be_admin
      end
      it 'est super' do
        expect(user).to be_super
      end
      it 'n’est pas grand manitou' do
        expect(user).not_to be_manitou
      end
    end
    context 'avec un grand manitou' do
      before(:all) do
        set_bit_admin_user(7)
      end
      it 'est admin' do
        expect(user).to be_admin
      end
      it 'est super' do
        expect(user).to be_super
      end
      it 'est grand manitou' do
        expect(user).to be_manitou
      end
    end
  end
end
