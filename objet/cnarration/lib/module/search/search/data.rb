# encoding: UTF-8
class Cnarration
class Search
  # ---------------------------------------------------------------------
  #   Les données de la recherche
  # ---------------------------------------------------------------------
  def data
    @data ||= param(:csearch)
  end
  def searched
    @searched ||= data[:content].nil_if_empty
  end
  # Que la recherche soit régulière ou non, on aura besoin
  # de cette expression pour remplacer les textes dans
  # le texte des titres ou des textes (cf. class Found).
  def reg_searched
    @reg_searched ||= begin
      str = regular? ? searched : Regexp::escape(searched)
      exact? ? (whole_word? ? /\b#{str}\b/ : /#{str}/) : (whole_word? ? /\b#{str}\b/i : /#{str}/i)
    end
  end
  def in_titres?
    @search_in_titres = data[:search_in_titre] == 'on' if @search_in_titres === nil
    @search_in_titres
  end
  def in_textes?
    @search_in_textes = data[:search_in_texte] == 'on' if @search_in_textes === nil
    @search_in_textes
  end
  alias :in_pages? :in_textes?
  
  def regular?
    @regular_search = ( data[:regular_search] == 'on' || whole_word? ) if @regular_search === nil
    @regular_search
  end
  def exact?
    @search_exact = data[:search_exact] == 'on' if @search_exact === nil
    @search_exact
  end
  def whole_word?
    @whole_word = data[:search_whole_word] == 'on' if @whole_word === nil
    @whole_word
  end

  # Le développement minimum de la page pour qu'elle soit consultable
  # par le visiteur.
  # Pour un administrateur, toutes les pages sans exception.
  def developpement_minimum
    @developpement_minimum ||= (user.admin? ? 0 : 7)
  end

end #/Search
end #/Cnarration
