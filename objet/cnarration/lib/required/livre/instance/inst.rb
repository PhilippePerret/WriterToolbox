# encoding: UTF-8
class Cnarration
class Livre

  attr_reader :id

  def initialize book_id
    @id = book_id
  end

  def titre ;       @titre        ||= data[:hname]  end
  def folder_name;  @folder_name  ||= data[:folder] end

  def tdm params = nil
    @tdm ||= Tdm::new(self)
  end

  def data
    @data ||= Cnarration::LIVRES[id]
  end

end #/Livre
end #/Cnarration
