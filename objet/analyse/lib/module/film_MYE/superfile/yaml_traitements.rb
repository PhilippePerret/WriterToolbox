# encoding: UTF-8
class SuperFile

  # Traitement en fonction du fichier YAML
  # On cherche d'abord une méthode qui porterait le nom
  # "traite_content_as_<affixe fichier>" par exemple
  # "traite_content_as_notes" pour le fichier notes.ymal et
  # si la méthode n'existe pas on traite la donnée avec la
  # méthode générale `traite_content_as_list_of_things`
  def as_yaml
    methode = "traite_content_as_#{affixe}".to_sym
    if respond_to? methode
      send(methode)
    else
      # Traitement comme une liste de choses, par exemple comme une
      # liste d'ironies dramatiques ou de préparations-paiements
      traite_content_as_list_of_things
    end.formate_balises_propres
  end

  # ---------------------------------------------------------------------
  #   Méthodes génériques utilisées par toutes les autres
  #   méthodes
  # ---------------------------------------------------------------------

  KEY_SYM_TO_HUMAN = {
    cdv:                    "Clé de voûte",
    contre_objectif:        "Contre-objectif",
    denouement:             "Dénouement",
    idees:                  "Idées",
    incdec:                 "Incident déclencheur",
    incper:                 "Incident perturbateur",
    intensite:              "Intensité",
    memo:                   "Mémo",
    originalite:            "Originalité",
    preparation_paiement:   "Préparation/paiement",
    procedes:               "Procédés",
    reponse:                "Réponse",
    running_gag:            "Running-gag",
    themes:                 "Thèmes"

  }
  # Méthode qui retourne le nom humain pour une clé symbole.
  # Elle reçoit par exemple :incdec et retourne "Incident déclencheur"
  def key_sym_to_human k
    # return k.to_s  # Pour correction
    if KEY_SYM_TO_HUMAN.has_key? k
      KEY_SYM_TO_HUMAN[k]
    else
      k.to_s.gsub(/_/,' ').capitalize
    end
  end

  # Reçoit un Array définissant des relatifs et retourne un texte
  # humain pour les voir.
  # +arr_rels+ Array de Hash contenant :type et :id
  # :type peut être :qrd, :objectif, :note etc. et :id est l'identifiant
  # de l'élément en relation.
  # TODO Pour le moment, pas d'interactivité, on indique simplement
  # la nature de l'élément et son identifiant
  def traite_relatifs arr_rels
    return "---" if arr_rels.nil? || arr_rels.empty?
    arr_rels.collect do |hrel|
      (
        case hrel[:type]
        when :qrd  then "Question & réponse dramatique"
        else hrel[:type].to_s.capitalize
        end + " ##{hrel[:id]}"
      ) # .in_a(href:"##{hrel[:type]}-#{hrel[:id]}")
    end.pretty_join
  end

  def traite_hash_value hvalue
    hvalue.collect do |lib, value|
      traite_any_value lib, value
    end.compact.join.in_div
  end

  def traite_array_value arr_value
    arr_value.collect do |value|
      traite_any_value nil, value
    end.compact.join.in_div
  end

  def traite_any_value lib, value
    return nil if lib == :id
    case value
    when String, Fixnum, Float
      libnval(lib, value.to_s)
    when Hash
      traite_hash_value value
    when Array
      traite_array_value value
    end
  end

  # Traite le contenu YAML comme une liste de choses
  # Par exemple une liste de commentaires.
  # Les "listes de choses" sont des Hash dont la clé est un ID numérique
  # et la valeur un Hash où on prendra la clé pour faire le libellé et la
  # valeur pour faire… la valeur.
  def traite_content_as_list_of_things
    traite_hash_value yaml_content

    yaml_content.collect do |key, hvalue|
      hvalue.collect do |lib, val|
        next nil if lib == :id
        lib = case lib
        when :titre then "Intitulé"
        when :texte then "Description"
        else key_sym_to_human(lib)
        end
        libnval(lib, val.to_s)
      end.compact.join.in_div
    end.join
  end

  # Traitement d'un fichier YAML contenant une liste de
  # procédés.
  def traite_hash_in_liste_definition hvalue
    hvalue.collect do |lib, value|
      key_sym_to_human(lib).in_dt + (case value
      when String, Fixnum
        value.to_s
      when Hash
        traite_hash_in_liste_definition value
      when Array
        value.pretty_join
      else
        value.inspect
      end.in_dd)
    end.join.in_dl
  end

  # ---------------------------------------------------------------------
  #   Traitement par type de fichier
  # ---------------------------------------------------------------------

  def traite_content_as_qrds
    yaml_content.collect do |qid, qdata|
      debug "qdata: #{qdata.pretty_inspect}"
      "##{qid} #{qdata[:question]}".in_dt +
      (
        libnval("Réponse", qdata[:reponse]) +
        libnval("Description", qdata[:description]) +
        libnval("Relatifs", traite_relatifs(qdata[:relatifs]))
      )
    end.join.in_dl
  end
  def traite_content_as_notes
    traite_hash_in_liste_definition yaml_content
  end

  def traite_content_as_procedes
    traite_hash_in_liste_definition yaml_content
  end

  # Traitement d'un fichier YAML contenant une liste des
  # thèmes
  def traite_content_as_themes
    yaml_content.collect do |key, hvalue|
      htheme = case hvalue[:nature_theme]
      when :concret   then "concret"
      when :abstrait  then "abstrait"
      when :both      then "abstrait et concret"
      end

      "<a name='theme-#{key}'></a>" +
      "#{hvalue[:libelle]}".in_dt +
      "Thème #{htheme}".in_dd
    end.join.in_dl
  end

  # Traitement d'un fichier YAML contenant la description des
  # personnages du film
  def traite_content_as_personnages
    yaml_content.collect do |key, hvalue|

      fonction = case hvalue[:fct_perso]
      when "prota"  then "Protagoniste"
      when "anta"   then "Antagoniste"
      else nil
      end

      "<a name='personnage-#{key}'></a>" +
      ( hvalue[:pseudo] || hvalue[:nom] ).in_dt +
      (
        libnval("Nom",      ("#{hvalue[:prenom]} #{hvalue[:nom]}").nil_if_empty) +
        libnval("Fonction", fonction) +
        description_of(hvalue) +
        facteur_u_of(hvalue)   +
        facteur_o_of(hvalue)   +
        libnval("Rôle",     hvalue[:role])
      ).in_dd
    end.join.in_dl
  end

  # Traitement du contenu dans c'est un fichier YAML contenant
  # des commentaires
  def traite_content_as_commentaires
    traite_hash_in_liste_definition yaml_content
    # yaml_content.collect do |key, hvalue|
    #   ( hvalue[:titre].in_dt + hvalue[:texte].in_dd )
    # end.join.in_dl
  end

  PROPERTIES_PP_TRAITED = [
    :id,
    :libelle, :description,
    :installation, :exploitation, :resolution,
    :scenes
  ]
  def traite_content_as_preparations_paiments
    explication_pp.in_p(class:'small italic') +
    yaml_content.collect do |key, hvalue|
      # debug "hvalue PP : #{hvalue.inspect}"
      if user.admin? && @properties_irdr_traited.nil?
        hcheck = hvalue.dup
        PROPERTIES_PP_TRAITED.each do |prop|
          hcheck.delete(prop)
        end
        error "Les propriétés #{hcheck.keys.join(', ')} ne sont pas traitées dans les préparations/paiements. #{lien.edit_file(__FILE__, titre:'Ouvrir ce fichier', line:__LINE__)} pour ajouter leur traitement" unless hcheck.empty?
        @properties_irdr_traited = true
      end
      <<-HTML
