# encoding: UTF-8
def boite_interaction
  menu_police         +
  menu_font_size      +
  menu_line_height    +
  menu_themes         +
  champs_scenodico    +
  champs_filmodico    +
  champs_options      +
  menu_checkup_groups +
  aide_narration        #  seulement si page Narration
end

def narration?
  @is_narration = param(:snippets_narration) == 'on' if @is_narration === nil
  @is_narration
end

def menu_police
  [
    'Lucida Console', 'Georgia', 'Arial', 'serif', 'monospace'
  ].collect{|p| [p,p]}.in_select(id:'police', name:'police',
    onchange:"$.proxy(EditText,'onchange_police',this.value)()")
end
def menu_line_height
  {
    '1'   => 'Serré',
    '1.3' => 'Normal',
    '1.7' => 'Écarté', # si changé, il faut modifier ready dans interaction.js
    '2.3' => 'Très écarté'
  }.collect{|k,v|[k,v]}.in_select(id:'line_height', name:'line_height',
    onchange: "$.proxy(EditText,'onchange_lineheight',this.value)()")
end
def menu_font_size
  ['11','12', '13','14','14.5','15','15.5','16','16.5','17','17.5','18','18.5','19','20','21'
  ].collect{|k|[k,k]}.in_select(id:'font_size', name: 'font_size',
  onchange: "$.proxy(EditText,'onchange_fontsize',this.value)()")
end

def menu_themes
  [
    ['normal',        'Thème Normal'],
    ['inverse',       'Thème Inverse'],
    ['inverse_blue',  'Blue thème'],
    ['blue_print',    'Thème blue-print']
  ].in_select(id: 'theme', name:'theme',
  onchange: "$.proxy(EditText,'onchange_theme',this.value)()")
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
def champs_options
  checkbox_snippets_markdown.in_div  +
  checkbox_snippets_narration.in_div
end
def checkbox_snippets_markdown
  'Snippets Markdown'.in_checkbox(id:'snippets_markdown', name:'snippets_markdown', onchange: "$.proxy(EditText,'oncheck_snippets_markdown',this.checked)()")
end
def checkbox_snippets_narration
  'Snippets Narration'.in_checkbox(checked: narration?, id:'snippets_narration', name:'snippets_narration', onchange:"$.proxy(EditText,'oncheck_snippets_narration',this.checked)()")
end

def aide_narration
  narration? || (return '')
  (
    'Balises spéciales'.in_legend +
    'AIDE'.in_a(href: 'admin/aide?in=cnarration', target: :new) +
    'Only admin'.in_a(onclick: "balise('adminonly')", class: 'block') +
    'Relecture'.in_a(onclick: "balise('RELECTURE_[RC][RC]', '[RC][RC]_RELECTURE', true)", class: 'block') +
    'Text only on WEB'.in_a(onclick: "balise('webonly')", class: 'block') +
    'Text only on PAPER'.in_a(onclick: "balise('paperonly')", class: 'block')
  ).in_fieldset(class:'left')
end

def menu_checkup_groups
  (
  'Checkup groupes (dans page)'.in_div(class: 'small') +
  ''.in_input_text(name:'checkup_group',id:'checkup_group').in_div +
  '<select id="checkup_groups" name="checkup_groups" onchange="$(\'input#checkup_group\').val(this.value).focus()"></select>'.in_div
  ).in_div(id: 'block_checkup_groups', display: false)
end
