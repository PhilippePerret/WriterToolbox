# encoding: UTF-8
class UNANProgramme

  # = main =
  #
  # Méthode principale qui permet d'afficher une recherche
  # sur le programme.
  #
  # La recherche est très simple : on passe en revue chaque
  # ligne en conservant seulement celles qui correspondent à
  # la recherche.
  #
  # C'est `filtre_search` qui permet de définir la recherche
  #
  def search

    c = String.new
    line_number   = nil


    current_pday_i = 0

    # current_pday_i  = 1000

    # Sera mis à true si la ligne-jour courante correspond
    # à la recherche.
    last_line_jour_is_ok = false

    # L'indice du jour-programme courant si on est en
    # "échelle réelle" c'est-à-dire où chaque ligne correspond
    # à un jour-programme.
    current_jour_programme = 0

    last_current_pday = nil

    raw_code.split("\n").each_with_index do |line, index|

      line_number = index + 1

      line_stripped = line.strip

      line_stripped != '' || next

      # La ligne est-elle une "ligne-jour" ?
      is_line_jour      = line_stripped.start_with?('JP ')
      is_not_line_jour  = !is_line_jour

      if is_line_jour
        current_pday_i  = line_stripped[3..5].to_i
        current_pday    = current_pday_i.to_s.rjust(3)
      end

      # Si on est en échelle réelle
      if real_scale?
      # Et le jour courant est supérieur au dernier jour
      # programme
      if current_pday_i > current_jour_programme
      # alors il faut ajouter autant de lignes
        diff = current_pday_i - current_jour_programme - 1
        diff.times do
          c << "JP #{(current_jour_programme += 1).to_s.rjust(3)}\n"
        end
      end
      end

      # La ligne correspond-elle aux critères de recherche.
      # Oui, si elle correspond à la recherche
      # Oui, si ce n'est pas une « ligne-jour » et que la
      # ligne-jour précédente correspondait à la recherche. En
      # d'autres termes, si la ligne-jour précédente correspond
      # aux critères de la recherche, tous ces éléments correspondent
      # à la recherche (sauf si ce sont des lignes-jour qui ne
      # correspondent pas)
      line_ok =
        filtre_search.call(line_stripped) ||
        (is_not_line_jour && last_line_jour_is_ok)

      if is_line_jour
        last_line_jour_is_ok = true && line_ok
      end

      if line_ok
        # La ligne correspond aux critères de recherche
        # Le lien pour afficher la ligne dans le fichier PROGRAMME_MAP.TXT
        lnum_linked = "#{line_number}".rjust(3)
        lnum_linked = "→o".in_a(href: "atm://open?url=file://#{programme_map_file.expanded_path}&line=#{line_number}", target: :new)
        entete =
          if last_current_pday == current_pday_i
            '      '
          else
            "JP #{current_pday}"
          end
        c << "#{entete} #{lnum_linked} #{line.sub(/^    /,'')}\n"

        current_jour_programme = current_pday_i

      else
        # c << "#{line_number}"
      end


      last_current_pday = current_pday_i

    end

    return "<pre style='font-size:10.2pt'>\n#{c}\n</pre>"
  end

  def real_scale?
    @with_real_scale ||= param(:real_scale) == 'on'
  end

  def filtre_search
    @filtre_search ||= begin
      find_string = param(:find).nil_if_empty
      notfind_string = param(:notfind).nil_if_empty
      code_search = Array.new
      find_string == nil || begin
        code_search << "line.match(/#{find_string}/i) != nil"
      end
      notfind_string == nil || begin
        code_search << "line.match(/#{notfind_string}/i).nil?"
      end
      code_search = code_search.join(' && ')
      debug "code search : #{code_search.inspect}"
      Proc.new { |line| eval(code_search) }
    end
  end

  # ---------------------------------------------------------------------
  #   Helper méthodes
  # ---------------------------------------------------------------------

  def formulaire_search
    <<-HTML
<form
  method="POST"
  action="unan_admin/programme"
  style="width:326px;padding:1em;border:1px solid #ccc;margin-left:40em">
  <input type="hidden" name="operation" value="search">
  <div>Inclure <input type="text" name="find" value="#{param(:find)}"></div>
  <div>Exclure <input type="text" name="notfind" value="#{param(:notfind)}"></div>
  <div class="right"><input type="submit" value="FILTRER"></div>
  <div>
    <input type="checkbox" id="cb_real_scale" name="real_scale" #{real_scale? ? 'CHECKED' : ''}>
    <label for="cb_real_scale">Échelle réelle</label>
  </div>
</form>
    HTML
  end

end #/UNANProgramme
