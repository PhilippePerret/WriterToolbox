# encoding: UTF-8
=begin

Module de construction du code complet de la page d'accueil

=end
class SiteHtml

  def build_home_page_content
    app.benchmark('-> SiteHtml#build_home_page_content')
    res = file_home_page_content.write( home_page_content_code )
    app.benchmark('<- SiteHtml#build_home_page_content')
    return res
  end

  def home_page_content_code
    (
      section_spotlight +
      cadre_independance_flottant #+
      #cadre_reseaux_sociaux
    ).in_div(class:'fright', style:'margin-top:20px') +
    incipit +
    # image_accueil +
    video_accueil +
    '<div style="clear:both"></div>' +
    extrait_last_blog_post +
    section_hot_news +
  end


  # ---------------------------------------------------------------------
  #   Les éléments visuels
  # ---------------------------------------------------------------------

  # Voir le fichier ./hot/spotlight.rb qui définit SPOTLIGHT
  def section_spotlight
    app.benchmark('[Building home]-> SiteHtml#section_spotlight')
    require './hot/spotlight'
    lien_spotlight = SPOTLIGHT[:title].in_a(href:SPOTLIGHT[:href]).in_div(id: 'main_thing')
    image =
      if SPOTLIGHT[:img]
        src = "view/img/#{SPOTLIGHT[:img]}"
        "<img src='#{src}' style='float:left;margin-right:8px;' />"
      else '' end
    res =
      (
        "#{image}#{SPOTLIGHT[:before]}#{lien_spotlight}#{SPOTLIGHT[:after]} ".in_div
      ).in_section(id:'home_spotlight', onclick:"document.location.href='#{SPOTLIGHT[:href]}'")
    app.benchmark('[Building home]<- SiteHtml#section_spotlight')
    return res
  end

  def image_accueil
    image('divers/logo.png', id:'homeimage', width:"340px").in_div(class:'center')
  end

  def video_accueil
    '<iframe width="560" height="315" src="https://www.youtube.com/embed/xpozls2yMkk" frameborder="0" allowfullscreen></iframe>'
  end

  # ---------------------------------------------------------------------
  #   Extrait du dernier article du blog
  # ---------------------------------------------------------------------
  def extrait_last_blog_post
    site.require_objet 'article'

    (
      'Dernier article'.in_span(id: 'libelle_last_post', class: 'libelle') +
      Article.last.extrait.in_span(class: 'extrait_blog') +
      ' [lire la suite]'
    ).in_a(id: 'last_post_blog', href:"article/#{Article.last.id}/show")
  end
  def path_current
    @path_current ||= site.folder_objet+'article/'
  end
  # ---------------------------------------------------------------------
  #   Les éléments textuels
  # ---------------------------------------------------------------------

  def incipit
    lien_phil = '<auteur class="darkcharte">Philippe Perret</auteur>'.in_a(href: "site/phil")
    (
      '<img id="medaillon_phil_accueil" src="./view/img/divers/phil.png" class="fleft" style="" />' +
      "Le site de #{lien_phil} entièrement dévolu au ".in_span(class:'bold') +
      "développement de vos histoires".in_span(class:'bold darkcharte') +
      "."
    ).in_p(class:'small', id:'incipit')
  end

  def cadre_independance_flottant
    app.benchmark('[Building home]-> SiteHtml#cadre_independance_flottant')
    signup_link = 'S’INSCRIRE'.in_a(id:'btn_signup',href:BOA.rel_signup_path, class:'btn')
    subscribe_link =
      'S’ABONNER'.in_a(id:'btn_subscribe', href:"user/paiement", class:'btn')
      #{signup_link}
    res = <<-HTML
      <div id="cadre_independance">
      <p><strong>Soutenez le site</strong> pour qu'il continue de proposer un
         contenu de qualité en vous abonnant pour #{site.tarif_humain} / an.
      </p>
      #{subscribe_link}
      </div>
      HTML
    app.benchmark('[Building home]<- SiteHtml#cadre_independance_flottant')
    return res
  end

end #/SiteHtml
