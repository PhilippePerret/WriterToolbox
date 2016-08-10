=begin

Test de la méthode content_formated qui met en forme le contenu d'un message

=end

describe 'Forum::Post#content_formated' do
  before(:all) do
    site.require_objet 'forum'
    @post = Forum::Post::new
  end

  def set_post_content_to contenu
    @post.instance_variable_set("@content", contenu)
    @post.instance_variable_set('@content_formated', nil)
  end

  let(:post) { @post }

  it 'répond' do
    expect(post).to respond_to :content_formated
  end

  context 'sans balises' do
    it 'retourne le même texte' do
      texte = "Un message normal à #{Time.now.to_i}"
      set_post_content_to texte
      expect(post.content_formated).to eq "<p>#{texte}</p>"
    end
  end
  context 'avec plusieurs paragraphes sans correction à faire' do
    it 'retourne plusieurs paragraphes' do
      texte = "Un paragraphe\n\nDeux paragraphes\n\nTrois paragraphes"
      set_post_content_to texte
      expect(post.content_formated).to eq "<p>Un paragraphe</p><p>Deux paragraphes</p><p>Trois paragraphes</p>"
    end
  end
  context 'avec une url' do
    it 'retourne l’url formatée' do
      texte = "[url=\"http://www.example.com\"]Exemple[/url]"
      set_post_content_to texte
      expect(post.content_formated).to eq "<p><a href=\"http://www.example.com\">Exemple</a></p>"
    end
  end
  
  context 'avec des balises de style' do

    it 'met des italiques si I' do
      texte = "Un texte [i]en italique[/i] pour voir. Et un deuxième [i]gourmand[/i] comme Marion."
      set_post_content_to texte
      expect(post.content_formated).to eq "<p>Un texte <i>en italique</i> pour voir. Et un deuxième <i>gourmand</i> comme Marion.</p>"
    end

    it 'met des italiques si U' do
      texte = "Un texte [u]en italique[/u] pour voir. Et un deuxième [u]gourmand[/u] comme Marion."
      set_post_content_to texte
      expect(post.content_formated).to eq "<p>Un texte <u>en italique</u> pour voir. Et un deuxième <u>gourmand</u> comme Marion.</p>"
    end

    it 'met des italiques si B' do
      texte = "Un texte [b]en italique[/b] pour voir. Et un deuxième [b]gourmand[/b] comme Marion."
      set_post_content_to texte
      expect(post.content_formated).to eq "<p>Un texte <b>en italique</b> pour voir. Et un deuxième <b>gourmand</b> comme Marion.</p>"
    end

    it 'met des italiques si STRONG' do
      texte = "Un texte [strong]en italique[/strong] pour voir. Et un deuxième [strong]gourmand[/strong] comme Marion."
      set_post_content_to texte
      expect(post.content_formated).to eq "<p>Un texte <strong>en italique</strong> pour voir. Et un deuxième <strong>gourmand</strong> comme Marion.</p>"
    end

    it 'met des italiques si EM' do
      texte = "Un texte [em]en italique[/em] pour voir. Et un deuxième [em]gourmand[/em] comme Marion."
      set_post_content_to texte
      expect(post.content_formated).to eq "<p>Un texte <em>en italique</em> pour voir. Et un deuxième <em>gourmand</em> comme Marion.</p>"
    end

  end
end
