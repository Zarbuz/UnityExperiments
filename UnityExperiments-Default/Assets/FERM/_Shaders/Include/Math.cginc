#ifndef MATH_CGINC
#define MATH_CGINC

#define PI 3.14159265358979

float Rand(float2 seed)
{
    return frac(sin(dot(seed, float2(12.9898, 78.233))) * 43758.5453);
}

inline float Mod(float a, float b)
{
    return frac(abs(a / b)) * abs(b);
}

inline float2 Mod(float2 a, float2 b)
{
    return frac(abs(a / b)) * abs(b);
}

inline float3 Mod(float3 a, float3 b)
{
    return frac(abs(a / b)) * abs(b);
}

inline float Rep(float a, float b)
{   
    float t = frac(a / b);
    t += -0.5 * (abs(t) / t - 1);
    return t * abs(b);
}

inline float2 Rep(float2 a, float2 b)
{
    float2 t = frac(a / b);
    t += -0.5 * (abs(t) / t - 1);
    return t * abs(b);
}

inline float3 Rep(float3 a, float3 b)
{
    float3 t = frac(a / b);
    t += -0.5 * (abs(t) / t - 1);
    return t * abs(b);
}

inline float SmoothMin(float d1, float d2, float k)
{
    float h = exp(-k * d1) + exp(-k * d2);
    return -log(h) / k;
}

inline float Union( float d1, float d2 ) { return min(d1,d2); }

inline float Difference( float d1, float d2 ) { return max(-d1,d2); }

inline float Intersect( float d1, float d2 ) { return max(d1,d2); }

inline float SmoothUnion( float d1, float d2, float k ) 
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) - k*h*(1.0-h); 
}

inline float SmoothDifference( float d1, float d2, float k ) 
{
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return lerp( d2, -d1, h ) + k*h*(1.0-h); 
}

inline float SmoothIntersect( float d1, float d2, float k ) 
{
    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) + k*h*(1.0-h); 
}

inline float DeformedMix( float d1, float d2, float k, float f, float a, float p) 
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
	h = h + a*(h - h*h)*sin((f*h*k + p) * 3.14);
    return lerp( d2, d1, h ) - k*h*(1.0-h); 
}

inline float3 ModuloX(float3 pos, float span)
{
    float x = Mod(pos.x, span);
	return float3(x, pos.y, pos.z);
}

inline float3 ModuloXZ(float3 pos, float2 span)
{
    float2 xz = Mod(pos.xz, span);
	return float3(xz.x, pos.y, xz.y);
}

inline float3 Modulo(float3 pos, float3 span)
{
    return Mod(pos, span);
}

inline float3 RepeatX(float3 pos, float span)
{
    float x = Rep(pos.x + .5*span, span) - .5*span;
	return float3(x, pos.y, pos.z);
}

inline float3 RepeatXZ(float3 pos, float2 span)
{
    float2 xz = Rep(pos.xz + .5*span, span) - .5*span;
	return float3(xz.x, pos.y, xz.y);
}

inline float3 Repeat(float3 pos, float3 span)
{
    return Rep(pos + .5*span, span) - .5*span;
}

inline float GoldInverse(float x)
{
    return 1.0 / (.618 + x) - .618;
}

inline float4 MulQuat(float4 q1, float4 q2) 
{
    return float4(
        q1.x * q2.w + q1.y * q2.z - q1.z * q2.y + q1.w * q2.x,
		-q1.x * q2.z + q1.y * q2.w + q1.z * q2.x + q1.w * q2.y,
		q1.x * q2.y - q1.y * q2.x + q1.z * q2.w + q1.w * q2.z,
		-q1.x * q2.x - q1.y * q2.y - q1.z * q2.z + q1.w * q2.w
    );
}

inline float4 InvertQuat(float4 q)
{
	return float4(-q.x, -q.y, -q.z, q.w);
}

inline float3 Rotate(float4 q, float3 vec)
{
	float4 qv = MulQuat(q, float4(vec, 0.0));
	return MulQuat(qv, InvertQuat(q)).xyz;
}

