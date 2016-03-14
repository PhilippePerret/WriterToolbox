# encoding: UTF-8
=begin
Ce script ne sert que pour ajax, pour relever la liste des
dossiers courant du livre donné en argument à partir du dossier
`from` qui a la base est "/"
=end
class Cnarration
class Livre
  def folders_from from_folder = "/"
    Dir["#{folder}#{from_folder}**"].collect do |p|
      next nil unless File.directory?(p)
      File.basename p
    end.compact.join('::')
  end
end #/Livre
end #/Cnarration

def book
  @book ||= Cnarration::Livre::get(param(:book_id).to_i)
end
def from_folder
  @from_folder ||= param(:from)
end


Ajax << {
  hierarchie: book.folders_from(from_folder)
}
