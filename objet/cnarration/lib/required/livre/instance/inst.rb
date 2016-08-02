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
    @tdm ||= Tdm.new(self)
  end

  def data
    @data ||= begin
      d = Cnarration::LIVRES[id]
      # Protection au cas où +d+ n'existe pas (ce qui arrive encore…)
      if d.nil?
        derr = {
          exception:  "Impossible d'obtenir les données du livre narration d'identifiant `#{id.inspect}` dans Cnarration::LIVRES",
          url:        site.current_route.route.to_s,
          file:       __FILE__
        }
        send_error_to_admin(derr)
        Hash.new
      else
        d
      end
    end
  end

end #/Livre
end #/Cnarration
