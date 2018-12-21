use <threads.scad>

translate([10,0,0])
  metric_thread (diameter=8, pitch=1, n_starts=6, square=0, length=1);

thread_polyhedron (radius=4, pitch=1, internal=0, n_starts=1, thread_size=2,
                          groove=0, square=0, rectangle=0, angle=30);
                          
