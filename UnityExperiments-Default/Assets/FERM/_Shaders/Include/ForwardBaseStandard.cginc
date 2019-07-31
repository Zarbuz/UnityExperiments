#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

#include "./Structs.cginc"
#include "./Raymarching.cginc"
#include "./Utils.cginc"

fixed4 _Color;
float _Glossiness;
float _Metallic;

FragOutput FragOne(Vert2Frag i)
{
    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    RaymarchInfo ray;
    float loop = Q_loop(_Qx, _Qy, _Qz);
    float minDistance = Q_minDistance(_Qx, _Qy);
    INITIALIZE_RAYMARCH_INFO(ray, i, loop, minDistance);
    Raymarch(ray);

    float3 worldPos = ray.endPos;
    float3 worldNormal = 2.0 * ray.normal - 1.0;
    fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
#ifdef USING_DIRECTIONAL_LIGHT
    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#else
    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
#endif

    SurfaceOutputStandard so;
    UNITY_INITIALIZE_OUTPUT(SurfaceOutputStandard, so);
    so.Albedo = _Color.rgb;
    so.Metallic = _Metallic;
    so.Smoothness = _Glossiness;
    so.Emission = 0.0;
    so.Alpha = 1.0;
    so.Occlusion = 1.0;
    so.Normal = worldNormal;

#ifdef POST_EFFECT
    POST_EFFECT(ray, so);
#endif

    UNITY_LIGHT_ATTENUATION(atten, i, worldPos)

    UnityGI gi;
    UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
    gi.indirect.diffuse = 0;
    gi.indirect.specular = 0;
    gi.light.color = _LightColor0.rgb;
    gi.light.dir = lightDir;

    UnityGIInput giInput;
    UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
    giInput.light = gi.light;
    giInput.worldPos = worldPos;
    giInput.worldViewDir = worldViewDir;
    giInput.atten = atten;

#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    giInput.lightmapUV = i.lmap;
#else
    giInput.lightmapUV = 0.0;
#endif

#if UNITY_SHOULD_SAMPLE_SH
    #ifdef SPHERICAL_HARMONICS_PER_PIXEL
    giInput.ambient = ShadeSHPerPixel(worldNormal, 0.0, worldPos);
    #else
    giInput.ambient.rgb = i.sh;
    #endif
#else
    giInput.ambient.rgb = 0.0;
#endif

    giInput.probeHDR[0] = unity_SpecCube0_HDR;
    giInput.probeHDR[1] = unity_SpecCube1_HDR;

#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
    giInput.boxMin[0] = unity_SpecCube0_BoxMin;
#endif

#ifdef UNITY_SPECCUBE_BOX_PROJECTION
    giInput.boxMax[0] = unity_SpecCube0_BoxMax;
    giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
    giInput.boxMax[1] = unity_SpecCube1_BoxMax;
    giInput.boxMin[1] = unity_SpecCube1_BoxMin;
    giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
#endif

    float4 color = 0.0;
    //LightingStandard_GI(so, giInput, gi);
    color += LightingStandard(so, worldViewDir, gi);
    color.rgb += so.Emission + unity_AmbientSky * so.Albedo;

    FragOutput o;
    UNITY_INITIALIZE_OUTPUT(FragOutput, o);
    o.color = color;
#ifdef USE_RAYMARCHING_DEPTH
    o.depth = ray.depth;
#endif

#if (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
    i.fogCoord.x = mul(UNITY_MATRIX_VP, float4(ray.endPos, 1.0)).z;
#endif
    UNITY_APPLY_FOG(i.fogCoord, o.color);

    return o;
}


#include "./Sample.cginc"
