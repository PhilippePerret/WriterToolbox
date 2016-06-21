# encoding: UTF-8
class Unan
class Program
class Work

  # Définition des bits de la propriété :options
  
  # BIT 0 = Bit du type de travail
  def bit_type_w
    @bit_type_w ||= options[0].to_i
  end

  # BIT 1 = Non défini
  def bit_2
    @bit_2 ||= options[1].to_i
  end


end #/Work
end #/Program
end #/Unan
