=begin

  Module de test du formatage des messages

=end
describe 'Formatage des messages de commentaires de pages' do
  before(:all) do

  end

  def new_comment data
    Page::Comments.new(data)
  end

  let(:comf) { @com.comment_formated }

  describe 'Les tags traditionnelle (u, i, etc.) sont transformés' do
    before(:all) do
      @com = new_comment({comment: "Un [u]soulignement[/u], un [i]italique[/i], un [strike]barré[/strike], un [b]gras[/b]"})
    end
    it 'le souligné a été transformé' do
      expect(comf).to have_tag('u', text: "soulignement")
    end
    it 'l’italique a été tranformé' do
      expect(comf).to have_tag('i', text: "italique")
    end
    it 'le gras a été tranformé' do
      expect(comf).to have_tag('b', text: "gras")
    end
    it 'le strike a été tranformé' do
      expect(comf).to have_tag('strike', text: "barré")
    end
    # ---------------------------------------------------------------------
  end
  describe 'autres traitements, et notamment les retours chariot et les balises malveillantes' do
    before(:all) do
      @com = new_comment({comment: "<script>Scriptmalveillant()\r\n</script> Ce texte est bon<script type='text/javascript'>Autre malveillance</script>\n\n\r\nUn autre texte."})
    end
    it 'toute balise sup/inf est supprimée' do
      expect(comf).to eq '<p>Ce texte est bon</p><p>Un autre texte.</p>'
    end
  end

  describe 'les éléments seuls commes les [hr] et [br]' do
    before(:all) do
      @com = new_comment({comment: "Il faut un [hr] et un [br] et autre [hr]"})
    end
    it 'sont remplacés par leur balise HTML' do
      expect(comf).to eq '<p>Il faut un <hr> et un <br> et autre <hr></p>'
    end
  end

  describe 'les liens internets' do
    before(:all) do
      @com = new_comment({comment: "C'est un [url]www.atelier-icare.net[/url]\n\nUn autre par [url='http://www.scenariopole.fr'][u]La boite[/u][/url]."})
    end
    it 'sont transformés en balises <a>' do
      expect(comf).to eq '<p>C\'est un <a href="http://www.atelier-icare.net">www.atelier-icare.net</a></p><p>Un autre par <a href="http://www.scenariopole.fr"><u>La boite</u></a>.</p>'
    end
  end
end
