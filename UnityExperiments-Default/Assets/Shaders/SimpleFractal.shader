Shader "Custom/SimpleFractal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			float2 rot(float2 uv, float a)
			{
				return float2(uv.x * cos(a) - uv.y * sin(a), uv.y * cos(a) + uv.x * sin(a));
			}


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float2 uv = i.uv;
				uv = rot(uv, _Time.y);
				uv = mul(sin(_Time.y) * 0.18 + 4.5, uv);
				int maxIterations = 5;

				float s = 0.3f;
				for (int i = 0; i < maxIterations; i++)
				{
					uv = abs(uv) - s;
					uv = rot(uv, -_Time.y);
					s = s / 2.1;
				}

				float circleSize = 1.0 / (3.0 * pow(2.0, float(maxIterations)));
				float c = length(uv) > circleSize ? 0 : 1.0;

				return float4(c, c, c, 1.0);
            }
            ENDCG
        }
    }
}
