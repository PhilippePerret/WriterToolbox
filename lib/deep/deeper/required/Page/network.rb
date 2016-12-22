# encoding: UTF-8
class Page

  def courante_route_sans_protocole
    @courante_route_sans_protocole ||= begin
      site.distant_host +
      (site.current_route ? site.current_route.route : '')
    end
  end
  def twitter_url
    @twitter_url ||= begin
      url = CGI.escape(courante_route_sans_protocole)

      href = "https://twitter.com/intent/follow"
      href << "?"
      href << "original_referer=#{url}"
      href << "&region=follow_link"
      href << "&screen_name=#{site.twitter}"
      href << "&tw_p=followbutton"

      onclick = "_gaq.push(['_trackEvent', 'outbound-article', 'https://twitter.com/intent/follow?original_referer=#{url}/&region=follow_link&screen_name=#{site.twitter}&tw_p=followbutton', 'Follow @#{site.twitter}'])"

      image = "Follow @#{site.twitter}"
      image = '<img src="./view/img/logo/reseaux/tweet.png" />'
      image.in_a(href: href, onclick: onclick, target: :new, class: 'network_button')
    end
  end

  def facebook_share_button
    url   = CGI.escape(courante_route_sans_protocole)
    titre = CGI.escape("La Boite à outils de l’auteur")
    href  = "http://www.facebook.com/sharer/sharer.php?u=#{url}&title=#{titre}"
    image = '<img src="./view/img/logo/reseaux/share.png" />'
    image.in_a(href: href, target: :new, class: 'network_button')
  end

  def facebook_like_button
    href = "https://www.facebook.com/laboiteaoutilsdelauteur"
    image = '<img src="./view/img/logo/reseaux/like.png" />'
    image.in_a(href: href, target: :new, class: 'network_button')
  end
end
