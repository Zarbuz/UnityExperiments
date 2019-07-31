int _UVMode = 0;

inline float2 Radial(float3 p) {
	return float2(length(p), 0.0);
}

inline float2 SphereUV(float3 p) {
    return float2(.5 + (.5/PI)*atan2(p.z, p.x), 1.0 - (1.0/PI)*acos(p.y/length(p)));
}

inline float2 CylinderUV(float3 p) {
    return float2(.5 + (.5/PI)*atan2(p.z, p.x), p.y);
}

inline float2 GetUV(RaymarchInfo ray)
{
    float3 p = ray.endPos;
    float2 uv = float2(0,0);
    switch(_UVMode){
		case 0: uv = p.xz; break;
        case 1: uv = p.xy; break;
        case 2: uv = p.yz; break;
        case 3: uv = SphereUV(p); break;
        case 4: uv = CylinderUV(p); break;
		case 5: uv = Radial(p); break;
    }
    return uv;
}

