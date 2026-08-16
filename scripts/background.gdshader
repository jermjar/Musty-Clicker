shader_type canvas_item;

uniform float rotation_speed : hint_range(-360.0, 360.0) = 30.0;
uniform float angle_degrees : hint_range(0.0, 360.0, 1.0) = 0.0;

uniform float repeat_x : hint_range(1.0, 20.0, 1.0) = 1.0;
uniform float repeat_y : hint_range(1.0, 20.0, 1.0) = 1.0;

// Width / Height of the area being drawn.
// For a 9:16 area, set this to 0.5625.
uniform float aspect_ratio = 0.5625;

uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
    float angle = radians(angle_degrees + TIME * rotation_speed);

    float c = cos(angle);
    float s = sin(angle);

    // Tile first
    vec2 uv = UV * vec2(repeat_x, repeat_y);

    // Work on a single tile
    uv = fract(uv);

    // Center around (0,0)
    uv -= vec2(0.5);

    // Compensate for aspect ratio
    uv.x *= aspect_ratio;

    // Rotate
    uv = vec2(
        uv.x * c - uv.y * s,
        uv.x * s + uv.y * c
    );

    // Undo aspect ratio compensation
    uv.x /= aspect_ratio;

    // Move back into UV space
    uv += vec2(0.5);

    COLOR = texture(TEXTURE, uv) * tint;
}