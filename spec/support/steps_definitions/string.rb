# encoding: UTF-8

def le_texte str, options = nil
  TestString.new str, options
end

class TestString
  attr_reader :string
  attr_reader :options

  def initialize str, options = nil
    @string   = str
    @options  = options || Hash.new
  end

  # ---------------------------------------------------------------------
  #   Méthodes de test
  #
  #   NOTE
  #     * Elles doivent retourner obligatoirement 'self' pour le
  #       chainage.
  # ---------------------------------------------------------------------
  def contient search, args = nil
    args.nil? || @options = args
    @current_check_method = :contient
    search_init = search.freeze
    if _include? search
      success options[:success] || "Le texte “#{string}” contient “#{search_init}”."
    else
      raise options[:failure] || "Le texte “#{string}” ne contient pas “#{search_init}”."
    end
    return self
  end

  def ne_contient_pas search, args = nil
    @current_check_method = :ne_contient_pas
    args.nil? || @options = args
    search_init = search.freeze
    if _include? search
      raise options[:failure] || "Le texte “#{string}” ne devrait pas contenir “#{search_init}”."
    else
      success options[:success] || "Le texte “#{string}” ne contient pas “#{search_init}”."
    end
    return self
  end

  def contient_la_balise tagname, args = nil
    @current_check_method = :contient_la_balise
    args ||= Hash.new
    mess_success = args.delete(:success)
    mess_failure = args.delete(:failure)
    if a_balise?(tagname, args)
      success mess_success || "Le texte “#{string_reponse}” contient la balise #{tagname_reponse}."
      return self
    else
      raise mess_failure || "Le texte “#{string_reponse}” ne contient pas la balise #{tagname_reponse}."
    end
  end
  def ne_contient_pas_la_balise tagname, args = nil
    @current_check_method = :ne_contient_pas_la_balise
    args ||= Hash.new
    mess_success = args.delete(:success)
    mess_failure = args.delete(:failure)
    if a_balise?(tagname, args)
      raise mess_failure || "Le texte “#{string_reponse}” ne devrait pas contenir la balise #{tagname_reponse}."
    else
      success mess_success || "Le texte “#{string_reponse}” ne contient pas #{tagname_reponse}"
      return self
    end
  end

  # On répète la méthode précédente
  def et arg, args = nil
    self.send(@current_check_method, arg, args)
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles de recherche
  # ---------------------------------------------------------------------
  def _include? str
    str =
      case str
      when String   then /#{Regexp.escape str}/
      when Regexp   then str
      end
    return string =~ str
  end

  attr_reader :tag_name, :tag_attrs

  def a_balise? tagname, attrs
    @tag_name   = tagname
    @tag_attrs  = attrs

    texte  = attrs.delete(:text)
    attrs.key?(:class) && attrs[:class] = attrs[:class].gsub(/ /, '.')
    c = String.new
    attrs.key?(:in) && c << attrs.delete(:in)
    c = tagname
    # puts "node.has_css?('#{tagname}') = #{node.has_css?(tagname).inspect}"
    attrs.key?(:id) && c << "##{attrs.delete(:id)}"
    # puts "node.has_css?('#{c}') = #{node.has_css?(c).inspect}"
    attrs.key?(:class) && c << ".#{attrs.delete(:class)}"
    # puts "node.has_css?('#{c}') = #{node.has_css?(c).inspect}"
    ilatag = node.has_css?(c)
    ilatag && begin
      if texte
        texte.instance_of?(Regexp) || texte = /#{Regexp.escape texte}/
        node.text =~ texte
      else
        true
      end
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes pour la réponse
  # ---------------------------------------------------------------------

  # Le string à écrire dans la réponse
  def string_reponse
    if string.length < 30
      string
    else
      string[0..10] + ' […] ' + string[-11..-1]
    end.gsub(/\n/,'\\n')
  end
  # Le string à écrire dans la réponse quand c'est une
  # balise qui est recherchée
  def tagname_reponse
    c = "#{tag_name}"
    tag_attrs.key?(:id) && c << "##{tag_attrs[:id]}"
    tag_attrs.key?(:class) && c << ".#{tag_attrs[:class]}"
    return c
  end

  # ---------------------------------------------------------------------
  #   Autres méthodes
  # ---------------------------------------------------------------------
  # Le texte comme document Nokogiri::HTML
  def nokogiri
    @nokogiri ||= Nokogiri::HTML(string)
  end
  def node
    @node ||= Capybara::Node::Simple.new(string)
  end

end #/TestString
