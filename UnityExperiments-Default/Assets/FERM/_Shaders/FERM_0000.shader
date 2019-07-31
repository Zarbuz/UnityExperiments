Shader "FERM/FERM_0000"
{


/*
 * -------------------------------------------------------------------------
 * ----------------------------- PROPERTIES --------------------------------
 * -------------------------------------------------------------------------
 */

 

Properties
{
    [HideInInspector] [Enum(UnityEngine.Rendering.CullMode)] _Cull("Culling", Int) = 2
	[HideInInspector] [Toggle][KeyEnum(Off, On)] _ZWrite("ZWrite", Float) = 1
     
    [Header(Raymarching)]
    _Qx("Quality factor", Range(-1,1)) = 0 
    _Qy("Cutoff factor", Range(-1,1)) = 0
	_Qz("Oversample factor", Range(0,1)) = 0
    _Qr("Render radius", Float) = 10000
	
	[Header(Standard shader)]
	_ShadowLoop("Shadow Loop", Range(1, 100)) = 30
    _ShadowMinDistance("Shadow Minimum Distance", Range(0.001, 0.1)) = 0.01
    _ShadowExtraBias("Shadow Extra Bias", Range(0.0, 1.0)) = 0.0
    
    [Header(Surface)]
	_MainColor("Color", Color) = (1, 1, 1, 1)
    _MainTex ("Texture", 2D) = "white" {}
    [Enum(XZ,0,XY,1,YZ,2,Sphere,3,Cylinder,4,Radial,5)] _UVMode ("UV mode", Int) = 0
	_SurfaceMetallic("Metallic", Range(0,1)) = .5 
	_SurfaceSmoothness("Smoothness", Range(0,1)) = .5 
}


SubShader
{

Tags
{
    "RenderType" = "Opaque"
    "Queue" = "Geometry"
    "DisableBatching" = "True"
}

Cull [_Cull]
CGINCLUDE

//#options
#define USE_RAYMARCHING_DEPTH
#define SUPERSAMPLING_1X

//#

#include "Include/Common.cginc"

/*
 * -------------------------------------------------------------------------
 * ------------------------- DISTANCE ESTIMATOR ----------------------------
 * -------------------------------------------------------------------------
 */

uniform float3 _t_position; 
uniform float4 _t_rotation;
uniform float _t_scale;

//#parameters
float par0;
float3 par1;
float4 par2;
float par3;
float3 par4;
float4 par5;
float par6;
float3 par7;
float par8;

//#

//#helpers

//#

#define DISTANCE_FUNCTION DistanceFunction
inline float DistanceFunction(float3 pos, float3 dir) 
{
	//#function
return Difference((Sphere(InverseTransform(par1, par2, par3, pos), par0) * par3), (SymmetricOrigins(InverseTransform(par4, par5, par6, Mirror(pos, par7, par8))) * par6));
//#
}


/*
 * -------------------------------------------------------------------------
 * ---------------------------- POST EFFECT --------------------------------
 * -------------------------------------------------------------------------
 */

#define POST_EFFECT PostEffect

fixed4 _MainColor;
sampler2D _MainTex;
float4 _MainTex_ST;

fixed4 _SurfaceColor;
half _SurfaceMetallic, _SurfaceSmoothness;
#define PostEffectOutput SurfaceOutputStandard 
inline void PostEffect(RaymarchInfo ray, inout PostEffectOutput o)
{
    o.Occlusion = GoldInverse(1.0 * ray.loop / ray.maxLoop);
    float2 uv = TRANSFORM_TEX(GetUV(ray), _MainTex);
    o.Albedo = _MainColor * tex2D(_MainTex, uv);
	o.Metallic = _SurfaceMetallic;
	o.Smoothness = _SurfaceSmoothness;
}


ENDCG

Pass
{
    Tags { "LightMode" = "ForwardBase" }

    ZWrite [_ZWrite]

    CGPROGRAM
    #include "Include/ForwardBaseStandard.cginc"
    #pragma target 3.0
    #pragma vertex Vert
    #pragma fragment Frag
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma multi_compile_fwdbase
    ENDCG
}

Pass
{
    Tags { "LightMode" = "ForwardAdd" }
    ZWrite Off 
    Blend One One

    CGPROGRAM
    #include "Include/ForwardAddStandard.cginc"
    #pragma target 3.0
    #pragma vertex Vert
    #pragma fragment Frag
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma skip_variants INSTANCING_ON
    #pragma multi_compile_fwdadd_fullshadows
    ENDCG
}

Pass
{
    Tags { "LightMode" = "ShadowCaster" }

    CGPROGRAM
    #include "Include/ShadowCaster.cginc"
    #pragma target 3.0
    #pragma vertex Vert
    #pragma fragment Frag
    #pragma fragmentoption ARB_precision_hint_fastest
    #pragma multi_compile_shadowcaster
    ENDCG
}


} Fallback Off 

}