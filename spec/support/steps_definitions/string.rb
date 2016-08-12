# encoding: UTF-8

def le_texte str, options = nil
  TestString.new str, options
end

class TestString
  attr_reader :string
  attr_reader :options

  def initialize str, options = nil
    @string   = str
    @options  = options
  end

  # ---------------------------------------------------------------------
  #   Méthodes de test
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
  end
  
  def ne_contient_pas search, args = nil
    args.nil? || @options = args
    @current_check_method = :ne_contient_pas
    search_init = search.freeze
    if _include? search
      raise options[:failure] || "Le texte “#{string}” ne devrait pas contenir “#{search_init}”."
    else
      success options[:success] || "Le texte “#{string}” ne contient pas “#{search_init}”."
    end
  end

  # On répète la méthode précédente
  def et arg, args = nil
    self.send(@current_check_method, arg, args)
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------
  def _include? str
    str =
      case search
      when String   then /#{Regexp.escape str}/
      when Regexp   then str
      end
    return string =~ str
  end

end #/TestString
