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
    vec3 finalColor = vec3(0.0);
    
    // flame
    float flameMask = 0.0;

    for (float i = 2.0; i < 6.0; i++)
    {
        vec2 circleUv = uv + vec2(0, i * 0.4 - 0.7);
        circleUv.x += mix(1.0, sin(40.0 * uTime / i), 0.1 / i) - 1;
        float dist = length(circleUv);
        float circleMask = 1.0 - smoothstep(pow(0.05, 1.0 / i), pow(0.5, 1.0 / i), dist);
        flameMask += circleMask;
    }

    vec3 col = palette(1.0 - min(1.0, flameMask * 0.25));
    finalColor += col * flameMask;
    
    // smoke
    vec2 uvSmoke = abs(uv + -vec2(1.0));
    float smokeMask = 1.0 - smoothstep(0, 1.0 / uvSmoke.y, abs(uv.x));
    vec2 uvScroll = uv + vec2(sin(uTime * 0.4), -uTime);
    vec3 smokeColor = vec3(0.0);

    for (float i = 0.0; i < 4.0; i++)
    {
        uvScroll = fract(uvScroll * 0.6) - 0.5;
        uvScroll *= rand(uvScroll);
        float d = length(uvScroll);
        d = sin(d * 3.0 + uTime * 0.5) / 10.0;
        d = abs(d);
        smokeColor += vec3(smokeMask * d);
    }

    finalColor += smokeColor * 0.6;
    
    // sparks
    vec3 sparkColor = palette(sin(uTime * 0.5) * length(uv));
    vec2 sparkScroll = uv + vec2(sin(uTime * 0.5) * 0.1 * (uv.y + 1.0), -uTime * 0.3);
    float sparkMask = 0.0;
    for (float i = 0.0; i < 2.0; i++)
    {
        sparkScroll = fract(sparkScroll * 1.5) * 2.0 - 1.;
        
        float d = length(sparkScroll);
        d = sin(d * 2.0) / 8.0;
        d = abs(d);
        
        d = 0.01 * (1.0 + sin(uTime * 1) * 0.2) / d;
        
        if (i <= 0.0)
        {
            sparkMask += d;
        }
        else
        {
            sparkMask *= d;
        }
    }
    sparkMask *= smoothstep(0.0, 1.0, 1.0 - flameMask);
    finalColor += sparkColor * sparkMask;
    
    // glow
    finalColor.x = pow(finalColor.x, 0.7);
    finalColor.y = pow(finalColor.y, 0.7);
    finalColor.z = pow(finalColor.z, 0.7);
    
    // vignette
    vec2 edge = gl_FragCoord.xy / uResolution.xy;
    edge *= 1.0 - edge.yx;
    float vig = edge.x * edge.y * 5.0;
    vig = pow(vig, 0.2);
    finalColor *= vig;
    
    outColor = vec4(finalColor, 1.0);
    //outColor = vec4(vec3(sparkMask), 1.0);
}