<a name="pp-#{key}"></a>
<dt>##{key} #{hvalue[:libelle]}</dt>
<dd>
  #{description_of  hvalue}
  #{installation_of hvalue}
  #{exploitation_of hvalue}
  #{resolution_of   hvalue}
  #{scenes_of       hvalue}
</dd>
      HTML
    end.join.in_dl
  end
  def explication_pp
    @explication_pp ||= <<-HTML
Notez que cette liste n'est pas nécessairement exhaustive et que de nombreuses autres préparations/paiements pourraient être trouvés dans le récit.
    HTML
  end

  # Pour vérifier que toutes les propriétés soient bien
  # traitées par la méthode, en attendant d'avoir passé en
  # revue tous les fichiers
  PROPERTIES_IRDR_TRAITED = [
    :id,
    :libelle, :description,
    :installation, :exploitation, :resolution,
    :auteur, :victime, :produit
  ]
  def traite_content_as_ironies_dramatiques
    explication_ironies_dramatiques.in_p(class:'small italic') +
    yaml_content.collect do |key, hvalue|
      if user.admin? && @properties_irdr_traited.nil?
        hcheck = hvalue.dup
        PROPERTIES_IRDR_TRAITED.each do |prop|
          hcheck.delete(prop)
        end
        error "Les propriétés #{hcheck.keys.join(', ')} ne sont pas traitées dans les ironies dramatiques. #{lien.edit_file(__FILE__, titre:'Ouvrir ce fichier', line:__LINE__)} pour ajouter leur traitement" unless hcheck.empty?
        @properties_irdr_traited = true
      end
      <<-HTML
