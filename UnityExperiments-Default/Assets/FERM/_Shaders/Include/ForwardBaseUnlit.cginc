#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

#include "./Structs.cginc"
#include "./Raymarching.cginc"
#include "./Utils.cginc"

FragOutput FragOne(Vert2Frag i) {
	UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    RaymarchInfo ray;
    float loop = Q_loop(_Qx, _Qy, _Qz);
    float minDistance = Q_minDistance(_Qx, _Qy);
    INITIALIZE_RAYMARCH_INFO(ray, i, loop, minDistance);
    Raymarch(ray);

    FragOutput o;
    UNITY_INITIALIZE_OUTPUT(FragOutput, o);
    o.color = float4(0.0, 0.0, 0.0, 1.0);
#ifdef USE_RAYMARCHING_DEPTH
    o.depth = ray.depth;
#endif

#ifdef POST_EFFECT
    POST_EFFECT(ray, o.color);
#endif

#if (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
    i.fogCoord.x = mul(UNITY_MATRIX_VP, float4(ray.endPos, 1.0)).z;
#endif
    UNITY_APPLY_FOG(i.fogCoord, o.color);

    return o;
}


#include "./Sample.cginc" 
