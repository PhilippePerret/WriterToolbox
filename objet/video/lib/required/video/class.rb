# encoding: UTF-8
class Video
  class << self

    def get vid
      vid = vid.to_i
      @instances ||= begin
        load_data
        Hash::new()
      end
      @instances[vid] ||= new(DATA_VIDEOS[vid])
    end

    def list
      load_data
      DATA_VIDEOS.collect do |vid, vdata|
        new(vdata).as_li
      end.join.in_ul(id:"videos", class:'tdm')
    end

    def load_data
      (folder+'DATA_VIDEOS.rb').require # => Video::DATA_VIDEOS
    end

    def folder
      @folder ||= site.folder_objet+'video'
    end
  end # /<< self
end #/Video
