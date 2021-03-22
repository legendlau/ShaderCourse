Shader "Unlit/color3"
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
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed step1(fixed a, fixed b, fixed x) {
				float t = saturate((x - a)/(b - a));
				return t;
			}
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c1 = fixed4(0.8, 0.3, 0.1, 1);
				fixed4 c2 = fixed4(0.3, 0.2, 0.8, 1);
				fixed4 c3 = fixed4(0.3, 0.8, 0.3, 1);

				//fixed pct = abs(sin(_Time.y));


				//fixed4 col = lerp(c1, c2, step(0.5, i.uv.x));
				fixed4 col = (1-step(0.33, i.uv.x))*c1+(step(0.33, i.uv.x)-step(0.66, i.uv.x))*c2
				+(step(0.66, i.uv.x))*c3;

				//fixed4 col = lerp(fixed4(c1.r, 0, 0, 1), fixed4(c2.r, 0, 0, 1), i.uv.x);
				//fixed diff = abs(pow(i.uv.x, 5)-i.uv.y);
				//fixed pct = smoothstep(0.1*pow(0.1i.uv.x, 5), 0, diff);//0 - 1
				/*
				fixed px = (frac(sin(8*i.uv.x))+1)/2;


				fixed pct1 = 1-smoothstep(px, px+0.1, i.uv.y);
				fixed pct2 = smoothstep(px-0.1, px, i.uv.y);
				fixed pct = pct1 * pct2;

				fixed4 col1 = pct*fixed4(0, 1, 0, 1) + (1-pct)*fixed4(0, 0, 0, 0);


				col = (1-pct)*fixed4(px, px, px, 1)+col1;
				*/

				return col;
			}

			ENDCG
		}
	}
}
