# encoding: UTF-8
class SiteMap
  class Location

    def simple_as_xml
      @nombre_urls += 1
      c = Array.new
      c << "<url>"
      c << "  <loc>#{full_url}</loc>"
      c << "  <priority>#{priority}</priority>"
      c << balise_last_modification
      c << balise_frequence_changement
      c << "</url>"
      c << balise_video
      return c.join("\n")
    end

    def balise_last_modification
      lastmod || (return '')
      value_lastmod =
        case lastmod
        when /([0-9]{4,4})-([0-9]{2,2})-([0-9]{2,2})/
          lastmod
        when true
          File.stat("./objet/#{url}.erb").mtime.strftime("%Y\-%m\-%d")
        end
      "\n      <lastmod>#{value_lastmod}</lastmod>"
    end
    def balise_frequence_changement
      changefreq || (return '')
      "\n      <changefreq>#{changefreq}</changefreq>"
    end

    def balise_video
      video? || (return '')
      <<-XML
      <video:video>
        <video:content_loc>
          #{video_loc}
        </video:content_loc>
        <video:player_loc allow_embed="yes">
          #{full_url}
        </video:player_loc>
        #{balise_thumbnail_video}
        <video:title>#{video_title}</video:title>
        <video:description>
          #{video_description}
        </video:description>
      </video:video>
      XML
    end

    def balise_thumbnail_video
      video_thumbnail || (return '')
      <<-XML
      <video:thumbnail_loc>
        #{video_thumbnail}
      </video:thumbnail_loc>
      XML
    end

  end #/Location
end #/SiteMap
