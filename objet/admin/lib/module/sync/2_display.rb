# encoding: UTF-8
class Sync

  # = main =
  #
  # Retourne le code de l'état des lieux de synchro entre les
  # fichiers locaux et distant, sur la boite à outils et sur
  # l'atelier Icare
  #
  # Noter que la méthode peut être appelée soit directement
  # soit à la fin d'une synchronisation, pour vérifier
  # l'état de synchro.
  def etat_des_lieux_offline
    build_inventory
    display_path.read
  end

  # Méthode principale qui construit l'état des lieux à afficher
  # en fonction des données de check.
  #
  # Produit le fichier temporaire qui contient le code à afficher.
  # Si ce fichier est moins vieux qu'une heure, on le prend. Dans
  # le cas contraire, ou lorsqu'on force le check de la synchronisation,
  # ce fichier est relu directement dans le fichier.
  def build_inventory

    # TODO: REMETTRE QUAND OK
    # return if display_path.exist? && display_path.mtime.to_i > (NOW - 3600)

    @suivi << "* Construction de l'inventaire à afficher"
    display_path.remove if display_path.exist?

    # La donnée dans laquelle on va conserver les données de
    # la synchronisation à opérer
    @datasync = Hash::new

    # On prend les données de la synchro (soit dans le fichier s'il n'est
    # pas trop vieux soit en les relevant à nouveau)
    dsync = online_sync_state

    c = String::new

    form = String::new

    form << "synchronize".in_hidden(name:'operation')

    form << (FILES2SYNC.collect do |fid, fdata|
      fdata.merge!(
        id:         fid,
        loc_mtime:  File.stat(fdata[:fpath]).mtime.to_i,
        boa_mtime:  (dsync[:boa][fid].nil? ? nil : dsync[:boa][fid][:mtime]),
        ica_mtime:  (dsync[:icare][fid].nil? ? nil : dsync[:icare][fid][:mtime])
      )
      ifile = Fichier::new(fdata)
      # On mémorise les synchronisation qui devront être faites
      @datasync.merge!( fid => ifile.data_synchro )
      # On retourne le code HTML pour ce fichier
      ifile.output
    end.join.in_pre(id:'sync_check'))

    form << (
      "Explication".in_a(onclick:"$('div#explication_force_synchro_narration').toggle()", class:'tiny fright') +
      "Forcer la synchronisation distante de cnarration.db".in_checkbox(id: 'cb_force_synchro_narration', name:'cb_force_synchro_narration').in_div +
      explication_force_synchro_narration
    ).in_p

    form << display_etat_des_lieux_fichiers_narration_icare
    form << display_etat_des_lieux_affiches_films

    # Le bouton pour lancer la synchronisation
    form << "Synchroniser".in_submit(class:'btn').in_div(class:'buttons')

    c << form.in_form(action: "admin/sync")

    # /fin du formulaire de synchronisation

    # Enregistrer les données de synchronisation à faire
    # dans le fichier adéquat, qui sera utilisé si la
    # synchronisation est demandée.
    # debug "\n\n@datasync : #{@datasync.pretty_inspect}\n\n"
    self.data_synchronisation = @datasync


    c << "<hr><div class='right btns'>"
    c << "Données de synchronisation".in_a(onclick:"$('pre#data_sync').toggle()", class:'small')
    c << " | "
    c << "Données retournées par le check".in_a(onclick:"$('pre#online_sync_state').toggle()", class:'small')
    c << " | "
    c << "Suivi des opérations".in_a(onclick:"$('pre#suivi_operation').toggle()", class:'small')
    c << "</div>"

    c << @datasync.pretty_inspect.in_pre(id: "data_sync", displayed: false)
    c << online_sync_state.pretty_inspect.in_pre(id: "online_sync_state", display: false)
    c << suivi.join("\n").in_pre(id: 'suivi_operation', display: false)

    # On écrit tout ce code dans le fichier temporaire pour qu'il soit
    # relu facilement.
    display_path.write(c)
  end

  # Retourne le code HTML à insérer dans le formulaire présentant
  # l'état des synchronisation concernant tous les fichiers à
  # synchroniser sur Icare pour la collection narration, c'est-à-dire :
  #   - les fichiers css utiles
  #   - tous les fichiers textes.
  # Note : La base est déjà checkée avant
  #
  def display_etat_des_lieux_fichiers_narration_icare

    # Les différences avec ce qui se trouve sur ICARE
    dnic = diff_narration_icare
    # Les différences avec ce qui se trouve sur BOA
    dboa = diff_narration_boa

    nombre_total_operations = dnic[:nombre_operations] + dboa[:nombre_operations]

    # On enregistre le résultat du check
    @datasync.merge!(cnarration_icare:  dnic)
    @datasync.merge!(cnarration_boa:    dboa)

    if dnic[:nombre_operations] == 0
      return "• Aucune opération à faire sur les fichier Narration sur ICARE et BOA".in_div(class:'small')
    end

    form = String::new
    if nombre_total_operations > 0
      # La case à cocher pour synchroniser les fichiers narration
      form << "Synchroniser tous les fichiers Narration (collection) sur ICARE et BOA".in_checkbox(id:'cb_synchro_files_narration', name:'cb_synchro_files_narration', checked:true)
    end
    form << "#{nombre_total_operations} opérations à exécuter.".in_div

    form << execute_operations_narration_with( dnic, :icare )
    form << execute_operations_narration_with( dboa, :boa )

    form.in_fieldset(class:'small', legend: "Fichiers Narration sur ICARE et BOA")
  end

  def execute_operations_narration_with dnic, lieu

    form = String::new

    on_icare  = lieu == :icare
    on_boa    = lieu == :boa

    lieu_str = on_boa ? "BOA" : "ICARE"

    if dnic[:css][:nombre_operations] == 0
      form << "Aucun fichier CSS à synchroniser sur #{lieu_str}".in_div(class:'tiny')
    else
      nb = dnic[:css][:nombre_synchro_req] + dnic[:css][:nombre_unknown_dis]
      if nb > 0
        form << ("Fichiers CSS à synchroniser sur #{lieu_str} : #{nb} sur #{dnic[:css][:nombre_total]} : " +
              (dnic[:css][:synchro_required]+dnic[:css][:distant_unknown]).collect do |pfile,nfile|
                nfile
              end.pretty_join.in_span(class:'tiny')).in_div
      else
        form << "Aucun fichier CSS à synchroniser sur #{lieu_str}".in_div(class:'small')
      end
      if dnic[:css][:nombre_unknown_loc] > 0
        form << ("Fichiers CSS à supprimer sur #{lieu_str} : #{dnic[:css][:nombre_unknown_loc]} : " +
        dnic[:css][:local_unknown].collect { |nfile| nfile }.pretty_join.in_span(class:'tiny')).in_div
      end
    end

    if dnic[:files][:nombre_operations] == 0
      form << "Aucun fichier texte (ERB) à synchroniser sur #{lieu_str}".in_div(class:'tiny')
    else
      nb = dnic[:files][:nombre_synchro_req] + dnic[:files][:nombre_unknown_dis]
      if nb > 0
        form << ("Fichiers ERB à synchroniser (#{dnic[:files][:synchro_required].count}) et ajouter (#{dnic[:files][:distant_unknown].count}) sur #{lieu_str} : #{nb} sur #{dnic[:files][:nombre_total]} : " +
                (dnic[:files][:synchro_required]+dnic[:files][:distant_unknown]).collect do |pfile, nfile|
          nfile
        end.pretty_join.in_span(class:'tiny')).in_div
      else
        form << "Aucun fichier ERB à synchroniser sur #{lieu_str}".in_div(class:'small')
      end
      if dnic[:files][:nombre_unknown_loc] > 0
        form << ("Fichiers ERB à supprimer sur #{lieu_str} : #{dnic[:files][:nombre_unknown_loc]} : " +
        dnic[:files][:local_unknown].collect { |nfile| nfile }.pretty_join.in_span(class:'tiny')).in_div
      end
    end

    return form
  end

  def display_etat_des_lieux_affiches_films
    # On peut fabriquer l'affichage des synchros
    # à faire au niveau des affiches de films.
    # Mais seulement s'il y a du boulot à faire, sinon une
    # simple phrase pour expliquer que tout est à jour.
    daf = diff_affiches

    if daf[:nombre_actions] == 0
      return "• Les affiches de films sont à jour sur BOA comme sur ICARE".in_div(class:'small')
    end

    form = String::new

    # On enregistre le résultat — i.e. les
    # affiches à synchroniser et à détruire — dans le hash
    # contenant toutes les données de synchronisation.
    @datasync.merge!( affiches: daf )


    nb_upl_ica = daf[:icare][:nombre_uploads].to_s.rjust(5)
    nb_del_ica = daf[:icare][:nombre_deletes].to_s.rjust(5)
    nb_upl_boa = daf[:boa][:nombre_uploads].to_s.rjust(5)
    nb_del_boa = daf[:boa][:nombre_deletes].to_s.rjust(5)

    form << (<<-HTML)
