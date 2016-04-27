# encoding: UTF-8
=begin

Pour gérer les films au moment de la translation en LaTex

=end
class Narration
class Film
class << self

  # Tableau contenant toutes les citations de films
  # Servira notamment à indiquer combien de fois chaque film
  # a été cité.
  attr_reader :films_citations

  # Retourne le titre pour le film, en fonction du fait que
  # c'est une première apparition ou une apparition suivante.
  def titre_for_film film_id
    @films_citations ||= begin
      site.require_objet 'filmodico'
      Hash::new
    end
    first_apparition = false
    dtitres = @films_citations[film_id] ||= begin
      first_apparition = true
      ifilm = Filmodico::get(film_id)
      titre_simple = "{\\it \\small #{ifilm.titre.upcase.as_latex}}"
      tc = "#{titre_simple} {\\small ("
      tc << ifilm.titre_fr.as_latex + " – " if ifilm.titre_fr.to_s != ""
      realisateur = ifilm.realisateur.collect do |hreal|
        "#{hreal[:prenom]} #{hreal[:nom]}"
      end.pretty_join
      tc << "#{realisateur}, #{ifilm.annee}"
      tc << ")}"
      {
        complet:    "\\film{#{tc}}\\cite{#{film_id}}",
        simple:     "\\film{#{titre_simple}}\\cite{#{film_id}}",
        citations:  0
      }
    end
    dtitres[:citations] += 1
    first_apparition ? dtitres[:complet] : dtitres[:simple]
  end

end #/<< self Film
end #/Film
end #/Narration
