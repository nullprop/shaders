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

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main()
{
    vec2 uv = (gl_FragCoord.xy * 2.0 - uResolution.xy) / uResolution.y;
    uv *= 0.6; // final scale
    vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0);

    // sun + sky base
    float dist = length(uv);
    float flareMask = 1.0 - smoothstep(0.4, 0.49, dist);
    float hotspotMask = 1.0 - smoothstep(0.4, 0.43, dist);
    float noiseMask = 1.0 - smoothstep(0, 0.43, dist);
    vec3 col = palette(dist);

    dist = 0.6 / dist;
    dist = pow(dist, 1.4);

    finalColor += col * dist;

    // flares
    vec3 flareColor = vec3(0.0);
    for (float i = 0.0; i < 3.0; i++)
    {
        uv = fract(uv * 1.6) - 0.5;
        
        float d = length(uv);
        vec3 col = palette(d + sin(uTime * 0.1));
        d = sin(d * 12.0 + uTime * 0.5) / 12.0;
        d = abs(d);
        
        d = 0.04 / d;
        d = pow(d, 1.4);
        
        flareColor += col * d * flareMask;
    }
    finalColor += flareColor;

    // hotspots
    /*
    vec3 hotspotColor = vec3(1.0);
    float hotspotMask2 = 1.0;
    vec2 hotspotUv = uv0 + 0.01 * vec2(uTime, -uTime * 0.2);
    
    for (float i = 0.0; i < 2.0; i++)
    {
        hotspotUv = fract(hotspotUv * 1.5) - 0.5;
        
        float d = length(hotspotUv);
        d = sin(d * 4.0) / 8.0;
        d = abs(d);
        
        d = 0.1 / d;
        
        hotspotMask2 *= d;
    }
    finalColor -= 0.03 * hotspotColor * hotspotMask * hotspotMask2;
    */

    // surface noise + brighter in the middle
    float noise = rand(uv * sin(uTime));
    finalColor += 1.5 * noise * noiseMask;
    
    // vignette
    vec2 edge = gl_FragCoord.xy / uResolution.xy;
    edge *= 1.0 - edge.yx;
    float vig = edge.x * edge.y * 20.0;
    vig = pow(vig, 0.1);
    finalColor *= vig;
    
    outColor = vec4(finalColor, 1.0);
    //outColor = vec4(hotspotColor * hotspotMask * hotspotMask2, 1.0);
}