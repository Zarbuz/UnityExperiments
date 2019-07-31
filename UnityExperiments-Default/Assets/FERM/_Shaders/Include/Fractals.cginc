#ifndef FRACTALS_CGINC
#define FRACTALS_CGINC

#include "./Utils.cginc"

inline float Mandelbulb(float3 p, int loop, float power)
{
    float3 z = p;
	float dr = 1.0;
	float r = 0.0;
	for (int i = 0; i < loop ; i++) {
        r = length(z);
        if(r > 10)
            break;

        // convert to polar coordinates
		float theta = acos(z.y/r);
		float phi = atan2(z.z, z.x) + PI/4;

		dr =  (pow(r, power-1.0)*power*dr) + 1.0;
		
		// scale and rotate the point
		float zr = pow(r, power);
		theta *= power;
		phi *= power;
		
		// convert back to cartesian coordinates
		z = zr*float3(sin(theta)*cos(phi), cos(theta), sin(theta)*sin(phi));
		z += p;
	}
	return 0.5*log(r)*r/dr;
}

inline float KochTetrahedron(float3 p, int loop)
{
	float3 z = p;
	float s = 1/3.0;
	float r = Tetrahedron(z, 0);
	for (int n = 0; n < loop; n++) {
		z = Mirror(z, float3(.36, 1, -.61), 0);
		z = Mirror(z, float3(.36, 1, .61), 0);
		z = Mirror(z, float3(-.7,1,0), 0);
		z = Mirror(z, float3(0,-1,0), s);
		z = Rotate(float4(0, 0.5, 0, 0.8660254), z*2.0 + float3(0,s,0));
		float i = pow(2,-n-1) * Tetrahedron(z, 0);
		r = min(r,i);
    }
    return r;
}

inline float SierpinskiTetrahedron(float3 pos, int loop)
{
	float3 z = pos;
	const float Scale = 2.0;
	const float Offset = 3.0;
    for (int n = 0; n < loop; n++) {
       if(z.x+z.y<0) z.xy = -z.yx;
       if(z.x+z.z<0) z.xz = -z.zx;
       if(z.y+z.z<0) z.zy = -z.yz;
       z = z*Scale - Offset*(Scale-1.0);
    }
    return (length(z) ) * pow(Scale, -float(n));
}

inline float JuliaBulb(float3 pos, int loop, float power)
{
	float3 zz = pos;
	float m = dot(zz, zz);
	float dz = 1.0f;
	for (int n = 0; n < loop; n++) {
		dz = 8.0 * pow(m, 3.5) * dz;

		float x = zz.x; float x2 = x*x; float x4 = x2 * x2;
		float y = zz.y; float y2 = y*y; float y4 = y2 * y2;
		float z = zz.z; float z2 = z*z; float z4 = z2 * z2;

		float k3 = x2 + z2;
		float k2 = rsqrt(k3*k3*k3*k3*k3*k3*k3);
		float k1 = x4 + y4 + z4 - 6.0*y2*z2 - 6.0*x2*y2 + 2.0*z2*x2;
        float k4 = x2 - y2 + z2;

		zz.x = power + 64.0*x*y*z*(x2-z2)*k4*(x4-6.0*x2*z2+z4)*k1*k2;
        zz.y = power + -16.0*y2*k3*k4*k4 + k1*k1;
        zz.z = power +-8.0*y*k4*(x4*x4 - 28.0*x4*x2*z2 + 70.0*x4*z4 - 28.0*x2*z2*z4 + z4*z4)*k1*k2;

		//float r = length(zz);
        //float b = 8.0*acos( clamp(zz.y/r, -1.0, 1.0));
        //float a = 8.0*atan2(zz.z, zz.zz);
        //zz = power + pow(r,8.0) * float3( sin(b)*sin(a), cos(b), sin(b)*cos(a) );

		m = dot(zz, zz);
		if (m > 2.0)
			break;
	}

	return 0.25 * log(m) * sqrt(m) / dz;
}


inline float3 SymmetricOrigins(float3 p) 
{

    // Rotate, but only the part that is on the side of rotDir
    //if (dot(p, rotDir) > 1.0) p *= rotMat;

    // Repeat our position so we can carve out many cylindrical-like things from our solid
    float3 rep = frac(p)-0.5;
    //final = max(final, -(length(rep.xz*rep.xz)*1.0 - 0.0326));
    float final = -(length(rep.xy*rep.xz) - 0.109);
    final = max(final, -(length(rep.zy) - 0.33));

    //final = max(final, -(length(rep.xz*rep.xz) - 0.03));
    //final = max(final, -(length(rep.yz*rep.yz) - 0.03));
    //final = max(final, -(length(rep.xy*rep.xy) - 0.030266));

    // Repeat the process of carving things out for smaller scales
    float3 rep2 = frac(rep*2.0)-0.5;
    final = max(final, -(length(rep2.xz)*0.5 - 0.125));
    final = max(final, -(length(rep2.xy)*0.5 - 0.125));
    final = max(final, -(length(rep2.zy)*0.5 - 0.125));

    float3 rep3 = frac(rep2*3.0)-0.5;
    final = max(final, -(length(rep3.xz)*0.1667 - 0.25*0.1667));
    final = max(final, -(length(rep3.xy)*0.1667 - 0.25*0.1667));
    final = max(final, -(length(rep3.zy)*0.1667 - 0.25*0.1667));

#ifdef TOO_MUCH_FRACTAL
    float3 rep4 = frac(rep3*3.0)-0.5;
    final = max(final, -(length(rep4.xz)*0.0555 - 0.25*0.0555));
    final = max(final, -(length(rep4.xy)*0.0555 - 0.25*0.0555));
    final = max(final, -(length(rep4.yz)*0.0555 - 0.25*0.0555));

    float3 rep5 = frac(rep4*3.0)-0.5;
    final = max(final, -(length(rep5.xz)*0.0185 - 0.25*0.0185));
    final = max(final, -(length(rep5.xy)*0.0185 - 0.25*0.0185));
    final = max(final, -(length(rep5.yz)*0.0185 - 0.25*0.0185));
#endif

    // Cut out stuff outside of outer sphere
    //final = max(final, (length(p) - Sphere(p, 1)));
    // Carve out inner sphere
    final = max(final, -(length(p) - 2.8));
    //final = max(final, abs(p.x) - 2.0);	// for that space station look
    //final = (length(p) - outerSphereRad);	// for debugging texture and lighting
    // Slice the object in a 3d grid so it can rotate like a rubik's cube
    float slice = 0.02;
    float3 grid = -abs(frac(p.xyz)) + slice;
    final = max(final, grid.x);
    final = max(final, grid.y);
    final = max(final, grid.z);
    //final = min(final, abs(p.y));
    return final;
}

#endif
