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

  # Retourne le délimiteur de la première ligne, soit
  # une tabulation, soit une espace.
  def delimiter_first_line
    first_line.match(/\t/) ? "\t" : " "
  end

  REG_FIRST_LINE_SCENE =
    /^((?:[0-9]:)?(?:[0-9]?[0-9]:[0-9]?[0-9])) (EXT\.|INT\.|NOIR)(?: ?\/ ?(EXT\.|INT\.|NOIR))? (JOUR|NUIT|MATIN|SOIR|NOIR)(?: ?\/ ?(JOUR|NUIT|MATIN|SOIR|NOIR))? (.*?)(?: ?\/ ?(.*?))?$/
  def parse_first_line
    if delimiter_first_line == "\t"
      @horloge, @lieu_effet, @decor, @resume = first_line.split("\t")
    else
      @horloge, @lieu, @lieu_alt, @effet, @effet_alt, @decor, @decor_alt =
        first_line.match(REG_FIRST_LINE_SCENE).to_a
    end
    horloge_to_time
    # Cas spécial où c'est la ligne de fin
    if ['FIN', 'END', 'THE END'].include?( @lieu_effet.upcase )
      @lieu = @effet = nil
      @resume = "FIN"
      flash "La durée est : #{@time.inspect}"
      AnalyseBuild.current_film_duree = @time
    else
      explode_lieu_effet
    end
  end

  # Transforme l'horloge en temps
  # Mais la méthode fait bien plus puisqu'elle corrige aussi le temps en
  # fonction du temps de départ du film pour qu'il parte vraiment à 0:00
  #
  def horloge_to_time
    sec, mns, hrs = @horloge.split(':').reverse
    @time = sec.to_i + mns.to_i * 60 + hrs.to_i * 3600
    # debug "Horloge et time initial : #{@horloge} / #{@time}"
    if film.start_time.nil?
      film.start_time = @time.to_i
      @time  = 0
    else
      @time -= film.start_time
    end
    @horloge = @time.as_horloge
    # debug "Horloge et time après correction : #{@horloge} / #{@time}"
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
      is_relatifs = !!(line =~ /^(B|N|P|S)([0-9]+) /i)

      # On reconnait les notes au fait que ce sont des lignes qui
      # commencent par "(<nombre>) ". Si ce ne sont pas des notes,
      # ce sont des paragraphes ou la dernière ligne avec des
      # marques de relatifs (principalement les brins)
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
        # Un paragraphe normal de la scène
        paras << Paragraphe.new(self, line).all_data
      end
    end
    @data_notes         = hnotes
    @data_paragraphes   = paras
  end

end #/Scene
end #/Film
end #/AnalyseBuild
