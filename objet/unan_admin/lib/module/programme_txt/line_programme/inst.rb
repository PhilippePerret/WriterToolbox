# encoding: UTF-8
class LineProgramme

  attr_reader :retrait
  attr_reader :line

  # {LineProgramme} Parent de cette ligne programme
  attr_accessor :parent

  def initialize data
    @data = data
    data.each{|k,v| instance_variable_set("@#{k}", v)}
  end

  def items
    @items ||= Array.new
  end

end #/LineProgramme
