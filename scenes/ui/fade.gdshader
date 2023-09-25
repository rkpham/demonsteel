shader_type canvas_item;

uniform float left;
uniform float right;
uniform float skew;

void fragment() {
	if ((UV.x + UV.y * skew) < left) {
		COLOR = vec4(0.0);
	}
	if ((UV.x + UV.y * skew) > right) {
		COLOR = vec4(0.0);
	}
}
