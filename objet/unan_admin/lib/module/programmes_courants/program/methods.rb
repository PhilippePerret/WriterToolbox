# encoding: UTF-8
class Unan
class Program

  def mettre_en_pause
    opts = options
    opts = opts.set_bit(0,0)
    opts = opts.set_bit(1,1)
    flash "Options mises à : #{opts.inspect}"
    set(options: opts)
  end

  def sortir_de_pause
    opts = options
    opts = opts.set_bit(0,1)
    opts = opts.set_bit(1,0)
    flash "Options mises à : #{opts.inspect}"
    set(options: opts)
  end
end#/Program
end#/UnanAdmin