<a name="ironie_dramatique-#{key}"></a>
<dt>##{key} #{hvalue[:libelle]}</dt>
<dd>
  #{description_of  hvalue}
  #{installation_of hvalue}
  #{exploitation_of hvalue}
  #{resolution_of   hvalue}
  #{libnval("Auteur",   hvalue[:auteur])}
  #{libnval("Victime",  hvalue[:victime])}
  #{libnval("Produit", hvalue[:produit] || "- non défini -")}
</dd>
      HTML
    end.join.in_dl
  end
  def explication_ironies_dramatiques
    @explication_ironies_dramatiques ||= <<-HTML
Trouvez ci-dessous une liste des MOT[19|ironies dramatiques] relevées dans le film. Notez que cette liste n'est pas nécessairement exhaustive.
    HTML
  end


  # Traitement du fichier yaml structure.yaml contenant la
  # définition de la structure du film
  PROPERTIES_STT = [:description, :explication, :time, :notes]
  def traite_content_as_structure
    dstt = yaml_content
    dstt_checked = dstt.dup # Pour voir s'il y a des propriétés supplémentaires

    decoupe = dstt.delete(:decoupe)
    dstt_checked.delete(:decoupe)
    "Découpe en #{decoupe} parties"
    incident_declencheur = dstt[:incdec]

    stt = ""

    {
      incper:     {hname:"Incident perturbateur"},
      incdec:     {hname:"Incident déclencheur"},
      un5ie:      {hname:"1 / 5<sup>e</sup>"},
      tiers:      {hname:"1 / 3"},
      deux5ie:    {hname:"2 / 5<sup>e</sup>"},
      cdv:        {hname:"Clé de voûte"},
      trois5ie:   {hname:"3 / 5<sup>e</sup>"},
      deuxtiers:  {hname:"2 / 3"},
      quatre5ie:  {hname:"4 / 5<sup>e</sup>"},
      crise:      {hname:"Crise"},
      climax:     {hname:"Climax"}
    }.each do |kpart, dpart|

      # Définition dans la structure
      sdpart = dstt[kpart]
      next if sdpart.nil?
      dstt_checked.delete(kpart)

      horloge = case sdpart[:time]
      when String then sdpart[:time]
      when Fixnum then sdpart[:time].as_horloge
      else nil
      end

      stt << dpart[:hname].in_dt
      stt << "<dd>"
      stt << libnval( "à", horloge ) unless horloge.nil?
      stt << libnval( "Description", dstt[kpart][:description] )
      stt << libnval( "Explication", dstt[kpart][:explication] )
      stt << libnval( "Notes",       dstt[kpart][:notes] )
      stt << "</dd>"

    end # / boucle sur chaque partie/scène-clé


    if user.admin? && false == dstt_checked.empty?

    end

    stt = stt.in_dl

    return stt
  end

  def libelle_and_value libelle, value
    return "" if value.to_s == ""
    (
      libelle.to_s.in_span(class:'libelle') +
      value.in_span(class:'value')
    ).in_div(class:'row')
  end
  alias :libnval :libelle_and_value

  def description_of h
    libnval( "Description", h[:description] )
  end
  def intitule_of h
    libnval("Intitulé", h[:intitule])
  end
  def installation_of h
    libnval("Installation", h[:installation])
  end
  def exploitation_of h
    libnval("Exploitation", h[:exploitation])
  end
  def resolution_of h
    libnval("Résolution", h[:resolution])
  end
  def facteur_u_of h
    libnval("Facteur U", h[:facteurU] || h[:facteur_u])
  end
  def facteur_o_of h
    libnval("Facteur O", h[:facteurO] || h[:facteur_o])
  end
  def scenes_of h
    return "" if h[:scenes].to_s == ""
    scenes = h[:scenes].split(' ').collect { |sid| sid.to_i }
    onclick = "$.proxy(Timeline,'show_scenes', '#{scenes.join(', ')}')()"
    lien_scenes = scenes.join(', ').in_a(onclick: onclick)
    libnval( "Scènes", lien_scenes )
  end


  def dsection_fond1
    fd1 = yaml_content[:personnage_fondamental]
    return "Pas de première Fondamentale définie.".in_p(class:'italic') if fd1.nil? || fd1.empty?
    patronyme = "#{fd1[:prenom]} #{fd1[:nom]}".strip
    <<-HTML
