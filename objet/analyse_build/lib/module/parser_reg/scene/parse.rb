# encoding: UTF-8
class AnalyseBuild
class Film
class Scene

  def parse_first_line
    @horloge, @lieu_effet, @decor, @resume, @brins_ids = first_line.split("\t")
    horloge_to_time
    explode_brins
    explode_lieu_effet
  end

  # Transforme l'horloge en temps
  def horloge_to_time
    sec, mns, hrs = @horloge.split(':').reverse
    @time = sec.to_i + mns.to_i * 60 + hrs.to_i * 3600
  end

  def explode_brins
    @brins_ids = (@brins_ids || '').split(' ').collect{|n| n.to_i}
    debug "@brins_ids = #{@brins_ids.inspect}"
  end

  def explode_lieu_effet
    @lieu, @effet = @lieu_effet.split(' ')
  end


  def parse_notes
    hnotes = Hash.new

    # Certaines notes ne sont pas numérotées donc il faut leur définir
    # un indice. On prend le premier arbitrairement au nombre de lignes.
    # Normalement, il ne peut pas y avoir plus d'indices de lignes que de
    # notes
    next_index_note = lines.count + 1
    lines[1..-1].each do |line|
      line = line.strip
      numbered = !!(line =~ /^\([0-9]+\)/)
      indice_note, note =
        if numbered
          line.scan(/^\(([0-9]+)\)(.*$)/).to_a.first
        else
          [next_index_note += 1, line]
        end
      indice_note = indice_note.to_i
      note = note.nil_if_empty
      note != nil || next
      hnotes.merge!(
        indice_note => {note: note, index: indice_note, numbered: numbered}
      )
    end
    @notes = hnotes
  end

end #/Scene
end #/Film
end #/AnalyseBuild
