# encoding: UTF-8
class UNANProgramme

  # = main =
  #
  # Méthode principale de construction de la map complète
  #
  def built
    debug "-> built"
    LineProgramme.instances.first.output.in_div(id: 'programme_map')
  end

end #/UNANProgramme
