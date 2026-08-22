shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform float edge = 0.005;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float dist = distance(UV, vec2(0.5));
    float alpha = 1.0 - smoothstep(radius - edge, radius, dist);

    COLOR = tex;
    COLOR.a *= alpha;
}