# encoding: UTF-8
class PageCours

  include MethodesObjetsBdD
  
  # {Fixnum} Identifiant de la page de cours éditée
  attr_reader :id
  def initialize pid
    @id = pid
  end

  # Actualiser le contenu de la page
  def update
    corrige_content
    # Faire un backup du fichier actuel
    fullpath_backup.write fullpath.read
    # Enregistrer le nouveau contenu
    fullpath.write content
    flash "Page ##{id} enregistrée dans son fichier."
  rescue Exception => e
    fullpath.remove if fullpath.exist?
    fullpath.write fullpath_backup.read
    error "Un problème est survenu, j'ai remis le texte original."
  else
    # On peut détruire le backup
    fullpath_backup.remove if fullpath_backup.exist?
    # Actualisation de la date de dernière modification
    set(updated_at: NOW)
  end

  def corrige_content
    texte = param(:page_cours)[:content]
    texte.gsub(/\r/, '') if texte.match("\n")
    debug "Texte : #{texte}"
    @content = texte
  end


  def content
    @content ||= begin
      fullpath.read
    end
  end

  def data
    @data ||= table_pages_cours.get(id)
  end

  # Type de la page (page un an un script, ou narration, ou
  # collection narration)
  def type
    @type ||= data[:type]
  end
  # Path relatif depuis le dossier du type
  def relpath
    @relpath ||= data[:path]
  end
  def fullpath
    @fullpath ||= Unan::main_folder_data + "pages_cours/#{type}/#{relpath}"
  end
  def fullpath_backup
    @fullpath_backup ||= begin
      dirname + "#{affixe}-backup#{NOW}.#{extension}"
    end
  end

  def dirname
    @dirname ||= fullpath.dirname
  end
  def affixe
    @affixe ||= fullpath.affixe
  end
  def extension
    @extension ||= fullpath.extension
  end

  def table_pages_cours
    @table_pages_cours ||= Unan::Program::PageCours::table_pages_cours
  end
  alias :table :table_pages_cours

end #/PageCours

def page_cours
  @page_cours ||= PageCours.new(site.current_route.objet_id)
end

case param(:operation)
when 'save_page_content'
  page_cours.update
end
