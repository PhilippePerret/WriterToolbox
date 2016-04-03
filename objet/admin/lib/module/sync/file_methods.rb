# encoding: UTF-8
=begin
Class Sync::File
-----------------
Gestion d'un fichier à synchroniser

=end
class Sync
class Fichier

  attr_reader :data

  # +data+
  #   :fpath        {String} Path relatif (entier) du fichier en local
  #   :loc_mtime    {Fixnum} mtime du fichier local
  #   :boa_mtime    {Fixnum} mtime du fichier sur la boite à outils
  #   :ica_mtime    {Fixnum} mtime du fichier sur l'atelier Icare
  def initialize data
    @data = data
  end

  # ---------------------------------------------------------------------
  #   Données
  # ---------------------------------------------------------------------
  def id
    @id ||= data[:id]
  end
  def name
    @hname ||= data[:hname]
  end
  def local_path
    @local_path ||= data[:fpath]
  end
  def loc_mtime
    @loc_mtime ||= data[:loc_mtime]
  end
  def boa_mtime
    @boa_mtime ||= data[:boa_mtime]
  end
  def ica_mtime
    @ica_mtime ||= data[:ica_mtime]
  end

  # ---------------------------------------------------------------------
  #   Data volatile
  # ---------------------------------------------------------------------


  # ---------------------------------------------------------------------
  #   CHECK METHODS
  # ---------------------------------------------------------------------

  def synchronized?
    @is_synchronized ||= synchro_on_boa? && ( icare? == synchro_on_icare? )
  end
  def synchro_on_boa?
    loc_mtime == boa_mtime
  end
  def synchro_on_icare?
    loc_mtime == ica_mtime
  end

  # Retourne la donnée synchronisation à enregistrer pour ce
  # fichier
  def data_synchro
    @data_synchro ||= begin
      # Si le ou les 2 fichiers sont synchronisés, il n'y a rien à
      # faire pour ce fichier synchronisable.
      if synchronized?
        nil
      else
        d = Hash::new
        if boa_mtime
          if loc_mtime > boa_mtime
            d.merge!(upate_on_boa: true)
          elsif boa_mtime > loc_mtime
            d.merge!(upate_on_local: true)
          end
        else
          # Le fichier boa n'existe pas, il faut l'actualiser
          d.merge!(upate_on_boa: true)
        end
        if icare?
          if ica_mtime
            if [loc_mtime, boa_mtime].max > ica_mtime
              d.merge!(update_on_icare: true)
            end
          else
            d.merge!(update_on_icare: true)
          end
        end
        d
      end
    end
  end

  # ---------------------------------------------------------------------
  #   HELPERS METHODS
  # ---------------------------------------------------------------------
  NAME_WIDTH = 22

  # = main =
  #
  # Méthode principale retournant le code HTML à écrire dans la
  # page pour signaler l'état de synchronisation du fichier
  def output
    (
      main_voyant_synchro +
      " | " +
      checkbox_synchro +
      " | " +
      span_name +
      " | " +
      voyant_synchro_local +
      span_loc_mtime +
      span_diff_if_loc_plus_vieux +
      " | " +
      voyant_synchro_boa +
      span_boa_mtime +
      span_diff_if_boa_plus_vieux +
      " | " +
      voyant_synchro_icare +
      span_ica_mtime +
      span_diff_if_ica_plus_vieux +
      " | "
    ).in_div(class:'file')
  end

  # ---------------------------------------------------------------------
  #   Méthodes d'helper
  # ---------------------------------------------------------------------
  def span_name
    name.ljust(NAME_WIDTH)
  end
  def span_loc_mtime
    span_mtime loc_mtime
  end
  def span_boa_mtime
    span_mtime boa_mtime
  end
  def span_ica_mtime
    span_mtime ica_mtime
  end

  def checkbox_synchro
    cb_id = "cb_synchronize_#{id}"
    "".in_checkbox(name: cb_id, id: cb_id, checked: !(synchro_on_boa? && synchro_on_icare?))
  end

  def span_diff_if_loc_plus_vieux
    diff = if boa_mtime && (loc_mtime < boa_mtime)
      boa_mtime - loc_mtime
    elsif ica_mtime && (loc_mtime < ica_mtime)
      ica_mtime - loc_mtime
    else nil end
    span_diff diff
  end
  def span_diff_if_boa_plus_vieux
    diff = if boa_mtime && (boa_mtime < loc_mtime)
      loc_mtime - boa_mtime
    else nil end
    span_diff diff
  end
  def span_diff_if_ica_plus_vieux
    diff = if ica_mtime && (ica_mtime < loc_mtime)
      loc_mtime - ica_mtime
    else nil end
    span_diff diff
  end

  def span_diff diff
    (diff.nil? ? "" : "-#{duree_of diff}").ljust(10).in_span(class: (diff.nil? ? nil : 'warning') ) + "  "
  end

  def span_mtime t
    (t.nil? ? "" : Time.at(t).strftime("%d%m%y-%H:%M")).ljust(14)
  end
  def duree_of t
    t.as_duree(usec:'', umin:':', uhour:':', ujour:nil)
  end

  # LES VOYANTS
  def main_voyant_synchro
    voyant_synchro( synchro_on_boa? && synchro_on_icare? )
  end
  def voyant_synchro_local
    # Le voyant est rouge si la date du fichier local
    # est inférieure à la date du fichier distant
    voyant_synchro !( boa_mtime && loc_mtime < boa_mtime )
  end
  def voyant_synchro_boa
    # Le voyant est rouge si le fichier boa n'existe pas
    # ou si le fichier boa est inférieur en date au fichier
    # local
    voyant_synchro( !( boa_mtime && boa_mtime < loc_mtime) )
  end
  def voyant_synchro_icare
    if icare?
      voyant_synchro( !( ica_mtime && (ica_mtime < loc_mtime || ica_mtime < boa_mtime) ) )
    else
      voyant_synchro nil
    end
  end
  def voyant_synchro synchronized
    couleur = case synchronized
    when true   then 'vert'
    when false  then 'rouge'
    when nil    then 'none'
    end
    image_name = "rond-#{couleur}.png"
    image_path = File.join('.', 'view', 'img', 'divers', image_name)
    "<img src='#{image_path}' class='voyant_synchro' />"
  end


  def icare?
    @existe_sur_icare ||= data[:icare] == true
  end

end #/File
end #/Sync
