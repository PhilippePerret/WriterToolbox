# encoding: UTF-8
raise_unless_admin

class Unan
class Program
class PageCours

  # def lien_edit titre = nil
  #   titre ||= titre || "Page de cours sans titre ##{id}"
  #   titre.in_a(href:"page_cours/#{id}/edit?in=unan_admin")
  # end

  def lien_edit titre = nil, options = nil
    options ||= Hash.new
    options.merge!(edit:true, titre:titre)
    link(options)
  end

  def lien_delete titre = nil, options = nil
    options ||= Hash.new
    options.merge!(delete:true, titre:titre)
    link(options)
  end
  alias :lien_destroy :lien_delete

end #/PageCours
end #/Program
end #/Unan
