#ifndef FRACTALS2D_CGINC
#define FRACTALS2D_CGINC

inline float Mandelbrot(float2 pos, int iterations)
{
    float2 z = float2(0.0, 0.0);
    float2 dz = float2(0.0, 0.0);

    float m2;
    for( int i=0; i<iterations; i++ )
    {
        dz = 2.0*CMul(z, dz) + 1.0;
        z = CMul(z,z) + pos;

        m2 = dot2(z);
        if( m2 > 1e5f )
            break;
    }

    return sqrt( m2/dot2(dz) )*0.5*log(m2);
}

inline float Mandelbrot(float3 pos, int iterations)
{
	return FlatDistance(pos, Mandelbrot(pos.xz, iterations));
}

inline float Julia(float2 pos, int iterations, float2 z)
{
	float2 dz = float2(1.0, 0.0);
	float m2;
	for( int i=0; i<iterations; i++)
    {
		dz = 2.0 * CMul(z,dz) + 1.0;
		z = CMul(z,z) + pos;
		m2 = dot2(z);
		if(m2 > 1e+5)
			break;
		
	}

	return sqrt( m2/dot2(dz))*0.5*log(m2);
}

inline float Julia(float3 pos, int iterations, float2 z)
{
	return FlatDistance(pos, Julia(pos.xz, iterations, z));
}

#endif
