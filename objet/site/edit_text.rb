# encoding: UTF-8
raise_unless_admin

# Pour les snippets
page.add_javascript(PATH_MODULE_JS_SNIPPETS)

# ---------------------------------------------------------------------
#   Méthodes d'helper
# ---------------------------------------------------------------------
def menu_police
  [
    'Lucida Console', 'Georgia', 'Arial', 'serif', 'monospace'
  ].collect{|p| [p,p]}.in_select(id:'police', name:'police',
    onchange:"$.proxy(EditText,'onchange_police',this.value)()")
end
def menu_line_height
  {
    '1'   => 'Serré',
    '1.2' => 'Normal',
    '1.4' => 'Écarté',
    '1.7' => 'Très écarté'
  }.collect{|k,v|[k,v]}.in_select(id:'line_height', name:'line_height',
    onchange: "$.proxy(EditText,'onchange_lineheight',this.value)()",
    selected: '1.2'
  )
end

# Champ pour chercher un mot du scénodico
def champs_scenodico
  (
    ''.in_input_text(name:'scenodico', id:'scenodico', placeholder: "Scénodico") +
    'Chercher'.in_button(onclick: "$.proxy(EditText,'cherche_scenodico')()")
  ).in_div(id:'div_scenodico', class: 'biblio')
end

def champs_filmodico
  (
    ''.in_input_text(name:'filmodico', id:'filmodico', placeholder: "Filmodico") +
    'Chercher'.in_button(onclick: "$.proxy(EditText,'cherche_filmodico')()")
  ).in_div(id:'div_filmodico', class: 'biblio')
end
# ---------------------------------------------------------------------
# /fin des méthodes d'helper
# ---------------------------------------------------------------------

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
