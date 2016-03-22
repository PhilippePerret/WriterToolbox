# encoding: UTF-8
class Cnarration
class Admin
class << self

  # Méthode qui va checker que toutes les pages du dossier des
  # pages markdown de cours se trouvent bien enregistrées dans la
  # table des matières d'un livre.
  # La méthode produit une liste des pages inconnues qui doivent
  # être ajoutées.
  def check_pages_out_tdm

    site.require_objet 'cnarration'
    table = Cnarration::table_pages
    path_main_folder = File.join('.', 'data', 'unan', 'pages_cours', 'cnarration')

    full_output           = String::new
    full_err_ouput        = String::new
    nombre_total_pages    = 0
    nombre_total_erreurs  = 0

    Dir["#{path_main_folder}/*"].each do |pathfolder|
      next unless File.directory?(pathfolder) # on ne traite que les dossiers
      livre_name = File.basename(pathfolder)
      livre_id   = Cnarration::SYM2ID[livre_name.to_sym]
      raise "livre_id inconnu pour #{livre_name}" if livre_id.nil?

      # On écrit le titre du livre
      titre_id_livre = "Livre #{livre_name} (##{livre_id})".in_p
      full_output << titre_id_livre

      # Pour les erreurs de ce livre
      nombre_erreurs = 0
      errs_output = String::new

      Dir["#{pathfolder}/**/*.md"].each do |page_path|
        nombre_total_pages += 1
        page_handler = page_path.sub(/#{pathfolder}\//,'').sub(/\.md$/,'')
        page_is_in = Cnarration::table_pages.count(where:"livre_id = #{livre_id} AND handler = '#{page_handler}'") > 0
        page_is_out = !page_is_in

        if page_is_out
          nombre_erreurs += 1
          errs_output << "Handler : #{page_handler}".in_div
        end

        mark_in = page_is_in ? "OK" : "INCONNUE"
        full_output << "Handler : #{page_handler} - #{mark_in}".in_div
      end

      if nombre_erreurs > 0
        nombre_total_erreurs += nombre_erreurs
        full_err_ouput << titre_id_livre
        full_err_ouput << errs_output
      end
    end

    sortie = ""
    if nombre_total_erreurs > 0
      sortie << "<h3>ERREURS RENCONTRÉES</h3>"
      sortie << full_err_ouput
    else
      sortie << "Aucune page narration “out” n'a été trouvée."
    end
    sortie << "<h3>Rapport complet (#{nombre_total_pages} pages)</h3>"
    sortie << full_output

    return sortie
  end
end # /<< self
end #/ Admin
end #/ Cnarration
