# encoding: UTF-8
=begin

Module de construction du code complet de la page d'accueil

=end
class SiteHtml

  def build_home_page_content
    file_home_page_content.write home_page_content_code
  end

  def home_page_content_code
    cadre_independance_flottant +
    incipit +
    image_accueil +
    '<div style="clear:both"></div>' +
    section_hot_news +
    message_inscription_footer
  end


  # ---------------------------------------------------------------------
  #   Les éléments visuels
  # ---------------------------------------------------------------------
  def image_accueil
    image('divers/logo.png', id:'homeimage', width:"340px").in_div(class:'center')
  end

  # ---------------------------------------------------------------------
  #   Les éléments textuels
  # ---------------------------------------------------------------------

  def incipit
    (
      "Un site entièrement dévolu au ".in_span(class:'bold') +
      "développement de vos histoires".in_span(class:'bold darkcharte') +
      "."
    ).in_p(class:'small', id:'incipit')
  end

  def cadre_independance_flottant
    signup_link = ("S’INSCRIRE " +
    "(gratuit)".in_span(class:'tiny')
    ).in_a(id:'btn_signup',href:"user/signup", class:'btn')
    subscribe_link = (
      "S’ABONNER " +
      "(#{site.tarif_humain}/an)".in_span(class:'tiny')
    ).in_a(id:'btn_subscribe', href:"user/paiement", class:'btn')
    <<-HTML
<div id="cadre_independance">
#{signup_link}
<p>
  Pour n'afficher <strong>aucune publicité</strong> et proposer néanmoins un
   <strong>contenu de qualité</strong>, l'utilisation de certains outils du
   site requiert un abonnement modique d'un montant de
   <strong>#{site.tarif_humain} pour une année</strong>
   (soit #{site.tarif_humain_par_mois}).
</p>
#{subscribe_link}
</div>
    HTML
  end

  def message_inscription_footer
    <<-HTML
<p class='tiny'>Si vous êtes déjà inscrit, vous pouvez
#{lien.signin("vous identifier", class:'greencharte bold')} grâce au
lien de la marge gauche. Si vous n'êtes pas inscrit, alors…
qu'attendez-vous pour
#{lien.subscribe("vous inscrire gratuitement", class:'greencharte bold')} 
? :-)
</p>
    HTML
  end

end #/SiteHtml
