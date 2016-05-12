# encoding: UTF-8

test_route "" do |r|
  r.responds
end

test_route "scenodico/32/show", __LINE__ do |r|
  r.responds
  r.has_title(/Scénodico/, 1)
end

# test_route "scenodico/32/show" do |r|
#   r.has_not_title(/Filmodico/)
# end
#
# test_route "bad/one.html", __LINE__ do |r|
#   r.not_responds
# end

test_route "" do |r|
  r.has_tag("section#header")
  r.has_tag("section#content")
  r.has_not_tag("section#footer")
  # r.has_not_tag("mauvaise#balise")
end
