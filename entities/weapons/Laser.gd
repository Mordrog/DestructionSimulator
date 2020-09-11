extends ImmediateGeometry

var from
var to
var color
var destroy_delay

func init(_from, _to, _color, _destroy_delay) -> void:
	from = _from
	to = _to
	color = _color
	destroy_delay = _destroy_delay

func _ready() -> void:
	draw_line(from, to, color)

func _process(delta: float) -> void:
	destroy_delay -= delta
	if destroy_delay < 0:
		queue_free()
		
func _exit_tree() -> void:
	clear()

func draw_line(from, to, color):
	begin(Mesh.PRIMITIVE_LINES)
	set_color(color)
	add_vertex(from)
	add_vertex(to)
	end()
