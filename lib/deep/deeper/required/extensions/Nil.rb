# encoding: UTF-8

class ::NilClass

  # Pour compatibilité quand une valeur est nil
  def in_hidden attrs
    "".in_hidden attrs
  end

  # Juste pour compatibilité avec les mêmes méthodes
  # pour String, Array, etc.
  def nil_if_empty
    nil
  end

  def nil_or_empty?
    true
  end

  def empty?
    true
  end

end
