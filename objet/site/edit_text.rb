# encoding: UTF-8
raise_unless_admin

site.require_module 'edit_text'

# Pour les snippets
page.add_javascript(PATH_MODULE_JS_SNIPPETS)
# Pour les snippets de Narration ou d'un document normal
# Noter qu'ils ne seront activés que si la CB "Snippets Narration"
# est cochée
page.add_javascript('./objet/cnarration/lib/module/snippets/pages.js')

class EditFile

  attr_reader :path

  def initialize path
    @path = path
  end

  def content
    @content ||= spath.read
  end
  def new_content
    @new_content ||= begin
      c = param(:file)[:content].nil_if_empty
      c != nil || raise('Impossible d’enregistrer un texte vide.')
      c.match(/\r/) && c.gsub!(/\r/,'')
      # Pour le "retourner"
      c
    end
  end

  # Sauvegarde le nouveau texte
  def save
    raise_unless_admin
    backup
    taille_init = content.length
    spath.write new_content
    flash "Texte sauvé (#{taille_init} → #{new_content.length} signes)."
    @content = new_content
  rescue Exception => e
    debug e
    error e.message
  else

  end

  # On fait un backup du fichier courant
  def backup
    spath_backup.write spath.read
  end

  def spath   ; @spath  ||= SuperFile.new(path) end
  def folder  ; @folder ||= File.dirname(path)  end
  def name    ; @name   ||= File.basename(path) end

  def spath_backup
    @spath_backup ||= SuperFile.new("#{path}.backup")
  end

end
def file
  @file ||= EditFile.new(param(:path) || param(:file)[:path])
end

case param(:operation)
when 'save_edited_text' then file.save
end