inline float3 InverseRotate(float4 q, float3 vec)
{
	return Rotate(InvertQuat(q), vec);
}

inline float3 Transform(float3 pos, float4 rot, float scale, float3 vec)
{
	return pos + Rotate(rot, scale * vec);
}

inline float3 InverseTransform(float3 pos, float4 rot, float scale, float3 vec)
{
	return InverseRotate(rot, (vec - pos)) / scale;
}

inline float3 Scale(float3 scale, float3 vec)
{
	return float3(scale.x * vec.x, scale.y * vec.y, scale.z * vec.z);
}

inline float3 InverseScale(float3 scale, float3 vec)
{
	return float3(vec.x/scale.x, vec.y/scale.y, vec.z/scale.z);
}

inline float Wobble(float3 freq, float scale, float3 vec)
{
	return cos(freq.x*vec.x)*cos(freq.y*vec.y)*cos(freq.z*vec.z)*scale;
}

inline float dot2(float3 v)
{
	return dot(v,v);
}

inline float dot2(float2 v)
{
	return dot(v,v);
}

inline float3 Mirror(float3 pos, float3 normal)
{
	float x = 2.0*dot(pos,normal)/dot2(normal);
	return pos - max(x, 0.0)*normal;
}

inline float3 Mirror(float3 pos, float3 normal, float d)
{
	normal = normalize(normal);
	float x = 2.0 * dot(pos - normal*d, normal);
	return pos - max(x, 0.0) * normal;
}

inline float SphereDirect(float3 pos, float3 dir, float r)
{
    float d = dot(pos, dir);
    
    if(d >= 0)
        return 1e+8;
        
    float p = length(pos);
    float discr = d*d - p*p + r*r;
    
    if(discr < 0)
        return 1e+8;
        
    return -d - sqrt(discr);
}

inline float3 Elongate(float3 p, float3 h)
{
    return p - clamp( p, -h/2.0, h/2.0 );
}

inline float2 CMul(float2 a, float2 b)
{
	return float2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x);
}

inline float4 AngleAxis(float3 axis, float angle)
{
	angle *= PI/360.0;
	float s = sin(angle);
	float c = cos(angle);
	return float4(axis.x*s, axis.y*s, axis.z*s, c);
}

inline float3 Twist(float3 p, float3 axis, float power)
{
	axis = normalize(axis);
	float angle = dot(p, axis) * power * 36.0;
	return Rotate(AngleAxis(axis, angle), p);
}

inline float3 Bend(float3 p, float3 axis, float3 direction, float power)
{
	direction = normalize(direction);
	float angle = dot(p, direction) * power * 36.0;
	axis = normalize(axis - dot(direction, axis)*direction);
    return Rotate(AngleAxis(axis, angle), p);
}

inline float3 Revolve(float3 p, float4 orientation)
{
	
	float3 axis = Rotate(orientation, float3(0.0, 0.0, 1.0));
	float3 projectDir = Rotate(orientation, float3(0.0, 1.0, 0.0));
	float3 sampleDir = Rotate(orientation, float3(1.0, 0.0, 0.0));
	
	float3 ax = dot(p,axis)*axis;
	
	float l = length(p - ax);
	return l*sampleDir + ax;
	
	
}

inline float3 Shear(float3 p, float xy, float xz, float yx, float yz, float zx, float zy)
{
	float3x3 m = float3x3(
		1.0, xy, xz,
		yx, 1.0, yz,
		zx, zy, 1.0);
	return mul(m, p);
}

inline float3 CartToSphere(float3 v)
{
	float r = length(v);
	float th = acos(v.y/r) - 0.5*PI;
	float phi = atan2(v.z, -v.x);
	return float3(r, th, phi);
}

inline float3 SphereToCart(float3 v)
{
	float3 s = float3(sin(v.z), sin(v.y), cos(v.z));
	s.xz *= cos(v.y);
	s *= v.x;
	return s;
}


#endif
