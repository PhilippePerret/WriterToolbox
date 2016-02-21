# encoding: UTF-8
=begin

Méthodes d'helper pour la synchronisation (note : celle des fichiers
indépendants tels que les bases de données du scénodico, etc.)

@usage

    RFile::new("./path/to/file.db").block_synchro

=end
class RFile

  # +options+
  #   :action     L'action du formulaire en cas de désynchro
  #   ------------------------------------------------------------
  #   :verbose    Si true, envoie un message même lorsque les deux
  #               fichier sont synchronisés.
  def bloc_synchro options

    case param(:operation)
    when 'synchro_upload_local_rfile_to_distant_file'
      autre_rfile = RFile::new( param(:synchro_rfile_path) )
      autre_rfile.upload
      return autre_rfile.message
    when 'synchro_download_distant_rfile_local_file'
      autre_rfile = RFile::new( param(:synchro_rfile_path) )
      autre_rfile.distant.download
      return autre_rfile.message
    else
      # On poursuit
    end

    verbose = !!options[:verbose]
    return "" if synchronized? && !verbose

    update_required = nil
    c = ""
    # - Check existence des fichiers -
    if exist? == false && distant.exist? == false
      raise "Ni le fichier local #{path} ni le fichier distant n'existent, impossible de les synchroniser…"
    end
    if exist?
      c << "Le fichier <strong>local</strong> existe.".in_div.freeze
      c << "Dernière modification : #{mtime.as_human_date(true, true)}".in_div.freeze
    else
      update_required = :distant_to_local
      c << "Le fichier <span class='bold'>local</span> n'existe pas.".in_span(class:'warning').in_div
    end
    if distant.exist?
      c << "Le fichier <strong>distant</strong> existe.".in_div.freeze
      c << "Dernière modification : #{distant.mtime.as_human_date(true, true)}".in_div.freeze
    else
      update_required = :local_to_distant
      c << "Le fichier <span class='bold'>distant</span> n'existe pas.".in_span(class:'warning').in_div
    end

    # - Check de la date des fichiers s'ils existent tous les deux
    if update_required.nil?
      if mtime == distant.mtime
        return "" unless verbose
      elsif mtime > distant.mtime
        update_required = :local_to_distant
      else
        update_required = :distant_to_local
      end
    end

    # ---------------------------------------------------------------------
    case update_required
    when :local_to_distant
      operationh = "Upload le local vers le distant"
      operation  = 'synchro_upload_local_rfile_to_distant_file'
    when :distant_to_local
      operationh = "Download le distant vers le local"
      operation  = 'synchro_download_distant_rfile_local_file'
    else
      return "" unless verbose
      operation = nil
    end

    if operation
      c << "Les deux fichiers ont besoin d'être synchronisés.".in_p
      c << (
        operation.in_hidden(name:'operation', id:'operation') +
        path.in_hidden(name:'synchro_rfile_path', id:'synchro_rfile_path') +
        operationh.in_submit(class:'btn small')
      ).in_form(action:options[:action], class:'inline')
    else
      c << "Les deux fichiers sont synchronisés.".in_p
    end

    return c
  end

end
