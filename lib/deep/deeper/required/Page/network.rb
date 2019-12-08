# encoding: UTF-8
class Page

  def courante_route_sans_protocole
    @courante_route_sans_protocole ||= begin
      site.distant_host +
      (site.current_route ? site.current_route.route : '')
    end
  end
  def twitter_button
    url = CGI.escape(courante_route_sans_protocole)

    href = "https://twitter.com/intent/follow"
    href << "?"
    href << "region=follow_link"
    href << "&screen_name=#{site.twitter}"
    href << "&tw_p=followbutton"
    href << "&original_referer=#{url}"

    onclick = "_gaq.push(['_trackEvent', 'outbound-article', 'https://twitter.com/intent/follow?region=follow_link&screen_name=#{site.twitter}&tw_p=followbutton&original_referer=#{url}', 'Follow @#{site.twitter}'])"

    img = image('logo/reseaux/tweet.png')
    img.in_a(href: href, onclick: onclick, target: :new, class: 'network_button')
  end

  def facebook_share_button
    url   = CGI.escape(courante_route_sans_protocole)
    titre = CGI.escape("La Boite à outils de l’auteur")
    href  = "http://www.facebook.com/sharer/sharer.php?u=#{url}&title=#{titre}"
    img = image('logo/reseaux/share.png')
    img.in_a(href: href, target: :new, class: 'network_button')
  end

  def facebook_like_button
    href = "https://www.facebook.com/scenariopole"
    img = image('logo/reseaux/like.png')
    img.in_a(href: href, target: :new, class: 'network_button')
  end
end
