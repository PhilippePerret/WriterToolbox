# encoding: UTF-8
module ModuleObjetCaseMethods

  # Inverse le comportement de la méthode +method_name+
  def not method_name, options = nil
    send(method_name, *options, inverser = true)
  end

end
