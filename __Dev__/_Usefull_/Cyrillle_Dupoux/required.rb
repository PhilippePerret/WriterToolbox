# encoding: UTF-8
=begin
  
  Mettre simplement :
    require_relative 'required'
  … en haut des fichiers pour requérir toutes les librairies de ce module
=end

def table_programs
  @table_programs ||= site.dbm_table(:unan, 'programs', online = true)
end

# Table des works absolus
def table_absolute_works
  @table_absolute_works ||= site.dbm_table(:unan, 'absolute_works', online = false)
end

# Instance de table des works de l'utilisateur
def table_works user_id = nil
  if user_id.nil? && @table_works.nil?
    raise "Il faut transmettre l'identifiant à la méthode `table_works` lors de son premier appel"
  end
  @table_works ||= SiteHtml::DBM_TABLE.new(:users_tables, "unan_works_#{user_id}", online = true)
end

# Retourne la "carte" du travail de données +hwork+
def work_card hwork
  # Les données du travail absolu
  dabs = table_absolute_works.get(hwork[:abs_work_id])
  c = []
  c << "-- WORK ##{hwork[:id]} (absolu : ##{dabs[:id]}) / P-Day #{hwork[:abs_pday]}"
  c << "   Titre : #{dabs[:titre]}"
  c << "   Commencé le : #{hwork[:created_at].as_human_date(true, true, ' ')}"
  if hwork[:ended_at]
    c << "   Achevé le #{hwork[:ended_at].as_human_date(true, true, ' ')}"
  else
    c << "   - Inachevé -"
  end
  c << "  Points : #{hwork[:points]}" if hwork[:points]
  
  c.join("\n")
end