#version 150

#extension GL_ARB_shading_language_include : require
#include <EmitterParams.h>
#include <Globals.h>
uniform vec4 CB1[4];
uniform vec4 CB0[53];
in vec3 POSITION;
in vec4 TEXCOORD1;
in vec2 TEXCOORD2;
in vec4 TEXCOORD3;
in vec2 TEXCOORD4;
out vec3 VARYING0;
out vec4 VARYING1;
out vec2 VARYING2;

void main()
{
    vec2 v0 = (TEXCOORD2 * 2.0) - vec2(1.0);
    vec4 v1 = TEXCOORD1 * vec4(0.00390625, 0.00390625, 0.00019175345369148999452590942382813, 3.0518509447574615478515625e-05);
    vec2 v2 = v1.xy + vec2(127.0);
    float v3 = v1.z;
    float v4 = cos(v3);
    float v5 = sin(v3);
    float v6 = v2.x;
    vec4 v7 = vec4(0.0);
    v7.x = v4 * v6;
    vec4 v8 = v7;
    v8.y = (-v5) * v6;
    float v9 = v2.y;
    vec4 v10 = v8;
    v10.z = v5 * v9;
    vec4 v11 = v10;
    v11.w = v4 * v9;
    vec4 v12 = (vec4(POSITION, 1.0) + (CB0[4] * dot(v0, v11.xy))) + (CB0[5] * dot(v0, v11.zw));
    vec4 v13 = v12 + (CB0[6] * CB1[1].x);
    mat4 v14 = mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec4 v15 = v12 * v14;
    vec3 v16 = vec3(TEXCOORD2.x, TEXCOORD2.y, vec3(0.0).z);
    v16.y = 1.0 - TEXCOORD2.y;
    vec3 v17 = v16;
    v17.z = length(CB0[7].xyz - v13.xyz);
    vec4 v18 = v13 * v14;
    vec4 v19 = v15;
    v19.z = (v18.z * v15.w) / v18.w;
    vec2 v20 = (TEXCOORD4 + ((TEXCOORD2 * (CB1[2].z - 1.0)) + vec2(0.5))) * CB1[2].xy;
    vec2 v21 = v20;
    v21.y = 1.0 - v20.y;
    gl_Position = v19;
    VARYING0 = v17;
    VARYING1 = TEXCOORD3 * 0.0039215688593685626983642578125;
    VARYING2 = v21;
}

