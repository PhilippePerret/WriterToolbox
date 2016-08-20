# Google Sitemap

L'idée est de générer automatiquement une site map XML à partir d'un fichier YAML (ou plus simple ?).

Voir le schéma sur [le site google](http://www.sitemaps.org/protocol.html).

~~~

<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
  xmlns:image="http://www.google.com/schemas/sitemap-image/1.1"
  xmlns:video="http://www.google.com/schemas/sitemap-video/1.1">
  <url>
    <loc>http://www.example.com/machin.html</loc>
    <lastmod>2005-05-23</lastmod>
    <image:image>
       <image:loc>http://example.com/image.jpg</image:loc>
       <image:caption>Chiens jouant aux cartes</image:caption>
    </image:image>
    <video:video>
      <video:content_loc>
        http://www.example.com/video123.flv
      </video:content_loc>
      <video:player_loc allow_embed="yes" autoplay="ap=1">
        http://www.example.com/videoplayer.swf?video=123
      </video:player_loc>
      <video:thumbnail_loc>
        http://www.example.com/thumbs/123.jpg
      </video:thumbnail_loc>
      <video:title>Barbecue d'été</video:title>  
      <video:description>
        Maîtrisez la cuisson de vos grillades
      </video:description>
    </video:video>
  </url>
</urlset>

~~~

## Fichier YAML

~~~

    -
      :url:         ./cnarration/home
      :lastmod:     true/false
      :changefreq:  always/hourly/dayly/weekly/monthly/yearly/never
      :priority:    0.0 à 1
    -
      :url: ./unan/home

~~~
