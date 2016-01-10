site.require_objet 'unan'

describe 'Méthodes de lecture d’une page de cours' do
  before(:all) do
    @pagecours = page_cours(1)

    @file_erb  =  @pagecours.fullpath.dirname + "test.erb"
    @file_html =  @pagecours.fullpath.dirname + "test.html"
    @file_txt  =  @pagecours.fullpath.dirname + "test.txt"
    @file_tex  =  @pagecours.fullpath.dirname + "test.tex"

    @file_erb.write  "<%= 'Code de la page ERB' %>"
    @file_html.write "Code de la vue en HTML"
    @file_txt.write  "Une vue simple texte"
    @file_tex.write  "\\par{Mon paragraphe}"
  end
  after(:all) do
    # On peut détruire les fichiers créés sauf l'original (erb)
    @file_html.remove   if @file_html.exist?
    @file_txt.remove    if @file_txt.exist?
    @file_tex.remove    if @file_tex.exist?
  end
  let(:pagecours) { @pagecours }

  describe '#read' do
    before(:each) do
      @pagecours.instance_variable_set('@fullpath', nil)
      @pagecours.instance_variable_set('@extension', nil)
    end
    def set_path_pagecours_to path
      @pagecours.instance_variable_set('@path', path)
      @pagecours.instance_variable_set('@fullpath', nil)
    end
    it 'répond' do
      expect(pagecours).to respond_to :read
    end
    context 'avec un vue ERB' do
      it 'retourne le code de la page ERB si erb' do
        set_path_pagecours_to 'test.erb'
        expect(pagecours.read).to eq "Code de la page ERB"
      end
    end
    context 'avec une vue simple texte' do
      it 'retourne le code de la page simple-text' do
        set_path_pagecours_to 'test.txt'
        expect(pagecours.read).to eq "<p>Une vue simple texte</p>\n"
      end
    end
    context 'avec une vue html' do
      it 'retourne le code de la vue HTML' do
        set_path_pagecours_to 'test.html'
        expect(pagecours.read).to eq "Code de la vue en HTML"
      end
    end
    context 'avec une vue latex' do
      it 'retourne le code de la vue en Latex' do
        set_path_pagecours_to 'test.tex'
        # Pas traité pour le moment
      end
    end

  end
end