<pre class='small'>
 -----------------------------
|        | Uploads | Deletes |
|--------|---------|---------|
| ICARE  |#{nb_upl_ica}    |#{nb_del_ica}    |
| B.O.A. |#{nb_upl_boa}    |#{nb_del_boa}    |
 -----------------------------
</pre>
    HTML


    [ ["Icare", :icare], ["B.O.A.", :boa]
    ].each do |darr|
      lieu, ident = darr
      data_aff = daf[ident]
      [:uploads, :deletes].each do |key_s|
        mess = "#{key_s.to_s.capitalize} sur #{lieu} : "
        key_nb = "nombre_#{key_s}".to_sym
        mess << (data_aff[key_nb] > 0 ? data_aff[key_s].pretty_join : "aucune")
        form << mess.in_div(class:'small')
      end
    end

    # Une case à cocher pour stipuler de synchroniser les affiches
    if daf[:nombre_actions] > 0
      form << "Synchroniser les affiches".in_checkbox(name: 'cb_synchronize_affiches', id: 'cb_synchronize_affiches', checked:true).in_p
    end

    return form.in_fieldset(legend: "Affiches de films")
  end

  def explication_force_synchro_narration
    <<-HTML
<div id='explication_force_synchro_narration' class="small italic" style="display:none;margin-left:2em">
  Dans la synchronisation normale de Narration, on compare les niveaux de développement des deux bases locales et distantes, pour garder toujours la plus haute. Mais parfois, suite à une erreur, il peut être nécessaire de rabaisser le niveau de développement. Pour le faire, il faut forcer l'upload en cochant cette case.<br>Par prudence, l'opération complète à faire est :
  <ul>
    <li>Synchroniser normalement la base — si nécessaire (voyant rouge) — pour récupérer les toute dernières valeurs,</li>
    <li>Modifier le niveau de développement en local,</li>
    <li>Synchroniser les deux bases en forçant la synchro online (en cochant cette case).</li>
  </ul>
</div>
    HTML
  end

end #/Sync
