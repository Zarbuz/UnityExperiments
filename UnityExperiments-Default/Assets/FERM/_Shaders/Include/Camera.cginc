#ifndef CAMERA_CGINC
#define CAMERA_CGINC

inline float3 GetCameraPosition()    { return _WorldSpaceCameraPos;      }
inline float3 GetCameraForward()     { return -UNITY_MATRIX_V[2].xyz;    }
inline float3 GetCameraUp()          { return UNITY_MATRIX_V[1].xyz;     }
inline float3 GetCameraRight()       { return UNITY_MATRIX_V[0].xyz;     }
inline float  GetCameraFocalLength() { return abs(UNITY_MATRIX_P[1][1]); }
inline float  GetCameraNearClip()    { return _ProjectionParams.y;       }
inline float  GetCameraFarClip()     { return _ProjectionParams.z;       }
inline bool   IsCameraPerspective()  { return any(UNITY_MATRIX_P[3].xyz); }
inline bool   IsCameraOrtho()        { return !IsCameraPerspective(); }
inline float2 GetCameraSize()        { return float2(unity_OrthoParams.y, unity_OrthoParams.y); }
inline float3x3 GetCameraRotation()  { return transpose(float3x3(GetCameraRight(), GetCameraUp(), GetCameraForward())); } 

//camera functions transform normalized offset values to physical screen positions

inline float2 GetNormalizedScreenPosition(float4 projPos)
{
    return (projPos.xy - 0.5) * 2.0 / projPos.w;
}

inline float2 GetAspectedScreenPosition(float4 projPos)
{
    float2 sp = GetNormalizedScreenPosition(projPos);
    sp.x *= _ScreenParams.x / _ScreenParams.y;
    return sp;
}

inline float3 GetCameraPerspDirection(float4 projPos)
{
    float2 sp = GetAspectedScreenPosition(projPos);
    float3 camDir = GetCameraForward();
    float3 camUp = GetCameraUp();
    float3 camSide = GetCameraRight();
    float  focalLen = GetCameraFocalLength();
    return normalize((camSide * sp.x) + (camUp * sp.y) + (camDir * focalLen));
}

inline float GetDistanceFromCameraToNearClipPlane(float4 projPos)
{
    float2 sp = GetAspectedScreenPosition(projPos);
    float3 norm = normalize(float3(sp, GetCameraFocalLength()));
    return GetCameraNearClip() / norm.z;
}

inline float3 GetCameraOrthoOffset(float4 projPos)
{
    float2 sp = GetAspectedScreenPosition(projPos);
    float3 camUp = GetCameraUp();
    float3 camSide = GetCameraRight();
    float2 camSize = GetCameraSize();
    return (camSide * sp.x * camSize.x) + (camUp * sp.y * camSize.y);
}

inline float3 GetCamera360Direction(float4 projPos)
{
    float2 sp = GetNormalizedScreenPosition(projPos);
	float3 sphere = float3(1.0, 0.0, 0.0);
	sphere.y = sp.y * PI * 0.5;
	sphere.z = sp.x * PI;
    return mul(GetCameraRotation(), SphereToCart(sphere)); 
}

#endif
