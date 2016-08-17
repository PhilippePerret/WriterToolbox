# encoding: UTF-8
class LineProgramme

  # Retrait de la ligne
  attr_reader :retrait

  # La ligne brute, telle que relevée dans le fichier
  attr_reader :raw_line

  # La ligne épurée, telle qu'utilisée dans la map
  attr_reader :line

  # # Type de la ligne
  # # Ça peut être un début de segment (:segment), un
  # # travail (:travail), une chose à faire (:todo),
  # # sinon c'est une simple description (:description)
  # Cf la méthode `type' dans analyse.rb
  # attr_reader :type

  # {LineProgramme} Parent de cette ligne programme
  attr_accessor :parent

  # {Fixnum} Le jour de départ (pday_deb pour début) et le jour
  # de fin (pday_fin) du segment, s'il est défini. Sinon, c'est le
  # parent qui le définit.
  attr_reader :pday_deb, :pday_fin

  def initialize data
    @data = data
    data.each{|k,v| instance_variable_set("@#{k}", v)}
    self.class << self
  end

  # Les travaux contenus dans la ligne ([WORK...], [EXEMPLE...] etc.)
  def travaux
    @travaux ||= Array.new
  end


end #/LineProgramme
