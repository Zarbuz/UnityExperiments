#ifndef STRUCTS_CGINC
#define STRUCTS_CGINC

struct GBufferOut
{
    half4 diffuse  : SV_Target0; // rgb: diffuse,  a: occlusion
    half4 specular : SV_Target1; // rgb: specular, a: smoothness
    half4 normal   : SV_Target2; // rgb: normal,   a: unused
    half4 emission : SV_Target3; // rgb: emission, a: unused
#ifdef USE_RAYMARCHING_DEPTH
    float depth    : SV_Depth;
#endif
};

struct RaymarchInfo
{
    // Input
    float3 startPos;
    float3 rayDir;
    float3 polyNormal;
    float minDistance;
    float maxDistance;
    int maxLoop;

    // Output
    int loop;
    float3 endPos;
    float lastDistance;
    float totalLength;
    float depth;
    float3 normal;
};


struct Vert2Frag {
	float4 pos : POSITION;
    float4 projPos : TEXCOORD0;
    float4 lmap : TEXCOORD1;
    //UNITY_SHADOW_COORDS(2)
    UNITY_FOG_COORDS(3)
#ifndef SPHERICAL_HARMONICS_PER_PIXEL
    #ifndef LIGHTMAP_ON
        #if UNITY_SHOULD_SAMPLE_SH
        half3 sh : TEXCOORD4;
        #endif
    #endif
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};


struct FragOutput
{
    float4 color : SV_Target;
#ifdef USE_RAYMARCHING_DEPTH
    float depth : SV_Depth;
#endif
};



#endif