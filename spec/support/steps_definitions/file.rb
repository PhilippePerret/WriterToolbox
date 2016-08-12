# encoding: UTF-8

def le_fichier path, options = nil
  TestFile.new(path, options)
end


class TestFile
  attr_reader :path
  attr_reader :options
  def initialize path, options = nil
    @path     = path
    @options  = options || Hash.new
  end

  # ---------------------------------------------------------------------
  # Méthode de test
  # ---------------------------------------------------------------------
  def existe opts = nil
    opts.nil? || @options = opts
    if File.exist? path
      success options[:success] || "Le fichier `#{path}` existe."
    else
      raise options[:failure] || "Le fichier `#{path}` n'existe pas."
    end
  end
  def nexistepas opts = nil
    opts.nil? || @options = opts
    if File.exist? path
      raise options[:failure] || "Le fichier `#{path}` ne devrait pas exister"
    else
      success options[:success] || "Le fichier `#{path}` n'existe pas."
    end
  end

end #/TestFile
