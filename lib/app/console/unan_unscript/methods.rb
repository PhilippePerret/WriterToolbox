# encoding: UTF-8
site.require_objet 'unan'
class SiteHtml
class Admin
class Console

  def unan_simule_envoi_rapport ref_user
    if OFFLINE
      return 'Cette commande doit impérativement s’utiliser ONLINE'
    end
    site.require_objet 'unan'
    if ref_user =~ /^(report|rapport)$/
      # Aucun user n'a été spécifié, il faut retourner la liste des
      # auteur suivant le programme
      res =
        Unan.table_programs.select(where: 'options LIKE "1%"').collect do |hprog|
          auteur = User.new(hprog[:auteur_id])
          "#{auteur.pseudo} (##{auteur.id})".in_li
        end.join('').in_ul
      sub_log(res)
      "Aucun auteur spécifié, je retourne la liste des auteurs suivant le programme."
    else
      ref_user =
        if ref_user.numeric?
          # => Par ID
          ref_user.to_i
        else
          # => Par pseudo
          hu = table_user.select(where: "pseudo = '#{ref_user}'").first
          hu != nil || raise("Aucun auteur n'a pu être trouvé avec le pseudo '#{ref_user}'…")
          hu[:id]
        end
      u = User.new(ref_user)
      rapport = u.current_pday.rapport_complet
      sub_log 'Rapport envoyé par mail :'.in_h3 + rapport
      site.send_mail_to_admin(
        subject: 'Simulation envoi rapport à auteur ÉCRIRE UN FILM/ROMAN EN UN AN',
        message: rapport,
        formated: true,
        force_offline: true
      )
      "Mail envoyé aussi dans la boite."
    end
  end

  def unan_build_manuel pour
    # On peut rassembler ici les ERREURS POSSIBLES qui empêchent
    # la compilation du fichier, afin d'en informer l'admin quand
    # on compile le fichier.
    sub_log(<<-HTML)
    <p>Les erreurs pouvant subvenir sont les suivantes :</p>
    <ul>
      <li>Des tirets plats ont été utilisés pour les noms de fichiers d'images ;</li>
      <li>Extensions de fichiers d'image incorrects (je crois que PNG — ou PDF — est le bon format) ;</li>
      <li>De façon générale, peut-être des tirets plats ont-ils été utilisés, il ne faut le faire EN AUCUN CAS.</li>
    </ul>
    HTML
    site.require_gem 'latexbook'
    ibook = LaTexBook::new((site.folder_objet+'unan/aide/manuel/latexbook').to_s)
    versions = case pour
    when "auteurs" # => Home et femme
      [true, false]
    when "auteure"  # => Femme
      [true]
    when "auteur"   # => Homme
      [false]
    end
    versions.each do |version|
      if ibook.build(version_femme: version, open_it: true)
        flash ibook.message
      else
        error ibook.error
      end
    end
    return ""
  end

  # Méthode qui affichage dans le sublog la valeur des points
  # jour après jour dans le programme ÉCRIRE UN FILM/ROMAN EN UN AN
  def unan_affiche_points_sur_lannee
    Unan::require_module 'quiz'
    debug "  Unan::Program::DATA_POINTS: #{  Unan::Program::DATA_POINTS.inspect}"
    total_points_max  = 0  # quand meilleures réponses
    total_points_min  = 0  # quand pires réponses
    total_works_count = 0
    hdata = Hash::new
    lines = ""
    tab = " "*4 # tabulation entre les données pour l'affichage
    grade_points_courant = nil
    (1..365).each do |pday_id|
      iabs_pday = ( Unan::Program::AbsPDay::get pday_id )
      pday_points_max = 0
      pday_points_min = 0
      # Boucle sur tous les works du pday courant
      instances_works = iabs_pday.works(:as_instances)
      pday_works_count = instances_works.count
      total_works_count += pday_works_count
      instances_works.each do |iabswork|

        if iabswork.quiz?
          min, max = ( max_and_min_points_quiz iabswork )
        else
          min = max = 0
        end
        pday_points_max += (iabswork.points || 0) + max
        pday_points_min += (iabswork.points || 0) + min
      end #/Fin de boucle sur tous les travaux

      total_points_max += pday_points_max
      total_points_min += pday_points_min
      hdata.merge!( pday_id => {
        max_jour: pday_points_max,
        min_jour: pday_points_min,
        total_max: total_points_max,
        total_min: total_points_min,
        nombre_works: pday_works_count
        })

      mark_pday = pday_id.to_s.rjust(4)
      mark_pday_max = pday_points_max.to_s.rjust(4)
      mark_pday_min = pday_points_min.to_s.rjust(4)
      mark_total_max = total_points_max.to_s.rjust(6)
      mark_total_min = total_points_min.to_s.rjust(6)
      mark_works_count = pday_works_count.to_s.rjust(3)
      mark_works_total = total_works_count.to_s.rjust(6)

      lines <<  "#{mark_pday}#{tab}#{mark_works_count}#{tab}  #{mark_pday_min}#{tab}#{mark_pday_max}#{tab}#{mark_total_min}#{tab}#{mark_total_max}#{tab}#{mark_works_total}\n"

      # Est-ce que ces points correspondent à un grade supérieur ?
      arr_points = Unan::Program::DATA_POINTS.keys
      index_key = nil
      arr_points.each_with_index do |points, index |
        if points > total_points_max ; index_key = index - 1; break end
      end
      index_key = arr_points.count - 1 if index_key.nil?
      points_sub = arr_points[index_key]
      data_points = Unan::Program::DATA_POINTS[points_sub]
      if grade_points_courant != data_points[:grade]
        lines << "=> passage au grade #{data_points[:hname]}\n"
        grade_points_courant = data_points[:grade].freeze
      end

    end
    line1_titre = "pday #{tab} Nb #{tab}  pts / pday    #{tab}   Total\n"
    line2_titre = "     #{tab}works#{tab}min  |   max  #{tab}min   |   max  |  works\n"
    separator = "-"*(line2_titre.length) + "\n"

    tableau = line1_titre + line2_titre + separator + lines + separator
    sub_log "<pre>\n#{tableau}\n</pre>"
    "OK"
  end


  # Relève le nombre de points maxi engrangés par ce questionnaire
  # et le nombre mini
  # Noter que ce nombre mini est nécessaire parce qu'il peut être
  # négatif, pas seulement zéro
  def max_and_min_points_quiz iabswork#, iwork
    total_min = 0
    total_max = 0
    # Instance du quiz absolu
    iabsquiz = Unan::Quiz::new( iabswork.item_id )
    iabsquiz.questions.each do |iquestion|
      min, max = [1000, 0]
      iquestion.reponses.each do |hreponse|
        max = hreponse[:points] if hreponse[:points] > max
        min = hreponse[:points] if hreponse[:points] < min
      end
      total_min += min
      total_max += max
    end
    return [total_min, total_max]
  end

end #/Console
end #/Admin
end #/SiteHtml
