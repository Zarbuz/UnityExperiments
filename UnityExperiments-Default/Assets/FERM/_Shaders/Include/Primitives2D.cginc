#ifndef PRIMITIVES2D_CGINC
#define PRIMITIVES2D_CGINC

inline float Circle(float2 p, float radius)
{
	return length(p) - radius;
}

inline float Circle(float3 p, float radius)
{
	return FlatDistance(p, Circle(p.xz, radius));
}

inline float Polygon(float2 p, float radius, int sides)
{
	float ang = PI/sides;
	float theta = Mod(atan2(p.y, p.x) + PI, ang*2.0) - ang;
	return (length(p) * cos(theta)) - (radius * cos(ang));
}

inline float Polygon(float3 p, float radius, int sides)
{
	return FlatDistance(p, Polygon(p.xz, radius, sides));
}

inline float Rouleaux(float2 p, float radius, int sides)
{
	float ang = PI/sides;
	float theta = Mod(atan2(p.y, p.x) + PI, ang*2.0) - ang;
	float2 c = length(p) * float2(cos(theta), sin(theta)) + float2(radius/2.0, 0);
	return length(c) - radius;
}

inline float Rouleaux(float3 p, float radius, int sides)
{
	return FlatDistance(p, Rouleaux(p.xz, radius, sides));
}

inline float Spiral(float2 p, float spacing, float thickness, float radius)
{
	float theta = atan2(p.y, p.x);
	float r = Mod(length(p) + spacing*theta/(2*PI), spacing);
	return max(min(r, spacing - r) - thickness/2.0, length(p) - radius);
}

inline float Spiral(float3 p, float spacing, float thickness, float radius)
{
	return FlatDistance(p, Spiral(p.xz, spacing, thickness, radius));
}

inline float Triangle( float3 p, float3 a, float3 b, float3 c )
{
    float3 ba = b - a; float3 pa = p - a;
    float3 cb = c - b; float3 pb = p - b;
    float3 ac = a - c; float3 pc = p - c;
    float3 nor = cross( ba, ac );

    return sqrt(
    (sign(dot(cross(ba,nor),pa)) +
     sign(dot(cross(cb,nor),pb)) +
     sign(dot(cross(ac,nor),pc))<2.0)
     ?
     min( min(
     dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
     dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
     dot2(ac*clamp(dot(ac,pc)/dot2(ac),0.0,1.0)-pc) )
     :
     dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}

inline float Triangle(float3 p, float2 a, float2 b, float2 c)
{
	return Triangle(p, 
		float3(a.x, 0.0, a.y), 
		float3(b.x, 0.0, b.y), 
		float3(c.x, 0.0, c.y));
}

float Quad(float2 pos, float2 size, float round)
{
	return length(max(abs(pos) - size/2.0 + round, 0.0)) - round;
}

float Quad(float3 pos, float2 size, float round)
{
	return FlatDistance(pos, Quad(pos.xz, size, round));
}

float Quad( float3 p, float3 a, float3 b, float3 c, float3 d )
{
    float3 ba = b - a; float3 pa = p - a;
    float3 cb = c - b; float3 pb = p - b;
    float3 dc = d - c; float3 pc = p - c;
    float3 ad = a - d; float3 pd = p - d;
    float3 nor = cross( ba, ad );

    return sqrt(
    (sign(dot(cross(ba,nor),pa)) +
     sign(dot(cross(cb,nor),pb)) +
     sign(dot(cross(dc,nor),pc)) +
     sign(dot(cross(ad,nor),pd))<3.0)
     ?
     min( min( min(
     dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
     dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
     dot2(dc*clamp(dot(dc,pc)/dot2(dc),0.0,1.0)-pc) ),
     dot2(ad*clamp(dot(ad,pd)/dot2(ad),0.0,1.0)-pd) )
     :
     dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}

inline float Line(float2 p, float length)
{
	float2 l = float2(length, 0.0);
	return Quad(p - l/2.0, l, 0.0);
}

inline float Sector(float2 p, float radius, float angle)
{
	float theta = abs(atan2(p.y, p.x));
	angle *= PI/360.0;
	if(abs(theta) < angle)
		return length(p) - radius;
	theta -= angle;
	p = length(p) * float2(cos(theta), sin(theta));
	return Line(p, radius);
}

inline float Sector(float3 p, float radius, float angle)
{
	return FlatDistance(p, Sector(p.xz, radius, angle));
}


#endif
