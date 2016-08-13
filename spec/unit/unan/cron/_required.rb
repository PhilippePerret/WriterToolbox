def verbose_here?
  false
end
def log str, opts = nil
  verbose_here? && (puts str)
end
def superlog str
  verbose_here? && (puts "Superlog: #{str}")
end
class CRON2
  class Histo
    def self.add h; end
  end
end
