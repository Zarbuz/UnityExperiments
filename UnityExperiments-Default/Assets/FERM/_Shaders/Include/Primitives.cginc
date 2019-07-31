#ifndef PRIMITIVES_CGINC
#define PRIMITIVES_CGINC

inline float Sphere(float3 pos, float radius)
{
    return length(pos) - radius;
}

inline float RoundedBox(float3 pos, float3 size, float round)
{
	float3 d = abs(pos) - size/2.0;
    return length(max(d + round, 0.0)) - round;
}

inline float Box(float3 pos, float3 size)
{
    float3 d = abs(pos) - size/2.0;
	return length(max(d, 0.0)) + min(max(d.x,max(d.y, d.z)), 0.0);
}

inline float Torus(float3 pos, float2 radius)
{
    float2 r = float2(length(pos.xz) - radius.x, pos.y);
    return length(r) - radius.y;
}

inline float Plane(float3 pos, float thickness)
{
    return abs(pos.y) - thickness;
}

inline float Cylinder(float3 pos, float2 r)
{
    float2 d = abs(float2(length(pos.xz), pos.y)) - r;
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - 0.01;
}

inline float Capsule(float3 p, float h, float r)
{
	h -= 2*r;
    p.y -= clamp( p.y, -h/2.0, h/2.0 );
    return length( p ) - r;
}

inline float InfinitePipe (float3 pos, float r1, float r2)
{
	float r = length(pos.xz);
	return (abs(2*r - r1 - r2) + r1 - r2)/2.0;
	
}

inline float Pipe (float3 pos, float r1, float r2, float len){
	float r = length(pos.xz);
	float y = abs(pos.y) - len/2.0;

	if(y < 0)
		return (InfinitePipe(pos,r1,r2));
	if(r > r2)
		return(length(float2(r-r2,y)));
	if(r < r1)
		return(length(float2(r1-r,y)));
	return y;
}

inline float Octahedron( float3 p, float s)
{
    p = abs(p);
    float m = p.x+p.y+p.z-s;
    float3 q;
         if( 3.0*p.x < m ) q = p.xyz;
    else if( 3.0*p.y < m ) q = p.yzx;
    else if( 3.0*p.z < m ) q = p.zxy;
    else return m*0.57735027;
    
    float k = clamp(0.5*(q.z-q.y+s),0.0,s); 
    return length(float3(q.x,q.y-s+k,q.z-k)); 
}

inline float HexPrism(float3 pos, float size, float height)
{
    float3 p = abs(pos);
    return max(
        p.y - height/2.0, 
        max(
            (p.z * 0.866025 + p.x * 0.5),
            p.x
        ) - size
    );
}

 inline	float TriPrism( float3 p, float size, float height)
{
    float3 q = abs(p);
    return max(q.y-height/2.0,max(q.x*0.866025+p.z*0.5,-p.z)-size*0.5);
}

inline float Tetrahedron(float3 p, float size)
{
	p /= size;
	
	p = Mirror(p, float3(.37, 1.0, .622));
	p = Mirror(p, float3(.37, 1.0, -.622));
	p = Mirror(p, float3(-1.0, 1.414, 0.0));
	
	float3 v1 = float3(.9428, -.3333, 0.0);
	float3 v2 = float3(-.4714, -.3333, .8165);
	float3 v3 = float3(-.4714, -.3333, -.8165);
	
	return Triangle(p,v1,v2,v3) * size;
}

inline float InfiniteCylinder(float3 pos, float radius)
{
    return length(pos.xz) - radius;
}

inline float RoundedCylinder(float3 p, float radius, float smooth, float h)
{
    float2 d = float2( length(p.xz)-radius+smooth, abs(p.y) - h/2.0 );
    return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - smooth;
}

inline float InfiniteCone( float3 p, float slope )
{
	float2 c = normalize(float2(slope, 1));
    float q = length(p.xz);
    return dot(c, float2(q,p.y));
}

inline float Cone( float3 p, float slope, float l)
{
	if(p.y > -l)
		return InfiniteCone(p, slope);
	else{
		float r = length(p.xz);
		float R = l/slope;
		if(r > R)
			return length(float2(r-R, p.y + l));
		return - p.y - l;
	}
}

inline float CappedCone(float3 p, float r1, float r2, float h)
{
    float2 q = float2( length(p.xz), p.y );
    
    float2 k1 = float2(r2,h/2.0);
    float2 k2 = float2(r2-r1,h);
    float2 ca = float2(q.x-min(q.x,(q.y < 0.0)?r1:r2), abs(q.y)-h/2.0);
    float2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot2(k2), 0.0, 1.0 );
    float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return s*sqrt( min(dot2(ca),dot2(cb)) );
}

inline float RoundedCone(float3 p, float r1, float r2, float h)
{
    float2 q = float2( length(p.xz), p.y );
	h /= 2.0;
    
    float b = (r1-r2)/h;
    float a = sqrt(1.0-b*b);
    float k = dot(q,float2(-b,a));
    
    if( k < 0.0 ) return length(q) - r1;
    if( k > a*h ) return length(q-float2(0.0,h)) - r2;
        
    return dot(q, float2(a,b) ) - r1;
}

inline float Ellipsoid(float3 p, float3 r) // Should have more params, more freedomses. 
{
    float k0 = length(p/r);
    float k1 = length(p/(r*r));
    return k0*(k0-1.0)/k1;
}

inline float InfinitePyramid(float3 pos, float2 slope)
{
	float3 xn = normalize(float3(slope.x, 1.0, 0.0));
	float3 yn = normalize(float3(0.0, 1.0, slope.y));
	float3 p = float3(abs(pos.x), pos.y, abs(pos.z));
	return max(dot(xn, p), dot(yn, p));
}

inline float Pyramid(float3 pos, float2 slope, float l)
{
	return max(InfinitePyramid(pos, slope), - l - pos.y);
}

inline float Arch(float3 pos, float3 size, float radius, float height)
{
	float3 ps = pos - float3(0.0, (height - size.y)/2.0, 0.0);
	float3 h = float3(0.0, height, size.z);
	return max( -Sphere(Elongate(ps, h), radius), Box(pos, size));
}



#endif
