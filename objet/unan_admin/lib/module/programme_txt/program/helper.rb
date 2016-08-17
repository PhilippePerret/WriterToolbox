# encoding: UTF-8
class UNANProgramme

  # = main =
  #
  # Méthode principale de construction de la map complète
  #
  def built
    LineProgramme.instances.first.output.in_div(id: 'programme_map')
  end

end #/UNANProgramme
