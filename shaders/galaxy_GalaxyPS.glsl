#version 330

uniform vec2 uResolution;
uniform float uTime;

out vec4 outColor;

const float PI = 3.14159;
const int CIRCLES = 2000;
const float OUTER_RAD = 1.0;
const float TILT_X = 0.05;
const float TILT_Y = 0.1;
const float CENTER_SPIN_SPEED = 1.0;

float circle(vec2 uv, vec2 center, float r0, float r1)
{
    float d = length(center - uv);
    return 1.0 - smoothstep(r0, r1, d);
}

float rand(vec2 co)
{
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

// https://iquilezles.org/articles/palettes/
// http://dev.thi.ng/gradients/
vec3 palette(float t)
{
    vec3 a = vec3(0.838, 0.838, 0.788);
    vec3 b = vec3(0.445, 0.390, 0.641);
    vec3 c = vec3(0.380, 0.584, 0.380);
    vec3 d = vec3(-0.272, -0.239, 0.075);

    return a + b*cos(6.28318*(c*t+d));
}

void main()
{
    vec2 uv = (gl_FragCoord.xy * 2.0 - uResolution.xy) / uResolution.y;
    vec3 finalColor = vec3(0.0);

    for (int i = 0; i < CIRCLES; i++)    
    {
        float centerDist = rand(vec2(i));
        float offset = i * PI * 2 / CIRCLES;
        float distSpeed = 1.0 + (1.0 - centerDist) * CENTER_SPIN_SPEED;
        float posX = sin(uTime * (TILT_X + distSpeed) + offset);
        float posY = cos(uTime * (TILT_Y + distSpeed) + offset);
        
        vec3 col = palette(centerDist + sin(uTime) * 0.5);

        finalColor += circle(
            uv,
            vec2(
                posX * OUTER_RAD * centerDist,
                posY * OUTER_RAD * centerDist
            ),
            0.0,
            0.04 * (1.0 - centerDist * 0.5)
        ) * col;
    }
    
    outColor = vec4(finalColor,1.0);
}