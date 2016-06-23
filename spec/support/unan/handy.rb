# encoding: UTF-8

# Prépare un auteur pour le programme UN AN UN SCRIPT
#
# +options+
#
#   :pday         Le jour-programme dans lequel doit se trouver l'auteur
#   :done_upto    Tous les travaux jusqu'à ce jour-programme doivent
#                 être marqué terminés.
#
def prepare_auteur options = nil
  options ||= {}

  options.key?(:pday)       || options[:pday] = 10
  options.key?(:done_upto)  || options[:done_upto] = 4

  done_upto = options[:done_upto]

  # On prend un auteur
  @hprog        = site.dbm_table(:unan, 'programs').select.first
  @hprog != nil || raise('Il faut créer un auteur pour le programme UN AN UN SCRIPT')
  @program_id   = @hprog[:id]
  @auteur_id    = @hprog[:auteur_id]

  puts "@auteur_id : #{@auteur_id}"
  @auteur_id != nil || raise('Aucun auteur n’a pu être trouvé…')

  @up = User.new(@auteur_id)

  # On va augmenter le current_pday de l'auteur pour qu'il
  # ait des travaux qui posent problème :
  #   - des travaux non démarrés
  #     (pour faire la différence avec les travaux du jour)
  #   - des travaux qui auraient dû être achevés
  #

  # On passe au dixième jour de programme
  @up.program.current_pday = options[:pday] # définit aussi current_pday_start
  @up.program.set(created_at: NOW - options[:pday].days)

  # On commence par détruire tous ses travaux
  @up.table_works.destroy
  @up.table_works.create

  # Il faut marquer quelques travaux achevé
  # Pour ce faire, on doit récupérer des travaux absolus dans les
  # premiers jours et créer des instances correspondantes dans la
  # table des works de l'auteur.
  some_aworks = []
  Unan.table_absolute_pdays.select(where: "id < #{done_upto}", colonnes: [:works]).each do |hd|
    next if hd[:works].nil?
    some_aworks += hd[:works].split(' ').collect do |id|
      hw = Unan.table_absolute_works.get(id.to_i)
      {
        id:       id.to_i,
        pday:     hd[:id],
        points:   hw[:points],
        options:  "#{hw[:type_w]}"
      }
    end
  end
  # Tous les travaux non achevés sont à partir du 4e jour
  # On va en démarrer certains et en laisser d'autres
  # Note : tous les travaux d'identifiant pair sont démarrés,
  # les autres sont laissés tels quels.
  @aworks_started     = []
  @aworks_not_started = []
  Unan.table_absolute_pdays.select(where: "id >= 4 AND id <= #{options[:pday]}").each do |hd|
    next if hd[:works].nil?
    hd[:works].split(' ').each do |id|
      id = id.to_i
      hw = Unan.table_absolute_works.get(id)
      dw = {id: id, duree: hw[:duree], pday: hd[:id], options: "#{hw[:type_w]}"}
      if id % 2 == 0
        @aworks_started << dw
      else
        @aworks_not_started << dw
      end
    end
  end

  # On crée des travaux démarrés
  @aworks_started.each do |haw|
    dtime = NOW - (options[:pday] - haw[:pday]).days
    duwork = {
      program_id:     @program_id,
      abs_work_id:    haw[:id],
      abs_pday:       haw[:pday],
      status:         1,
      options:        haw[:options],
      created_at:     dtime,
      updated_at:     dtime,
      ended_at:       nil,
      points:         0
    }
    @up.table_works.insert(duwork)
  end

  # Le reste, ce seront des travaux non-démarrés

  # On crée le travaux finis
  some_aworks.each do |haw|
    dtime = NOW - (done_upto - haw[:pday]).days
    data_uwork = {
      program_id:   @program_id,
      abs_work_id:  haw[:id],
      abs_pday:     haw[:pday],
      status:       9,
      options:      haw[:options],
      created_at:   dtime,
      updated_at:   dtime,
      ended_at:     dtime + 1.day,
      points:       haw[:points]
    }
    @up.table_works.insert(data_uwork)
  end

  # Pour voir
  # puts "Works marqués finis pour l'user :"
  # puts @up.table_works.select.pretty_inspect

end
