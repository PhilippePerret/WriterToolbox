# encoding: UTF-8
require 'json'
class Evc

  # Le chemin d'accès relatif (commence par ".") à l'evc
  attr_reader :path
  # {Array d'instances Evc::Events} Tous les évènements
  attr_reader :events
  # {Evc::Specs} Infos de l'évènemencier
  # Ou NIL si l'évènemencier ne contient pas de première ligne de
  # description
  attr_reader :specs


  # L'initialisation d'un Evènemencier se fait par le path
  # de son fichier de données
  # Noter, à titre d'information, que le dossier principal
  # (juste au-dessus de 'evc') est normalement l'ID du film
  # Mais on peut retrouver l'ID dans les infos si elles sont
  # définies
  def initialize path
    @path = path
  end

  # = main =
  #
  # Méthode principale qui parse le fichier évènemencier et définit :
  #   specs       Les infos sur le film (ou NIL)
  #   events      Toutes les instances Evc::Event des évènements
  def parse
    if lines.first.start_with?('{')
      @specs = Specs::new( self, lines.shift )
    else
      @specs = nil
    end
    @events = lines.collect { |line| Event::new( self, line ) }
  end

  # Enregistrement de l'évènemencier
  # TODO Peut-être le mettre seulement dans un module
  # administrateur
  def save
    File.unlink(path) if File.exist?(path)
    File.open(path, 'wb') { |f| f.write code2save }
    end
  end

  # Le code à sauver dans le fichier, reconstitution
  # des éléments actuels.
  def code2save
    @code2save ||= begin
      c = Array::new
      # Les infos d'entête
      c << specs.as_hash.to_json unless specs.nil?
      # On reconstitue tous les évènements
      c << events.collect { |iev| iev.as_raw_line }.join("\n")
      # Et on joint tout avec des retours chariot
      c.join("\n")
    end
  end

  # Toutes les lignes décomposées.
  # La première est peut-être la ligne d'infos.
  def lines
    @lines ||= begin
      ls = raw_content.gsub(/\r/,'')
      ls.split("\n").collect { |l| l.strip }
    end
  end

  # Le contenu brut du fichier
  def raw_content
    @content ||= begin
      File.open(path,'rb'){|f| f.read.force_encoding("utf-8")}
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes de path
  # ---------------------------------------------------------------------

  def filename
    @filename ||= File.basename(path)
  end
  def folder
    @folder ||= File.dirname(path)
  end

end
