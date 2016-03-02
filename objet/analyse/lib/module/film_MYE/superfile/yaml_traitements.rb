# encoding: UTF-8
class SuperFile

  # Traitement en fonction du fichier YAML
  def as_yaml

    case affixe
    when 'personnages'
      traite_content_as_personnages
    when 'structure'
      traite_content_as_structure
    when 'fondamentales'
      traite_content_as_fondamentales
    when 'commentaires'
      traite_content_as_commentaires
    when 'ironies_dramatiques'
      traite_content_as_ironies_dramatiques
    when 'preparations_paiments'
      traite_content_as_pps
    else
      # Traitement comme une liste de choses, par exemple comme une
      # liste d'ironies dramatiques ou de préparations-paiements
      traite_content_as_list_of_things
    end.formate_balises_propres
  end

  # Traitement le contenu yam comme une liste de choses
  # Par exemple une liste de commentaires.
  # Les "listes de choses" sont des Hash dont la clé est un ID numérique
  # et la valeur un Hash où on prendra la clé pour faire le libellé et la
  # valeur pour faire… la valeur.
  def traite_content_as_list_of_things
    yaml_content.collect do |key, hvalue|
      hvalue.collect do |lib, val|
        next nil if lib == :id
        lib = case lib
        when :titre then "Intitulé"
        when :texte then "Description"
        else lib.to_s
        end
        libnval(lib, val.to_s)
      end.compact.join.in_div
    end.join
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
    yaml_content.collect do |key, hvalue|
      ( hvalue[:titre].in_dt + hvalue[:texte].in_dd )
    end.join.in_dl
  end

  PROPERTIES_PP_TRAITED = [
    :id,
    :libelle, :description,
    :installation, :exploitation, :resolution
  ]
  def traite_content_as_pps
    explication_pp.in_p(class:'small italic') +
    yaml_content.collect do |key, hvalue|
      if user.admin? && @properties_irdr_traited.nil?
        hcheck = hvalue.dup
        PROPERTIES_PP_TRAITED.each do |prop|
          hcheck.delete(prop)
        end
        error "Les propriétés #{hcheck.keys.join(', ')} ne sont pas traitées dans les préparations/paiements. #{lien.edit_file(__FILE__, titre:'Ouvrir ce fichier', line:__LINE__)} pour ajouter leur traitement" unless hcheck.empty?
        @properties_irdr_traited = true
      end
      <<-HTML
<a name="ironie_dramatique-#{key}"></a>
<dt>#{hvalue[:libelle]}</dt>
<dd>
  #{description_of  hvalue}
  #{installation_of hvalue}
  #{exploitation_of hvalue}
  #{resolution_of   hvalue}
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
    :auteur, :victime
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
<dt>#{hvalue[:libelle]}</dt>
<dd>
  #{description_of  hvalue}
  #{installation_of hvalue}
  #{exploitation_of hvalue}
  #{resolution_of   hvalue}
  #{libnval("Auteur",   hvalue[:auteur])}
  #{libnval("Victime",  hvalue[:victime])}
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
      libelle.in_span(class:'libelle') +
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


  def dsection_fond1
    fd1 = yaml_content[:personnage_fondamental]
    return "" if fd1.nil? || fd1.empty?
    <<-HTML
<dt>Personnage Fondamental (Fd. 1)</dt>
<dd>
  #{libnval("Nom", fd1[:nom])}
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
    return "" if fd2.nil? || fd2.empty?
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

  end
  def dsection_fond4

  end
  def dsection_fond5

  end

  def traite_content_as_fondamentales
    fd3 = yaml_content[:opposition_fondamentale]
    fd4 = yaml_content[:reponse_fondamentale]
    fd5 = yaml_content[:concept_fondamental]
    <<-HTML
<dl>
  #{dsection_fond1}
  #{dsection_fond2}

  <dt>Opposition Fondamentale (Fd. 3)</dt>
  <dd>
    #{intitule_of(fd3)}
    #{description_of(fd3)}
    #{facteur_u_of(fd3)}
    #{facteur_o_of(fd3)}
  </dd>

  <dt>Réponse Dramatique Fondamentale (Fd. 4)</dt>
  <dd>
    #{intitule_of(fd4)}
    #{description_of(fd4)}
    #{facteur_u_of(fd4)}
    #{facteur_o_of(fd4)}
  </dd>

  <dt>Concept Fondamental (Fd. 5)</dt>
  <dd>
    #{intitule_of(fd5)}
    #{description_of(fd5)}
    #{facteur_u_of(fd5)}
    #{facteur_o_of(fd5)}
  </dd>
</dl>
    HTML
  end
end #/SuperFile
