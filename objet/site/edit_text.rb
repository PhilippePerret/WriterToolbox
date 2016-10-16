# encoding: UTF-8
raise_unless_admin

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
    spath.read
  end

  def spath ; @spath ||= SuperFile.new(path) end
end
def file
  @file ||= EditFile.new(param(:path) || param(:file)[:path])
end