<dt>Personnage Fondamental (Fd. 1)</dt>
<dd>
  #{libnval("Nom", patronyme)}
  #{description_of(fd1)}
  #{libnval("Atouts", fd1[:atouts] )}
  #{libnval("Handicaps", fd1[:handicaps])}
  #{facteur_u_of(fd1)}
  #{facteur_o_of(fd1)}
</dd>
    HTML
  end
  def dsection_fond2
    fd2 = yaml_content[:question_fondamentale]
    return "Pas de deuxième Fondamentale définie.".in_p(class:'italic') if fd2.nil? || fd2.empty?
    <<-HTML
<dt>Question Dramatique Fondamentale (Fd. 2)</dt>
<dd>
  #{intitule_of(fd2)}
  #{description_of(fd2)}
  #{facteur_u_of(fd2)}
  #{facteur_o_of(fd2)}
</dd>
    HTML
  end
  def dsection_fond3
    fd3 = yaml_content[:opposition_fondamentale]
    return "Pas de troisième Fondamentale définie.".in_p(class:'italic') if fd3.nil? || fd3.empty?
    <<-HTML
<dt>Opposition Fondamentale (Fd. 3)</dt>
<dd>
  #{intitule_of(fd3)}
  #{description_of(fd3)}
  #{facteur_u_of(fd3)}
  #{facteur_o_of(fd3)}
</dd>
    HTML
  end
  def dsection_fond4
    fd4 = yaml_content[:reponse_fondamentale]
    return "Pas de quatrième Fondamentale définie.".in_p(class:'italic') if fd4.nil? || fd4.empty?
    <<-HTML
<dt>Réponse Dramatique Fondamentale (Fd. 4)</dt>
<dd>
  #{intitule_of(fd4)}
  #{description_of(fd4)}
  #{facteur_u_of(fd4)}
  #{facteur_o_of(fd4)}
</dd>
    HTML
  end
  def dsection_fond5
    fd5 = yaml_content[:concept_fondamental]
    return "Pas de cinquième Fondamentale définie.".in_p(class:'italic') if fd5.nil? || fd5.empty?
    <<-HTML
<dt>Concept Fondamental (Fd. 5)</dt>
<dd>
  #{intitule_of(fd5)}
  #{description_of(fd5)}
  #{facteur_u_of(fd5)}
  #{facteur_o_of(fd5)}
</dd>
    HTML
  end

  def traite_content_as_fondamentales
    <<-HTML
<dl>
  #{dsection_fond1}
  #{dsection_fond2}
  #{dsection_fond3}
  #{dsection_fond4}
  #{dsection_fond5}
</dl>
    HTML
  end

  NATURE_OBJECTIF = {
    'cc'  => "Concret",
    'ab'  => "Abstrait"
  }
  CATEGORIE_OBJECTIF = {
    'objf'  => "Objectif fondamental",
    'objv'  => "Objectif de vie",
    'sobj'  => "Sous-objectif",
    'objl'  => "Objectif local"
  }

  def traite_content_as_dynamique
    yaml_content.collect do |dynid, dyndata|
      debug dyndata.inspect
      (
        "Objectif ##{dynid} : #{dyndata[:libelle]}".in_dt +
        (
          libnval("Description", dyndata[:description]) +
          libnval("Catégorie", CATEGORIE_OBJECTIF[dyndata[:obj_categorie]]) +
          libnval("Nature", NATURE_OBJECTIF[dyndata[:obj_nature]])+
          libnval("Relatifs", traite_relatifs(dyndata[:relatifs]))
        ).in_dd
      ).in_dl
    end.join
  end

end #/SuperFile
