=begin

  Test des traitement des dépôts de fichier, au niveau des tests
  unitaires.

=end
describe 'Parse d’un fichier déposé' do
  before(:all) do
    site.require_objet 'analyse_build'

    # On fait un fichier de collecte de scène
    code_collecte_scene = <<-TEXT
    0:30\tINT. JOUR\tBUREAU\tLe résumé de la scène
    TEXT
  end

  describe 'Parse régulier du code' do
    before(:all) do
      AnalyseBuild.require_module 'parser_reg'
      @chantier = AnalyseBuild.new(220)
    end
    let(:chantier) { @chantier }


    describe 'Une scène avec seulement une ligne' do
      before(:all) do
        code = "0:30\tINT. JOUR\tBUREAU\tLe résumé de la scène"
        @scene = AnalyseBuild::Film::Scene.new(@chantier.film, code)
      end
      let(:scene) { @scene }
      it 'est analysée correctement' do
        expect(scene).to be_instance_of AnalyseBuild::Film::Scene
        expect(scene).to respond_to :numero
        expect(scene.numero).to eq 1
        expect(scene.horloge).to eq '0:30'
        expect(scene.time).to eq 30
        expect(scene.effet).to eq 'JOUR'
        expect(scene.lieu).to eq 'INT.'
        expect(scene.decor).to eq 'BUREAU'
        expect(scene.resume).to eq 'Le résumé de la scène'
      end
      it 'ne contient pas de paragraphes' do
        expect(scene.data_paragraphes).to be_empty
      end
      it 'définit un full résumé correct' do
        expect(scene.full_resume).to eq 'Le résumé de la scène'
      end
    end
    # /Une scène avec seulement une ligne

    describe 'Une scène avec des paragraphes' do
      before(:all) do
        code = "1:56\tEXT. NUIT\tROUTE\tRésumé de la scène presque.\n"+
        "Le premier paragraphe.\tB1\n"+
        "Le deuxième paragraphe.\tB2\n"+
        "Le troisième paragraphe.\n"+
        "B3 B4"
        @scene = AnalyseBuild::Film::Scene.new(@chantier.film, code)
      end
      let(:scene) { @scene }
      it 'définit bien ses data paragraphes' do
        expect(scene.data_paragraphes).not_to be_empty
        expect(scene.data_paragraphes.count).to eq 3
      end
      it 'définit bien son premier paragraphe' do
        dpara = scene.data_paragraphes.first
        expect(dpara[:texte]).to eq 'Le premier paragraphe.'
        expect(dpara[:brins]).to eq [1]
      end
      it 'définit bien son deuxième paragraphe' do
        dpara = scene.data_paragraphes[1]
        expect(dpara[:texte]).to eq 'Le deuxième paragraphe.'
        expect(dpara[:brins]).to eq [2]
      end
      it 'définit bien son troisième paragraphe' do
        dpara = scene.data_paragraphes[2]
        expect(dpara[:texte]).to eq 'Le troisième paragraphe.'
        expect(dpara[:brins]).to be_empty
      end
      it 'définit bien les brins de la scène' do
        expect(scene.brins).not_to be_empty
        expect(scene.brins).to eq [3,4]
      end
    end

  end

end
