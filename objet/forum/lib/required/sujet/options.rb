# encoding: UTF-8
=begin
Exention Forum::Sujet pour le champ options
=end
class Forum
class Sujet

  BIT_VALID   = 0
  BIT_TYPE_S  = 1

  def options
    @options ||= get(:options) || ""
  end

  def bit_validation
    @bit_validation ||= options[0].to_i || 0
  end
  # Pour valider un sujet
  def validate
    opts = "#{options}"
    opts[BIT_VALID] = 1
    set(:options => opts)
  end
  # Invalide un sujet précédemment validé
  def invalidate
    opts = "#{options}"
    opts[BIT_VALID] = 0
    set(:options => opts)
  end

  def type_s
    @type_s ||= options[1].to_i
  end
  def type_s= valeur
    opts = "#{options}"
    opts[BIT_TYPE_S] = valeur
    set(:options => opts)
  end

end #/Sujet
end #/Forum
