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
      # flash "-> #{methode}"
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
    cdv:                    'Clé de voûte',
    categorie:              'Catégorie',
    contre_objectif:        'Contre-objectif',
    denouement:             'Dénouement',
    idees:                  'Idées',
    incdec:                 'Incident déclencheur',
    incper:                 'Incident perturbateur',
    pivot1:                 'Premier pivot',
    intensite:              'Intensité',
    memo:                   'Mémo',
    originalite:            'Originalité',
    preparation_paiement:   'Préparation/paiement',
    procedes:               'Procédés',
    reponse:                'Réponse',
    running_gag:            'Running-gag',
    themes:                 'Thèmes'

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
  # la nature de l'élément et son identifiant, mais on ne peut pas
  # le rejoindre dans la page
  def traite_relatifs arr_rels
    return "" if arr_rels.nil? || arr_rels.empty?
    l = arr_rels.collect do |hrel|
      (
        case hrel[:type]
        when :qrd  then "Question & réponse dramatique"
        else hrel[:type].to_s.capitalize
        end + " ##{hrel[:id]}"
      ) # .in_a(href:"##{hrel[:type]}-#{hrel[:id]}")
    end.pretty_join
    libnval("Relatifs", l)
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

  # Parfois, la donnée est un array alors qu'il faudrait que ce
  # soit un Hash. On corrige l'erreur en la signalant
  def convert_array_to_hash arr
    h = {
      titre:        "ÉLÉMENT NON DÉFINI #{1}",
      description:  arr.first
    }
    return 1, h
  end


  # ---------------------------------------------------------------------
  #   Traitement par type de fichier
  # ---------------------------------------------------------------------

  def traite_content_as_procedes
    debug "yaml_content: #{yaml_content.inspect}"
    explication_procedes +
    yaml_content.collect do |pid, pdata|
      if pdata.instance_of?(Array)
          nid, pdata = convert_array_to_hash(pdata)
          error "Problème de formatage avec le fichier #{self.to_s}"
        end
      idpid = "PROC ##{pid}".in_div(class:'fright tiny italic')
      "#{idpid}#{pdata[:titre]||pdata[:libelle]}".in_dt +
      (
        categorie_of(pdata, :famille)   +
        description_of(pdata) +
        explication_of(pdata) +
        produit_of(pdata)     +
        traite_relatifs(pdata[:relatifs])
      ).in_dd
    end.join.in_dl
  rescue Exception => e
    debug e
    debug aide_formatage_procedes
    error "# ERREUR EN FORMATANT LE DOCUMENT YAML PROCÉDÉS : #{e.message} (voir en débug l'erreur et le formatage attendu)"
  end

  def aide_formatage_procedes
    <<-HTML

AIDE FORMATAGE DOCUMENT PROCÉDÉS

:id:
  :titre:         Le titre du procédé     [MANDATORY]
  :categorie:     La catégorie du procédé [MANDATORY]
  :description:   Description du procédé  [MANDATORY]
  :explication:   Explication du procédé
  :produit:       L'effet ou les effets produits
  :relatifs:      Liste de relatifs, if any

    HTML
  end

  def explication_procedes
    ""
  end

  def traite_content_as_qrds
    explication_questions_reponses_dramatiques +
    yaml_content.collect do |qid, qdata|
      idqid = "QRD ##{qid}".in_div(class:'fright tiny italic')
      "#{idqid}#{qdata[:question]}".in_dt +
      (
        reponse_of(qdata) +
        description_of(qdata) +
        traite_relatifs(qdata[:relatifs])
      ).in_dd
    end.join.in_dl
  end
  def explication_questions_reponses_dramatiques
    "Quelques questions et réponses dramatiques tirées du film (ce n'est pas, sauf indication contraire, une liste exhaustive)".in_div(class:'italic small discret')
  end
  def traite_content_as_notes
    yaml_content.collect do |nid, ndata|
      # debug "(#{nid}) ndata : #{ndata.inspect}"
      if ndata.instance_of?(Array)
        nid, ndata = convert_array_to_hash(ndata)
        error "Problème de formatage avec le fichier #{self.to_s}"
      end
      debug "ndata : #{ndata.inspect}"
      idnote = "Note ##{nid}".in_div(class:'fright tiny italic')
      "#{idnote}#{ndata[:titre]}".in_dt +
      (
        intitule_of(ndata)      +
        description_of(ndata)   +
        notes_of(ndata)         +
        traite_relatifs( ndata[:relatifs] )
      ).in_dd
    end.join.in_dl
  end

  # Traitement d'un fichier YAML contenant une liste des
  # thèmes
  def traite_content_as_themes
    yaml_content.collect do |key, hvalue|
      htheme =
        case hvalue[:nature_theme]
        when :concret   then 'concret'
        when :abstrait  then 'abstrait'
        when :both      then 'abstrait et concret'
        else                 'de nature inconnue'
        end
      description = hvalue[:description]

      "<a name='theme-#{key}'></a>" +
      "#{hvalue[:libelle]}".in_dt +
      (description ? description.in_dd : '') +
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
    presentation_liste_commentaires +
    yaml_content.collect do |key, hvalue|
      hid = "Commentaires ##{key}".in_div(class:'fright italic tiny')
      ( ("#{hid}#{hvalue[:titre]}").in_dt + hvalue[:texte].in_dd )
    end.join.in_dl
  end
  def presentation_liste_commentaires
    @presentation_liste_commentaires ||= begin
      <<-HTML
