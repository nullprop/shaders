#version 330

uniform vec2 uResolution;
uniform float uTime;

out vec4 outColor;

// https://iquilezles.org/articles/palettes/
// http://dev.thi.ng/gradients/
vec3 palette(float t) {
    vec3 a = vec3(0.500, 0.500, 0.000);
    vec3 b = vec3(0.500, 0.500, 0.000);
    vec3 c = vec3(0.100, 0.500, 0.000);
    vec3 d = vec3(0.000, 0.000, 0.000);

    return a + b*cos(6.28318*(c*t+d));
}

vec3 palette2(float t) {
    vec3 a = vec3(0.500, 0.500, 0.000);
    vec3 b = vec3(0.500, 0.500, 0.000);
    vec3 c = vec3(1.000, 1.000, 1.000);
    vec3 d = vec3(0.000, 0.333, 0.667);

    return a + b*cos(6.28318*(c*t+d));
}

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main()
{
    vec2 uv = (gl_FragCoord.xy * 2.0 - uResolution.xy) / uResolution.y;
    
    // wobble
	uv.x *= mix(1.0, sin(uTime * 0.5), 0.05);
	uv.y *= mix(1.0, sin(uTime * 0.4), 0.05);
    
    vec2 uv0 = uv;
    float dist = length(uv0);
    vec3 finalColor = vec3(0.0);
    
    // foreground flash
    for (float i = 0.0; i < 2.0; i++)
    {
    	uv = fract(uv * 0.4) - 0.5;
    	uv *= cos(uTime * 0.5);

    	vec3 col = palette(dist + sin(uTime * 0.1));

		float d = length(uv);
		d = sin(d * 12.0 + uTime * 0.5) / 12.0;
		d = abs(d);
		
		d = 0.02 / d;
		d = pow(d, 1.4);

		finalColor += col * d;
    }

    // noise
    float noise = rand(uv0 * uTime);
    float strength = 0.2;
    finalColor.x = pow(finalColor.x, mix(1.0, noise, strength));
    finalColor.y = pow(finalColor.y, mix(1.0, noise, strength));
    finalColor.z = pow(finalColor.z, mix(1.0, noise, strength));

	// background circles
    uv = fract(uv0 * 30.5) - 0.5;
    uv *= sin(uTime * 0.5);

    vec3 col = palette2(dist + sin(uTime * 0.4));
    
	float d = length(uv);
	d = sin(d * 5.0 + uTime * 0.5) / 5.0;
	d = abs(d);
	
	d = 0.01 / d;
	d = pow(d, 0.5);
	
	finalColor += col * d;
	
	// vignette
	vec2 edge = gl_FragCoord.xy / uResolution.xy;
	edge *= 1.0 - edge.yx;
    float vig = edge.x * edge.y * 20.0;
    vig = pow(vig, 0.4);
    finalColor *= vig;
    
    outColor = vec4(finalColor, 1.0);
}