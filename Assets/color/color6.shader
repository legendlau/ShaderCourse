Shader "Unlit/color6"
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

			fixed3 rgb2hsb(fixed3  c ){
			    fixed4 K = fixed4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			    fixed4 p = lerp(fixed4(c.bg, K.wz), 
			                 fixed4(c.gb, K.xy), 
			                 step(c.b, c.g));
			    fixed4 q = lerp(fixed4(p.xyw, c.r), 
			                fixed4(c.r, p.yzx), 
			                 step(p.x, c.r));
			    float d = q.x - min(q.w, q.y);
			    float e = 1.0e-10;
			    return fixed3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), 
			                d / (q.x + e), 
			                q.x);
			}

			fixed3 hsb2rgb(fixed3  c ){
			   fixed3  rgb = clamp(abs(fmod(c.x*6.0+fixed3(0.0,4.0,2.0),
			                             6.0)-3.0)-1.0, 
			                     0.0, 
			                     1.0 );
			    rgb = rgb*rgb*(3.0-2.0*rgb);
			    return c.z * lerp(fixed3(1.0, 1.0, 1.0), rgb, c.y);
			}

			fixed step1(fixed a, fixed b, fixed x) {
				float t = saturate((x - a)/(b - a));
				return t;
			}
			fixed4 frag (v2f i) : SV_Target
			{

				//x h
				// 1
				//y b
				fixed2 dir = fixed2(i.uv.x, i.uv.y)-fixed2(0.5, 0.5);
				fixed radius = length(dir);
				fixed s = 1-radius;

				fixed theta = atan2(dir.y, dir.x);//-pi pi  -0.5 0.5
				fixed h = theta/(2*3.14)+0.5;
				fixed intPart = floor(h*6);

				fixed4 col = fixed4(hsb2rgb(fixed3(intPart/6, s, 1)), 1);


				return col;
			}

			ENDCG
		}
	}
}
