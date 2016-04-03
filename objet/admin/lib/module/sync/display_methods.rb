# encoding: UTF-8
class Sync

  # = main =
  #
  # Retourne le code de l'état des lieux de synchro entre les
  # fichiers locaux et distant, sur la boite à outils et sur
  # l'atelier Icare
  #
  def etat_des_lieux_offline
    build_inventory
    # retourne le code de l'inventaire
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

    form << "synchronise".in_hidden(name:'operation')

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
    form << "Affiches de films à uploader sur Icare".in_h3
    datasync.merge!(affiches_icare: diff_affiches_icare)
    nombre_aff_uploads = diff_affiches_icare[:nombre_uploads]
    mess = if nombre_aff_uploads == 0
      "Aucune affiche à mettre sur Icare"
    else
      s = nombre_aff_uploads > 1 ? 's' : ''
      "#{nombre_aff_uploads} affiche#{s} à uploader sur Icare : #{diff_affiches_icare[:upload_on_icare].pretty_join}"
    end
    form << mess.in_p

    nombre_aff_deletes = diff_affiches_icare[:nombre_deletes]
    mess = if nombre_aff_deletes == 0
      "Aucune affiche à détruire sur Icare"
    else
      s = nombre_aff_deletes > 1 ? 's' : ''
      "#{nombre_aff_deletes} affiche#{s} à détruire sur Icare : #{diff_affiches_icare[:delete_on_icare].pretty_join}"
    end
    form << mess.in_p

    # Une case à cocher pour stipuler de synchroniser les affiches
    if (nombre_aff_uploads + nombre_aff_deletes) > 0
      form << "Synchroniser les affiches sur Icare".in_checkbox(name: 'cb_synchronize_affiches', id: 'cb_synchronize_affiches', checked:true).in_p
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

    # Enregistrer les données de synchronisation à faire
    # dans le fichier adéquat, qui sera utilisé si la
    # synchronisation est demandée.
    data_synchronisation= datasync

    c << "Données de synchronisation".in_h3
    c << datasync.pretty_inspect.in_pre

    c << "Données retournées par le check".in_h3
    c << online_sync_state.pretty_inspect.in_pre

    display_path.write(c)
  end


end #/Sync
