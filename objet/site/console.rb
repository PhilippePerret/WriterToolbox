# encoding: UTF-8
raise "Section interdite" unless user.admin?

=begin
Traitement de la console.

Les fichiers se trouvent dans ./lib/deep/deeper/_per_route/site/console/
=end

def console
  @console ||= SiteHtml::Admin::Console::current
end

console.execute_code if console.has_code?