<div class='italic discret small'>Les commentaires suivants sont comme des notes prises rapidement au cours de la vision d'un film. Ils ne sont pas développés et s'intègrent parfois à une discussion plus générale. Ce sont en quelque sorte de simples “points à noter” qui peuvent être repris dans des fiches de commentaires textuels.</div>
      HTML
    end
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
      ppid = "P/P ##{key}".in_div(class:'fright tiny italic')
      <<-HTML
<a name="pp-#{key}"></a>
<dt>#{ppid}#{hvalue[:libelle]}</dt>
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
    :auteur, :victime, :produit,
    :effet_produit, :notes, :preparation
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
      idid = "Ironie dramatique ##{key}".in_div(class:'tiny fright italic')
      <<-HTML
<a name="ironie_dramatique-#{key}"></a>
<dt>#{idid}#{hvalue[:libelle]}</dt>
<dd>
  #{description_of  hvalue}
  #{preparation_of  hvalue}
  #{installation_of hvalue}
  #{exploitation_of hvalue}
  #{resolution_of   hvalue}
  #{libnval('Auteur',   hvalue[:auteur])}
  #{libnval('Victime',  hvalue[:victime])}
  #{libnval('Produit', hvalue[:produit] || hvalue[:effet_produit] || "- non défini -")}
  #{notes_of        hvalue}
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
      # Note : Ces éléments doivent être placés dans
      # l'ordre de la structure.
      Acte_I:     {hname:'Exposition'},
      incper:     {hname:'Incident perturbateur'},
      incdec:     {hname:'Incident déclencheur'},
      pivot1:     {hname:'Premier pivot'},
      Acte_II:    {hname:'Développement'},
      un5ie:      {hname:'1 / 5<sup>e</sup>'},
      tiers:      {hname:'1 / 3'},
      deux5ie:    {hname:'2 / 5<sup>e</sup>'},
      cdv:        {hname:'Clé de voûte'},
      devpart2:   {hname:'Développement (2<sup>nde</sup> partie)'},
      trois5ie:   {hname:'3 / 5<sup>e</sup>'},
      deuxtiers:  {hname:'2 / 3'},
      crise:      {hname:'Crise'},
      pivot2:     {hname:'Second pivot'},
      Acte_III:   {hname:'Dénouement'},
      quatre5ie:  {hname:'4 / 5<sup>e</sup>'},
      climax:     {hname:'Climax'},
      end:        {hname:'Fin'},
      fin:        {hname:'Fin'}
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

  # Traitement d'une fiche YAML "fondamentales.yaml"
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
  #{libnval( "Objectif", fd2[:objectif])}
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
          traite_relatifs(dyndata[:relatifs])
        ).in_dd
      ).in_dl
    end.join
  end


  # Méthode générique qui retourne une rangée avec
  # un libellé et une valeur.
  def libelle_and_value libelle, value
    return "" if value.to_s == ""
    # Si la valeur ne se termine pas par un point,
    # on en ajoute un
    value = value.to_s.strip
    value =~ %r{[…\.\?\!\:;]$} || value += '.'
    (
      libelle.to_s.in_span(class:'libelle') +
      value.in_span(class:'value')
    ).in_div(class:'row')
  end
  alias :libnval :libelle_and_value

  def categorie_of h, key_alt = nil
    val = h[:categorie] || h[key_alt] || "" unless key_alt.nil?
    libnval("Catégorie", val.in_span(class:'bold'))
  end
  def description_of h
    libnval( 'Description', h[:description] )
  end
  def explication_of h
    libnval('Explication', h[:explication])
  end
  def preparation_of h
    libnval('Préparation', h[:preparation])
  end
  def exploitation_of h
    libnval('Exploitation', h[:exploitation])
  end
  def facteur_u_of h
    libnval('Facteur U', h[:facteurU] || h[:facteur_u])
  end
  def facteur_o_of h
    libnval('Facteur O', h[:facteurO] || h[:facteur_o])
  end
  def intitule_of h, key_alt = nil
    value = h[:intitule] || h[:libelle]
    value ||= h[key_alt] unless key_alt.nil?
    value ||= ''
    libnval('', value.in_span(class: 'bold'))
  end
  def installation_of h
    libnval('Installation', h[:installation])
  end
  def produit_of h
    libnval('Produit', h[:produit])
  end
  def question_of h
    libnval('Question', h[:question])
  end
  def reponse_of h
    libnval('Réponse', h[:reponse])
  end
  def resolution_of h
    libnval('Résolution', h[:resolution])
  end
  def notes_of h
    notes = h[:notes] || h[:note]
    notes ? libnval('Note(s)', notes) : ''
  end
  def scenes_of h
    return "" if h[:scenes].to_s == ""
    scenes = h[:scenes].split(' ').collect { |sid| sid.to_i }
    onclick = "$.proxy(Timeline,'show_scenes', '#{scenes.join(', ')}')()"
    lien_scenes = scenes.join(', ').in_a(onclick: onclick)
    libnval( 'Scènes', lien_scenes )
  end



end #/SuperFile
