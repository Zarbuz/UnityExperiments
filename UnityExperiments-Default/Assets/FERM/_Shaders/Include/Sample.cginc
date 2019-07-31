#pragma exclude_renderers d3d11 gles
Vert2Frag Vert(appdata_full v) {
    Vert2Frag o;
    UNITY_INITIALIZE_OUTPUT(Vert2Frag, o);

    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    o.pos = v.vertex;
    o.projPos = ComputeNonStereoScreenPos(o.pos);
    COMPUTE_EYEDEPTH(o.projPos.z);

#ifdef DYNAMICLIGHTMAP_ON
    o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
#ifdef LIGHTMAP_ON
    o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif
    UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy);
    //UNITY_TRANSFER_FOG(o,o.pos);
    return o;
}

FragOutput Average(FragOutput samples[16], int amount){
	float4 color = float4(0, 0, 0, 0);
#ifdef USE_RAYMARCHING_DEPTH
	float depth = 0;
#endif
	for (int i = 0; i < amount; i++) {
		color += samples[i].color;
#ifdef USE_RAYMARCHING_DEPTH
		depth += samples[i].depth;
#endif
	}
	FragOutput o;
	o.color = color / amount;
#ifdef USE_RAYMARCHING_DEPTH
	o.depth = depth / amount;
#endif
	
	return o;
}


FragOutput Sample1(Vert2Frag i) {
	return FragOne(i);
}

FragOutput Sample2(Vert2Frag i) {
	float2 offSet = .25 * float2(1 / _ScreenParams.x, 1 / _ScreenParams.y);
	
	FragOutput samples[16];
	
	i.projPos.xy += offSet; samples[0] = FragOne(i);
	i.projPos.xy -= 2*offSet; samples[1] = FragOne(i);
	
	return Average(samples, 2);
}



FragOutput Sample4(Vert2Frag i) {
	float2 offSet = .1666 * float2(1 / _ScreenParams.x, 1 / _ScreenParams.y);
	
	FragOutput samples[16];
	
	i.projPos.xy += offSet;	samples[0] = FragOne(i);
	i.projPos.y -= 2*offSet.y; samples[1] = FragOne(i);
	i.projPos.x -= 2*offSet.x; samples[2] = FragOne(i);
	i.projPos.y += 2*offSet.y; samples[3] = FragOne(i);
	
	return Average(samples, 4);
}

FragOutput Sample9(Vert2Frag i) {
	float2 offSet = .25 * float2(1 / _ScreenParams.x, 1 / _ScreenParams.y);
	
	FragOutput samples[16];
	
	samples[0] = FragOne(i); 
	i.projPos.xy += offSet; samples[1] = FragOne(i);
	i.projPos.y -= offSet.y; samples[2] = FragOne(i);
	i.projPos.y -= offSet.y; samples[3] = FragOne(i); 
	i.projPos.x -= offSet.x; samples[4] = FragOne(i);
	i.projPos.x -= offSet.x; samples[5] = FragOne(i);
	i.projPos.y += offSet.y; samples[6] = FragOne(i);
	i.projPos.y += offSet.y; samples[7] = FragOne(i); 
	i.projPos.x += offSet.x; samples[8] = FragOne(i); 
	
	return Average(samples, 9);
	
}

FragOutput Sample16(Vert2Frag i) {
	float2 offSet = .125 * float2(1 / _ScreenParams.x, 1 / _ScreenParams.y);
	
	FragOutput samples[16];
	
	i.projPos.xy += offSet;	samples[0] = FragOne(i);
	i.projPos.y -= 2*offSet.y; samples[1] = FragOne(i);
	i.projPos.x -= 2*offSet.x; samples[2] = FragOne(i);
	i.projPos.y += 2*offSet.y; samples[3] = FragOne(i);
	i.projPos.x += 2*offSet.x;
	i.projPos.xy += offSet;	samples[4] = FragOne(i);
	i.projPos.y -= 2*offSet.y; samples[5] = FragOne(i);
	i.projPos.y -= 2*offSet.y; samples[6] = FragOne(i);
	i.projPos.y -= 2*offSet.y; samples[7] = FragOne(i);
	i.projPos.x -= 2*offSet.x; samples[8] = FragOne(i);
	i.projPos.x -= 2*offSet.x; samples[9] = FragOne(i);
	i.projPos.x -= 2*offSet.x; samples[10] = FragOne(i);
	i.projPos.y += 2*offSet.y; samples[11] = FragOne(i);
	i.projPos.y += 2*offSet.y; samples[12] = FragOne(i);
	i.projPos.y += 2*offSet.y; samples[13] = FragOne(i);
	i.projPos.x += 2*offSet.x; samples[14] = FragOne(i);
	i.projPos.x += 2*offSet.x; samples[15] = FragOne(i);
	
	return Average(samples, 16);
}

FragOutput Frag(Vert2Frag i) {
#ifdef SUPERSAMPLING_16X
	return Sample16(i);
#elif defined(SUPERSAMPLING_9X)
	return Sample9(i);
#elif defined(SUPERSAMPLING_4X)
	return Sample4(i);
#elif defined(SUPERSAMPLING_2X)
	return Sample2(i);
#else
	return Sample1(i);
#endif
}

