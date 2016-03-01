# encoding: UTF-8
class Ajax
  class << self

    attr_reader :data

    def output
      STDOUT.write "Content-type: application/json; charset:utf-8;\n\n"
      STDOUT.write (data || Hash::new).to_json
    end

    # Ajoute une donnée à retourner
    def << hdata
      @data ||= Hash::new
      @data.merge!( hdata )
    end

  end # /<< self
end #/Ajax
