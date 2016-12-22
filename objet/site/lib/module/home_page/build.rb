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
    image_accueil +
    '<div style="clear:both"></div>' +
    extrait_last_blog_post +
    section_hot_news +
    message_inscription_footer
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
    signup_link = 'S’INSCRIRE'.in_a(id:'btn_signup',href:"user/signup", class:'btn')
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

#   # Cadre pour contenir les liens vers facebook et
#   # twitter OBSOLÈTE
#   def cadre_reseaux_sociaux
#     app.benchmark('[Building home]-> SiteHtml#cadre_reseaux_sociaux')
#     res = <<-HTML
# <div id="cadre_reseaux_sociaux">
#   #{picto_facebook}
#   #{picto_twitter}
# </div>
#     HTML
#     app.benchmark('[Building home]<- SiteHtml#cadre_reseaux_sociaux')
#     return res
#   end
  # def picto_facebook
  #   app.benchmark('[Building home]-> SiteHtml#picto_facebook')
  #   res = <<-HTML
  #   <div
  #     class="fb-like"
  #     data-href="https://www.facebook.com/laboiteaoutilsdelauteur"
  #     data-layout="button"
  #     data-action="like"
  #     data-show-faces="false"
  #     data-share="true"
  #     style="margin:0"
  #     >Facebook</div>
  #   HTML
  #   app.benchmark('[Building home]<- SiteHtml#picto_facebook')
  #   return res
  # end
  # def picto_twitter
  #   app.benchmark('[Building home]-> SiteHtml#picto_twitter')
  #   res = <<-HTML
  #   <div style="margin:0"><a
  #     id="twitter-button"
  #     class="twitter-share-button"
  #     href="https://twitter.com/intent/tweet"
  #     data-size='medium'
  #     >Tweet</a></div>
  #   HTML
  #   app.benchmark('[Building home]<- SiteHtml#picto_twitter')
  #   return res
  # end

  def message_inscription_footer
    app.benchmark('[Building home]-> SiteHtml#message_inscription_footer')
    res = <<-HTML
<p class='tiny'>Si vous êtes déjà inscrit, vous pouvez
#{lien.signin("vous identifier", class:'greencharte bold')} grâce au
lien de la marge gauche. Si vous n'êtes pas inscrit, alors…
qu'attendez-vous pour
#{lien.subscribe("vous inscrire gratuitement", class:'greencharte bold')} 
? :-)
</p>
    HTML
    app.benchmark('[Building home]<- SiteHtml#message_inscription_footer')
    return res
  end

end #/SiteHtml
