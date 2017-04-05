# encoding: UTF-8
class Unan
class Program

  #
  # Fonctionnement de la pause
  #
  # La pause fonctionne avec :
  #
  #   pauses    Un Array de hash contenant toutes les pauses
  #             Chaque élément contient :start et :end
  #             Si le programme est en pause, on trouve un
  #             dernier élément où :start est défini mais pas
  #             :end
  #
  def mettre_en_pause
    opts = options
    opts = opts.set_bit(0,0)
    opts = opts.set_bit(1,1)
    set(options: opts)
    # Il faut enregistrer la date de la pause
    lespauses = get_pauses
    lespauses << {start: Time.now.to_i, end: nil}
    set_pauses(lespauses)
  end

  def sortir_de_pause
    opts = options
    opts = opts.set_bit(0,1)
    opts = opts.set_bit(1,0)
    set(options: opts)
    # Indiquer la fin de cette pause
    lespauses = get_pauses
    lespauses.last[:end] = Time.now.to_i
    set_pauses(lespauses)
  end

end#/Program
end#/UnanAdmin
