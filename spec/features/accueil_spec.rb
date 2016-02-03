=begin

  la_page_a un_lien_pour_sinscrire
  la_page_a
=end
def la_page_a chose
  expect(page).to have_tag(chose.tag, chose.hash), "#{chose.human} est introuvable dans la page."
  puts "La page possède #{chose.human}"
end
def un_lien param
  TagFeature::new("a", {href:param.first}, param[1], "un lien pour #{param.last}")
end
def sinscrire
  ["user/signup", "S'inscrire", "s'inscrire"]
end
def sidentifier
  ["user/signin", "S'identifier", "s'identifier"]
end
def contact
  ["site/contact", "Contact", "contact"]
end
def sabonner titre = "S'abonner"
  ["user/paiement", nil, "s'abonner"]
end

def le_titre_principal
  TagFeature::new("span", {id:"site_title"}, "LA BOITE À OUTILS DE L'AUTEUR", "le titre principal")
end


class TagFeature
  attr_accessor :tag
  attr_accessor :with
  attr_accessor :text
  attr_accessor :human
  def initialize balise = nil, with_hash = nil, texte = nil, chose_humaine = nil
    @tag    = balise
    @with   = with_hash
    @text   = texte
    @human  = chose_humaine
  end

  def hash
    h = Hash::new
    h.merge!( with: with) unless with.nil?
    h.merge!( text: text) unless text.nil?
    h
  end
end


feature "Test de la page d'accueil" do
  scenario "Un visiteur quelconque rejoint la page d'accueil et trouve une page conforme" do

    visit home

    la_page_a le_titre_principal

    la_page_a un_lien sinscrire

    la_page_a un_lien sidentifier

    la_page_a un_lien contact

    la_page_a un_lien sabonner("Vous abonner")

  end
end
