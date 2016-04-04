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

    # TODO: REMETTRE QUAND CE SERA OK POUR NE PAS RECONSTRUIRE À
    # CHAQUE FOIS
    # return if display_path.exist? && display_path.mtime.to_i > (NOW - 3600)

    display_path.remove if display_path.exist?

    # La donnée dans laquelle on va conserver les données de
    # la synchronisation à opérer
    datasync = Hash::new

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
        boa_mtime:  (dsync[fid].nil? ? nil : dsync[fid][:mtime]),
        ica_mtime:  (dsync[:icare][fid].nil? ? nil : dsync[:icare][fid][:mtime])
      )
      ifile = Fichier::new(fdata)
      # On mémorise les synchronisation qui devront être faites
      datasync.merge!( fid => ifile.data_synchro )
      # On retourne le code HTML pour ce fichier
      ifile.output
    end.join.in_pre(id:'sync_check'))

    # Ici, on vérifie les affiches pour narration
    form << "Affiches de films".in_h3

    # On fait l'analyse des listes d'affiches qui ont été
    # retournées et on enregistre le résultat — i.e. les
    # affiches à synchroniser et à détruire — dans le hash
    # contenant toutes les données de synchronisation.
    datasync.merge!( affiches: diff_affiches )

    # Ensuite, on peut fabriquer l'affichage des synchros
    # à faire au niveau des affiches de films.
    daf = diff_affiches

    debug "diff_affiches : #{diff_affiches.pretty_inspect}"

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

    # TODO

    # TODO: Traiter les pages de narration pour qu'elles soient aussi
    # synchronisées sur l'atelier icare (comme les affiches)
    # NOTE: IL FAUDRA METTRE icare: true à narration dans les constantes
    # pour synchroniser aussi cnarration mais ATTENTION : POUR LE MOMENT
    # CES DEUX BASES SONT CERTAINEMENTS RADICALEMENT DIFFÉRENTES

    # Le bouton pour lancer la synchronisation
    form << "Synchroniser".in_submit(class:'btn').in_div(class:'buttons')

    c << form.in_form(action: "admin/sync")

    # /fin du formulaire de synchronisation

    # Enregistrer les données de synchronisation à faire
    # dans le fichier adéquat, qui sera utilisé si la
    # synchronisation est demandée.
    data_synchronisation= datasync


    c << "<hr><div class='right btns'>"
    c << "Données de synchronisation".in_a(onclick:"$('pre#data_sync').toggle()", class:'small')
    c << " | "
    c << "Données retournées par le check".in_a(onclick:"$('pre#online_sync_state').toggle()", class:'small')
    c << "</div>"

    c << datasync.pretty_inspect.in_pre(id: "data_sync", displayed: false)
    c << online_sync_state.pretty_inspect.in_pre(id: "online_sync_state", display: false)

    display_path.write(c)
  end


end #/Sync
