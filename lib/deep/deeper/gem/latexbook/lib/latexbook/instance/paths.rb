# encoding: UTF-8
=begin

Module définissant les paths utiles

=end
class LaTexBook

  # {SuperFile} de la table des matières
  def file_tdm
    @file_tdm ||= begin
      p = nil
      ["tdm", "TDM", "_tdm_", "_TDM_"].each do |aff|
        p = SuperFile::new([sources_folder, "#{aff}.yaml"])
        break if p.exist?
      end
      p
    end
  end

  # {SuperFile} Dossier contenant les fichiers latex assets propres
  # au livre
  def assets_folder
    @assets_folder ||= SuperFile::new([folder_path, 'assets'])
  end

  # {SuperFile} Fichier contenant les données du livre
  def file_book_data
    @file_book_data ||= SuperFile::new([folder_path, "book_data.rb"])
  end

  # {SuperFile} Le path du fichier final
  def pdf_file
    @pdf_file ||= SuperFile::new(File.join(main_folder, "#{pdf_name||'latexbook'}.pdf"))
  end
  def pdf_file= value; @pdf_file = value end


  # Dossier principal (qui contient le dossier des sources)
  # C'est dans ce dossier que sera mis par défaut le manuel
  # PDF final
  def main_folder
    @main_folder ||= File.dirname(self.folder_path)
  end

end #/LaTexBook
