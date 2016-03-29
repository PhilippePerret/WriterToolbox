# encoding: UTF-8
=begin
  Utilisé pour ouvrir un fichier Markdown

  @usage

    href: "site/open_md_file?path=le/path/du/fichier.md"
=end
flash "Ouverture de #{param :path}"
`open -a #{site.markdown_application} "#{param :path}"`
redirect_to :last_route
