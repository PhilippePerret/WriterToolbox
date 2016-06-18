# encoding: UTF-8
=begin
Extention de Unan::Program::Exemple pour l'affichage de la
liste des exemples
=end
site.require_objet 'unan'
Unan::require_module 'exemple'
UnanAdmin::require_module 'exemple'

class Unan
class Program
class Exemple

  # Helper pour afficher l'exemple
  def as_li
    (
      boutons_edition +
      "[##{id}] #{titre}"
    ).in_li(class:'li_ex')
  end

  def boutons_edition
    (
      "[edit]".in_a(href:"exemple/#{id}/edit?in=unan_admin") +
      "[show]".in_a(href:"exemple/#{id}/show?in=unan")
    ).in_div(class:'fright tiny')
  end

end #/Exemple
end #/Program
end #/Unan

def nombre_exemples
  @nombre_exemples ||= Unan::table_exemples.count
end
# Liste des IDS de toutes les questions
def ids_exemples
  @ids_exemples ||= begin
    data_request = {colonnes: []}
    # Si un filtre est défini on l'applique
    if (filtre = param(:filtre))
      stitre = filtre[:titre].nil_if_empty
      sexemple = filtre[:exemple].nil_if_empty
      ssource  = filtre[:source_src]
      ssource = nil if ssource.to_i == 0
      ssujet  = filtre[:sujet]
      ssujet  = nil if ssujet == "0" || ssujet == "0-"

      where = Array::new
      where << "titre LIKE '%#{stitre}%'"               unless stitre.nil?
      where << "exemple LIKE '%#{sexemple}%'"           unless sexemple.nil?
      where << "SUBSTR(source_type,1,1) = '#{ssource}'" unless ssource.nil?
      where << "SUBSTR(source_type,8,1) = '#{ssujet}'"  unless ssujet.nil?

      if stitre!=nil || sexemple!= nil
        data_request.merge!(nocase:true)
      end
      unless where.empty?
        where = where.join(' AND ')
        data_request.merge!(where:where)
      end
    end

    # On relève les exemples correspondant à
    # la requête et au filtre
    Unan::table_exemples.select(data_request).collect{|h|h[:id]}
  end
end


# Retourne le code HTML pour le filtre des questions
# Ce filtrage peut se faire suivant trois caractéristiques :
#   - le type de question
#   - le titre
#   - l'identifiant d'un questionnaire
def boite_filtre
  site.require 'form_tools'
  form.prefix = "filtre"
  (
    "filtrer_items".in_hidden(name:'operation') +
    form.field_text("in Titre", 'titre', nil) +
    form.field_select("Sujet", 'sujet', nil, {values:sujets_cibles_as_select}) +
    form.field_text("in exemple", 'content', nil, {class:'high'}) +
    form.field_select("Tiré de", 'source_src', nil, {values: Unan::Program::Exemple::TYPES_SOURCES}) +
    form.submit_button("Filtrer", class_button:'small')
  ).in_form(action:"exemple/list?in=unan_admin", class:'', style:"width:60%;border:1px solid;display:block;text-align:left;margin-left:40%").in_div(class:'tiny')
end
