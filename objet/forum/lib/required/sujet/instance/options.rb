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
    @bit_validation ||= options[BIT_VALID].to_i # || 0
  end
  def bit_validation= value
    @bit_validation = value
  end
  # Pour valider un sujet
  def validate
    set(:options => "#{options}".set_bit(BIT_VALID, '1'))
  end
  # Invalide un sujet précédemment validé
  def invalidate
    set(:options => "#{options}".set_bit(BIT_VALID, '0'))
  end

  def type_s
    @type_s ||= options[BIT_TYPE_S].to_i
  end
  def type_s= valeur
    @type_s = valeur
  end

end #/Sujet
end #/Forum
