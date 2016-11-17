# encoding: UTF-8
class AnalyseBuild
class Film
class Scene

  require './objet/analyse_build/lib/module/parser_reg/_first/parse_relatifs_module.rb'
  include ModuleParseRelatifs

  # = main =
  #
  # Méthode principale qui parse la scène, appelée à l'instanciation
  #
  def parse
    parse_first_line
    parse_lines
  end

  def parse_first_line
    @horloge, @lieu_effet, @decor, @resume = first_line.split("\t")
    horloge_to_time
    explode_lieu_effet
  end

  # Transforme l'horloge en temps
  def horloge_to_time
    sec, mns, hrs = @horloge.split(':').reverse
    @time = sec.to_i + mns.to_i * 60 + hrs.to_i * 3600
  end

  def explode_lieu_effet
    @lieu, @effet = @lieu_effet.split(' ')
  end


  def parse_lines
    paras   = Array.new
    hnotes  = Hash.new

    # Certaines notes ne sont pas numérotées donc il faut leur définir
    # un indice. On prend le premier arbitrairement au nombre de lignes.
    # Normalement, il ne peut pas y avoir plus d'indices de lignes que de
    # notes
    next_index_note = lines.count + 1


    lines.each do |line|
      line = line.strip
      is_note = !!(line =~ /^\([0-9]+\) /)
      is_relatifs = !!(line =~ /^(B|N|P|S)[0-9]/)

      # On reconnait les notes au fait que ce sont des lignes qui
      # commencent par "(<nombre>) ". Si ce ne sont pas des notes,
      # ce sont des paragraphes.
      if is_note
        #
        # Traitement d'une note
        #
        # Une note commence toujours par "(<nombre>) "
        #
        indice_note, note = line.scan(/^\(([0-9]+)\)(.*$)/).to_a.first
        indice_note = indice_note.to_i
        note = note.nil_if_empty
        note != nil || next
        hnotes.merge!(
          indice_note => {note: note, index: indice_note}
        )
      elsif is_relatifs
        #
        # Traitement d'une liste de relatifs
        #
        # Une liste de relatifs commence par une lettre comme B, N, P
        # ou S suivie d'un nombre
        @liste_relatifs = line
        parse_relatifs
      else
        paras << Paragraphe.new(self, line).all_data
      end
    end
    @data_notes         = hnotes
    @data_paragraphes   = paras
  end

end #/Scene
end #/Film
end #/AnalyseBuild