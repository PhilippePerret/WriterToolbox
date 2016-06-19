# encoding: UTF-8
class Cnarration
class Admin
class << self

  # Méthode qui va checker que toutes les pages du dossier des
  # pages markdown de cours se trouvent bien enregistrées dans la
  # table des matières d'un livre.
  #   1/ Que toutes les pages du dossier des pages markdown se
  #      trouvent utilisées par un enregistrement.
  #   2/ Que tous les enregistrements de pages ont un handler
  #      défini.
  #   3/ Que le handler défini, combiné au livre, possède bien
  #      un fichier physique (ce n'est pas une erreur, mais on peut
  #      le signaler)
  # La méthode produit une liste des pages erronnées.
  def check_pages_out_tdm

    site.require_objet 'cnarration'
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
      titre_id_livre = "Livre #{livre_name} (##{livre_id})".in_div(class:'underline')
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
          # La page physique peut ne pas exister pour le livre, mais peut avoir été
          # enregistrée quand même (sans avoir été associée à un livre, ce qui est une erreur)
          # Dans ce cas-là, on signale juste que la page n'est pas dans le livre auquel elle devrait appartenir.
          record_existe = Cnarration::table_pages.count(where: {handler: page_handler}) > 0
          nombre_erreurs += 1
          if record_existe
            errs_output << "Handler : #{page_handler} (MAIS DÉJÀ CONSIGNÉE OK => AJOUTER AU LIVRE)".in_div
          else
            errs_output << "Handler : #{page_handler}".in_div
          end
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

    # ---------------------------------------------------------------------
    #   CONTROLE DE L'APPARTENANCE À DES TDM DE LIVRE
    # ---------------------------------------------------------------------
    # Nombre de page ou titre non attribués à des livres
    # ou hors table des matières
    nombre_total_record_out_tdm = 0

    # Note : prendre en compte le fait qu'un élément peut se trouver
    # dans un livre, mais pas être classé dans la table des matières
    # de ce livre.

    # On récupère les TDM de tous les livres

    # Liste de tous les IDs se trouvant dans les tables des
    # matières.
    liste_all_ids_titres_et_pages = Array::new
    Cnarration::LIVRES.each do |bid, bd|
      Cnarration::table_tdms.select(where: {id: bid}).each do |bdata|
        liste_all_ids_titres_et_pages += bdata[:tdm]
      end
    end
    # debug "liste_all_ids_titres_et_pages: #{liste_all_ids_titres_et_pages.inspect}"

    nombre_pages_sans_fichier = 0
    liste_pages_sans_fichier = Array::new

    nombre_pages_sans_handler = 0
    liste_pages_sans_handler  = Array::new

    liste_pages_hors_livres = Array::new
    liste_pages_hors_tdm    = Array::new
    Cnarration::table_pages.select(colonnes:[:titre, :livre_id, :options, :handler]).each do |pdata|
      pid = pdata[:id]
      ptype = (pdata[:options][0]=="1" ? "page" : "titre")
      if pdata[:livre_id].nil? || pdata[:livre_id] == 0
        # => Page ou titre qui n'appartient pas à un livre
        liste_pages_hors_livres << {id: pid, type: ptype, titre: pdata[:titre]}
        nombre_total_record_out_tdm += 1
      else
        # La page/titre appartient bien à un livre

        if ptype == "page"
          # Si c'est une page, il faut qu'elle ait un handler défini et
          #  que son fichier physique existe.
          if pdata[:handler].to_s == ""
            nombre_pages_sans_handler += 1
            liste_pages_sans_handler <<  {id: pid, type: ptype, titre: pdata[:titre], livre_id: pdata[:livre_id]}
          else
            path_fichier = File.join(path_main_folder, Cnarration::LIVRES[pdata[:livre_id]][:folder], "#{pdata[:handler]}.md")
            unless File.exist?(path_fichier)
              nombre_pages_sans_fichier += 1
              liste_pages_sans_fichier << {id: pid, type: ptype, titre: pdata[:titre], livre_id: pdata[:livre_id]}
            end
          end
        end # / fin de si c'est une page (pas un titre)

        # Il faut vérifier qu'elle soit bien classé/e
        unless liste_all_ids_titres_et_pages.include? pid
          # => La page/titre est inconnu de la table des matières
          # du livre auquel il appartient
          nombre_total_record_out_tdm += 1
          liste_pages_hors_tdm << {id: pid, type: ptype, titre: pdata[:titre], livre_id: pdata[:livre_id]}
        end
      end
    end


    # ---------------------------------------------------------------------
    #   RAPPORT
    # ---------------------------------------------------------------------

    sortie = ""
    if nombre_total_erreurs > 0
      sortie << "1. PAGES PHYSIQUES NON DATABASÉES".in_h3(class:'underline')
      sortie << "Nombre de fichiers physiques à enregistrer : #{nombre_total_erreurs}"
      sortie << full_err_ouput
    else
      sortie << "Aucun fichier physique narration “hors database” n'a été trouvée. C'est-à-dire que tous les fichiers physiques sont consignés dans la base `cnarration.db`."
    end


    sortie << "2. TITRES OU PAGES HORS TDM DE LIVRE".in_h3(class:'underline')
    if nombre_total_record_out_tdm > 0
      sortie << "(La liste ci-dessous présente tous les enregistrements qui ne sont utilisés par aucune tdm de livre. Il faut <strong>distinguer le cas</strong> d'une page qui appartient à un livre MAIS n'est pas placée dans sa table des matières d'une page qui n'appartient à aucun livre. Pour corriger le problème, il suffit d'éditer la page, de l'attribuer à un livre, puis d'éditer la TdM du livre pour placer la page.)".in_div(class:'tiny')

      sortie << "2.1 Pages ou titre hors livres (#{liste_pages_hors_livres.count})".in_h4
      if liste_pages_hors_livres.count > 0
        sortie << "(Ces pages doivent être ajoutées aux livres — cf. les pages physiques non databasées pour trouver peut-être leur livre)".in_div(class:'tiny')
        sortie << (
          liste_pages_hors_livres.collect do |hpage|
            hpage[:titre].in_a(href:"page/#{hpage[:id]}/edit?in=cnarration").in_li
          end.join('').in_ul
        )
      end

      sortie << "2.2 Pages ou titres hors tables des matières (#{liste_pages_hors_tdm.count})".in_h4
      if liste_pages_hors_tdm.count > 0
        sortie << "(ces pages ou titres, qui appartiennent à des livres, doivent être placées dans les tables des matières de ces livres)".in_div(class:'tiny')
        sortie << (
          liste_pages_hors_tdm.collect do |hpage|
            lien_edit_page  = hpage[:titre].in_a(href:"page/#{hpage[:id]}/edit?in=cnarration")
            lien_edit_tdm   = "Éditer Tdm livre".in_a(href:"livre/#{hpage[:livre_id]}/edit?in=cnarration")
            ( "#{lien_edit_page} (#{lien_edit_tdm})" ).in_li
          end.join('').in_ul
        )
      end

    else
      sortie << "Tous les titres et pages se trouvent bien classés dans les tables des matières des livres.".in_p
    end

    sortie << "3 CONTRÔLE HANDLER/FICHIER PHYSIQUE".in_h3

    sortie << "3.1 Fichiers sans handler défini".in_h3
    if nombre_pages_sans_handler == 0
      sortie << "Toutes les pages définissent leur `handler`".in_p
    else
      sortie << "Nombre de pages sans handler défini : #{nombre_pages_sans_handler}"
      sortie << (
        liste_pages_sans_handler.collect do |hpage|
          hpage[:titre].in_a(href:"page/#{hpage[:id]}/edit?in=cnarration").in_li
        end.join('').in_ul
      )
    end

    sortie << "3.2 Fichiers sans fichier physique".in_h3
    if nombre_pages_sans_fichier == 0
      sortie << "Toutes les pages possèdent leur fichier physique".in_p
    else
      sortie << "Nombre de pages sans fichier physique : #{nombre_pages_sans_fichier}"
      sortie << "(afficher la page — en cliquant le lien ci-dessous — créera automatiquement le fichier physique)".in_div(class:'tiny')
      sortie << (
        liste_pages_sans_fichier.collect do |hpage|
          hpage[:titre].in_a(href:"page/#{hpage[:id]}/show?in=cnarration").in_li
        end.join('').in_ul
      )
    end

    sortie << "<hr />"
    sortie << "<h3>RAPPORT COMPLET (#{nombre_total_pages} pages)</h3>"
    sortie << full_output

    return sortie
  end

end #/<<self
end #/Admin
end #/Cnarration
