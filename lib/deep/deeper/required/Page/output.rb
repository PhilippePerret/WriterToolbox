# encoding: UTF-8
=begin

=end
class Page

  def output
    unless site.ajax?
      debug "Juste avant cgi.html, app.session['user_id']/app.session['boa_user_id'] = #{app.session['user_id']} / #{app.session['boa_user_id']}"
      final_code = cgi.html{cgi.head{head}+cgi.body{body}}
      app.benchmark('CODE HTML FINAL BUILT') rescue nil
      # Correspond aussi à la fin de la méthode output du site
      app.benchmark('<- SiteHtml#output')
      app.benchmark_fin #rescue nil

      # Pour CGI::out
      data_cgiout = {}

      if user.identified?
        debug "User ##{user.id} identifié (#{user.pseudo})"
        sessionId = app.session.session_id
        now = Time.now.to_i
        route = site.full_route # contre self.full_route sur SCENARIOPOLE
        # INSERT INTO table (id, name, age) VALUES(1, "A", 19) ON DUPLICATE KEY UPDATE
        # name="A", age=19
        query = "INSERT INTO `sessions`"+
                " (session_id, user_id, ip_address, route, created_at)"+
                " VALUES (?, ?, ?, ?, ?)"+
                " ON DUPLICATE KEY UPDATE route = ?, created_at = ?, ip_address = ?"
        values = [
            sessionId, user.id, user.ip, route, now,
            route, now, user.ip
          ]
        # Soumettre la requête
        site.db.use_db('hot')
        site.db.execute(query, values)

        userCookie = CGI::Cookie.new(
          "name"      => "sessionid",
          "value"     => sessionId,
          "expires"   => Time.now + 3600
        )

        data_cgiout.merge!(
          "cookie" => userCookie
        )

        debug "--- Enregistrement de la connexion côté BOA ---"
      else
        debug "--- User non identifié, pas d'enregistrement de connexion côté BOA ---"
      end

      cgi.out(data_cgiout){final_code}
      # RIEN NE PEUT PASSER ICI
    else
      # Retour d'une requête ajax
      Ajax.output
    end
  end

  # Retourne TRUE si l'objet est une collection, pour schema.org,
  # comme une dictionnaire (scénodico) ou une liste comme filmodico.
  # Cela a pour effet d'ajouter "itemscope itemtype='http://schema.org/Collecion'"
  # dans la section de contenu de la page.
  #
  # @usage: utiliser page.is_collection pour définir que c'est une
  # collection.
  def collection?
    !!@is_collection
  end
  def is_collection value = true
    @is_collection = value
  end

  def ajout_schema_org
    if collection?
      ' itemscope itemtype="http://schema.org/Collection"'
    else
      ''
    end
  end

  def head
    @head ||= begin
      app.benchmark('-> Page#head')
      # <link href='https://fonts.googleapis.com/css?family=Open+Sans:400,300,600,700&subset=latin-ext,latin' rel='stylesheet' type='text/css'>
      fonts_google =
        if true # Mettre ONLINE quand on ne peut pas avoir de connexion
          <<-FONTS
          <link href="https://fonts.googleapis.com/css?family=News+Cycle" rel="stylesheet">
          <!--[if lt IE 9]>
          <script src="//html5shim.googlecode.com/svn/trunk/html5.js"></script>
          <![endif]-->
          FONTS
        else
          ""
        end
      head_built = <<-HEAD
  <meta content="text/html; charset=utf-8" http-equiv="Content-type">
  <title>#{page.title}</title>
  <base href="#{site.url}/" />
  <link rel="shortcut icon" href="view/img/favicon.ico?" type="image/x-icon">
  <link rel="icon" href="view/img/favicon.ico?" type="image/x-icon">
  #{self.balise_meta_description}
  #{fonts_google}
  #{self.javascript}
  #{self.css}
  #{self.raw_css}
  #{self.raw_javascript}
        HEAD
      app.benchmark('<- Page#head')
      head_built
    end
    #/head
  end

  def route_courante
    site.url +
    if site.current_route
      "/#{site.current_route.route}"
    else
      ''
    end
  end

  def body
    @body ||= begin
      app.benchmark('-> Page#body')
      res =
        page.header         +
        (left_margin? ? page.left_margin : '') +
        page.content        +
        page.footer         +
        app.div_flash       +
        page.section_debug
      app.benchmark('<- Page#body')
      res
    end
  end
  # /body

end
