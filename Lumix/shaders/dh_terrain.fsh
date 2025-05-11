#version 410 compatibility

uniform sampler2D lightmap;
uniform sampler2D depthtex0;

uniform float viewWidth;
uniform float viewHeight;

uniform vec3 fogColor;

uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;
uniform vec3 geoNormal;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;

in vec4 blockColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;

void main()
{

    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);

    vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * geoNormal;

    float lightBrightness = clamp(dot(shadowLightDirection, worldGeoNormal), 0.2, 1.0);

    vec3 lightColor = pow(texture(lightmap, lightMapCoords).rgb, vec3(2.2));

    vec4 outputColorData = blockColor;
    vec3 outputColor = outputColorData.rgb * lightColor;
    float transparency = outputColorData.a;
    if (transparency < .1)
    {
        discard;
    }

    vec2 texCoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    float depth = texture(depthtex0, texCoord).r;
    if (depth != 1.0)
    {
        discard;
    }

    float distanceFromCamera = distance(vec3(0), viewSpacePosition);

    float maxFogDistance = 4000.0; // Example value, adjust as needed
    float minFogDistance = 2500.0; // Example value, adjust as needed

    outputColor *= lightBrightness;

    float fogBlendValue = clamp((distanceFromCamera - minFogDistance) / (maxFogDistance - minFogDistance),0,1);

    outputColor = mix(outputColor, pow(fogColor, vec3(2.2)), fogBlendValue);

    outColor0 = pow(vec4(outputColor, transparency), vec4(1 / 2.2));
}