require 'factory_girl'

Factory.define :role, :class => :role do |r|
    r.category "admin"
    r.limit 15
end


Factory.define :yarn_count do |yc|
    yc.warp_ply_count 2
    yc.weft_ply_count 2
    yc.warp_yarn_thickness 30
    yc.weft_yarn_thickness 40
end

Factory.define :reed_pick do |rp|
    rp.reed 24
    rp.pick 32
end

Factory.define :color1, :class => :color do |c|
  c.red 230
  c.green 243
  c.blue 134
end

Factory.define :color2, :class => :color do |c|
  c.red 34
  c.green 198
  c.blue 76
end

Factory.define :fabric do |f|
  f.code "Code1234"
  f.width 44
  f.price 55.49
  f.quantity 100.30
  f.reed_pick {|rp| rp.association(:reed_pick)}
  f.yarn_count {|yc| yc.association(:yarn_count)}
  f.colors {|c| [c.association(:color1), c.association(:color2)]}
end

Factory.define :collection do |c|
  c.name "default"
  c.fabrics {|f| [f.association(:fabric)]}
end

Factory.define :user do |u|
    u.username "foo"
    u.password "foobar1234"
    u.password_confirmation { |u| u.password }
    u.email "foo@test.com"
    u.collections {|c| [c.association(:collection)]}
end
