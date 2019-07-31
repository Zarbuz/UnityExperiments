#ifndef RAYMARCHING_CGINC
#define RAYMARCHING_CGINC

#include "UnityCG.cginc"
#include "./Camera.cginc"
#include "./Utils.cginc"

float _Qx, _Qy, _Qz, _Qr, _Qs;

#ifndef DISTANCE_FUNCTION

inline float _DefaultDistanceFunction(RaymarchInfo ray)
{
    return Box(ray.endPos, 1.0);
}
#define DISTANCE_FUNCTION _DefaultDistanceFunction
#endif

inline float _DistanceFunction(float3 pos, float3 dir)
{
    float R = _Qr + 1;
    if(length(pos) > R)
        return SphereDirect(pos, dir, R - 1);
    return DISTANCE_FUNCTION(pos, dir);
}

inline float3 GetDistanceFunctionNormal(RaymarchInfo ray)
{
    const float d = ray.minDistance;
	const float3 pos = ray.endPos - ray.rayDir*d;
	const float3 dir = ray.rayDir;
	
    return normalize(float3(
        _DistanceFunction(pos + float3(d, 0, 0), dir) - _DistanceFunction(pos, dir),
        _DistanceFunction(pos + float3(0, d, 0), dir) - _DistanceFunction(pos, dir),
        _DistanceFunction(pos + float3(0, 0, d), dir) - _DistanceFunction(pos, dir)));
}

inline bool StopCondition(RaymarchInfo ray)
{
	return ray.lastDistance  < ray.minDistance * ray.totalLength;
}

inline bool _ShouldRaymarchFinish(RaymarchInfo ray)
{
    return StopCondition(ray) || ray.totalLength > ray.maxDistance;
}

inline void InitRaymarchFullScreen(out RaymarchInfo ray, float4 projPos)
{
    UNITY_INITIALIZE_OUTPUT(RaymarchInfo, ray);
    ray.totalLength = GetCameraNearClip() / _t_scale;
    ray.maxDistance = GetCameraFarClip();
    
    float3 cameraPos = float3(0.0, 0.0, 0.0);
	
	//depth and position switch
    
#if defined(USING_STEREO_MATRICES)
	//Stereoscopic view for VR: shift position according to which eye is rendering
    cameraPos = unity_StereoWorldSpaceCameraPos[unity_StereoEyeIndex];
    cameraPos += float3(1., 0, 0) * unity_StereoEyeIndex;
#elif defined(SKYBOX_MODE)
    //skybox perspective mode
    ray.totalLength = 0.0;
#else
    //normal mode
    cameraPos = InverseTransform(_t_position, _t_rotation, _t_scale, _WorldSpaceCameraPos);
#endif


	//camera projection switch

#if defined(EQUIRECT_360_MODE)
	//360 degree capture: cylinder projection
	ray.rayDir = InverseRotate(_t_rotation, GetCamera360Direction(projPos));
	ray.startPos = cameraPos + ray.totalLength * ray.rayDir;
	
#else
	if(IsCameraOrtho())
    {
		ray.rayDir = InverseRotate(_t_rotation, GetCameraForward());
		float3 offset = GetCameraOrthoOffset(projPos);
		offset = InverseTransform(float3(0.0,0.0,0.0), _t_rotation, _t_scale, offset);
        ray.startPos = cameraPos + ray.totalLength * ray.rayDir + offset;
    }
    else if(IsCameraPerspective())
    {
        ray.rayDir = InverseRotate(_t_rotation, GetCameraPerspDirection(projPos));
		ray.startPos = cameraPos + ray.totalLength * ray.rayDir;
    }
#endif	
	
	
}

inline void InitRaymarchObject(out RaymarchInfo ray, float4 projPos, float3 worldPos, float3 worldNormal)
{
    UNITY_INITIALIZE_OUTPUT(RaymarchInfo, ray);
    ray.rayDir = normalize(worldPos - GetCameraPosition());
    ray.startPos = worldPos;
    ray.polyNormal = worldNormal;
    ray.maxDistance = GetCameraFarClip();

#ifdef CAMERA_INSIDE_OBJECT
    float3 startPos = GetCameraPosition() + GetDistanceFromCameraToNearClipPlane(projPos) * ray.rayDir;
    if (IsInnerObject(startPos)) {
        ray.startPos = startPos;
        ray.polyNormal = -ray.rayDir;
    }
#endif
}

inline void InitRaymarchParams(inout RaymarchInfo ray, int maxLoop, float minDistance)
{
    ray.maxLoop = maxLoop;
    ray.minDistance = minDistance;
}

#ifdef USE_CAMERA_DEPTH_TEXTURE
UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

inline void UseCameraDepthTextureForMaxDistance(inout RaymarchInfo ray, float4 projPos)
{
    float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(projPos)));
    float dist = depth / dot(ray.rayDir, GetCameraForward());
    ray.maxDistance = dist;
}
#endif

#define INITIALIZE_RAYMARCH_INFO(ray, i, loop, minDistance) \
    InitRaymarchFullScreen(ray, i.projPos); \
    InitRaymarchParams(ray, loop, minDistance);

inline bool _Raymarch(inout RaymarchInfo ray)
{
    ray.endPos = ray.startPos;
    ray.lastDistance = 0.0;
	float rayScale = Q_overSample(_Qz);
	ray.minDistance *= rayScale;

    for (ray.loop = 0; ray.loop < ray.maxLoop; ++ray.loop) {
        ray.lastDistance = rayScale * _DistanceFunction(ray.endPos, ray.rayDir);
        ray.totalLength += ray.lastDistance;
        ray.endPos += ray.rayDir * ray.lastDistance;
        if (_ShouldRaymarchFinish(ray)){
            break;
        }
    }
	
    return StopCondition(ray);
}

void Raymarch(inout RaymarchInfo ray)
{
    if (!_Raymarch(ray)) discard;

    float3 normal = Rotate(_t_rotation, GetDistanceFunctionNormal(ray));
    ray.normal = EncodeNormal(normal);
    ray.depth = EncodeDepth(Transform(_t_position, _t_rotation, _t_scale, ray.endPos));
    return;

#ifdef CAMERA_INSIDE_OBJECT
    if (IsInnerObject(GetCameraPosition()) && ray.totalLength < GetCameraNearClip()) {
        ray.normal = EncodeNormal(-ray.rayDir);
        ray.depth = EncodeDepth(ray.startPos);
        return;
    }
#endif

    float initLength = length(ray.startPos - GetCameraPosition());
    if (ray.totalLength - initLength < ray.minDistance) {
        ray.normal = EncodeNormal(ray.polyNormal);
        ray.depth = EncodeDepth(ray.startPos) - 1e-6;
    } else {
        float3 normal = GetDistanceFunctionNormal(ray);
        ray.normal = EncodeNormal(normal);
        ray.depth = EncodeDepth(ray.endPos);
    }
}

#endif
