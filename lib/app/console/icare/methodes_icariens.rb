# encoding: UTF-8
class SiteHtml
class Admin
class Console

  def set_icarien line
    tout, ref_icarien, action = line.match(/^set icarien (.*?) (inactif|actif|on|off)$/i).to_a
    valeur_bit, new_etat =
      case action
      when 'actif', 'on'
        ['2', 'actif']
      when 'inactif', 'off'
        ['1', 'inactif']
      end
    where_clause, de_prop =
      if ref_icarien.numeric?
        [{id: ref_icarien.to_i}, 'd’identifiant']
      else
        [{pseudo: ref_icarien}, 'de pseudo']
      end
    # Il faut toujours faire l'opération ONLINE
    table = site.dbm_table(:hot, 'users', online = true)
    duser = table.get(where: where_clause, colonnes: [:options, :pseudo])

    if duser.nil?
      error "L'icarien #{de_prop} `#{ref_icarien}` est introuvable."
    else
      opts = duser[:options]
      opts = opts.split('') # Car il n'y en a peut-être pas 32
      bit31 = opts[31]
      if bit31 == valeur_bit
        error "l'icarien #{duser[:pseudo]} (#{duser[:id]}) est déjà dans l'état #{new_etat} sur le site distant."
      else
        opts[31] = valeur_bit
        opts = opts.collect{|e| e || 0}.join('')
        table.update(duser[:id], options: opts)
        flash "Icarien #{duser[:pseudo]} (#{duser[:id]}) a été mis à l'état #{new_etat} sur le site distant."
      end
    end

    return ''
  end

end #/Console
end #/Admin
end #/SiteHtml
