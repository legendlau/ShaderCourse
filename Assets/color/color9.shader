Shader "Unlit/color9"
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

			fixed rectRange(fixed2 st, fixed2 size, fixed2 pos){
				fixed2 offs = pos-st;
				fixed av = step(0, offs.x)*step(0, offs.y);
				fixed bv = step(offs.x, size.x)*step(offs.y, size.y);
				return av*bv;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				/*
				//x h
				// 1
				//y b
			 	fixed3 influenced_color_a = fixed3(0.880,0.793,0.581);
			    fixed3 influenced_color_b = fixed3(0.654,0.760,0.576);
			    
			    fixed3 influencing_color_A = fixed3(0.980,0.972,0.896); 
			    fixed3 influencing_color_B = fixed3(0.036,0.722,0.790);

				fixed3 col1 = lerp(
				influencing_color_A,	
				influenced_color_a,
				rectRange(fixed2(0.3, 0.7), fixed2(0.5, 0.2), i.uv) );

				fixed3 col2 = lerp(
					influencing_color_B,
					influenced_color_b,
					rectRange(fixed2(0.3, 0.2), fixed2(0.5, 0.2), i.uv) 
				);


				fixed3 col3 = lerp(
					col2,
					col1,
					rectRange(fixed2(0.0, 0.5), fixed2(1, 0.5), i.uv) 
				);
				fixed4 col = fixed4(col3, 1);
				*/
				/*
				fixed x1 = 1-step(0.1, i.uv.x);
				fixed y1 = 1-step(0.1, i.uv.y);
				fixed ok = step(0.1, x1+y1);


				fixed x2 = step(0.9, i.uv.x);
				fixed y2 = step(0.9, i.uv.y);
				fixed ok1 = step(0.1, x2+y2);

				fixed ok2 = step(0.1, ok+ok1);

				//boolean
				fixed4 col = lerp(fixed4(1, 1, 1, 1), fixed4(0, 0, 0, 1), ok2);
				*/

				fixed2 center = fixed2(0.5, 0.5);
				fixed dist = length(i.uv.xy - center);
				fixed4 col = lerp(fixed4(0, 0, 0, 1), fixed4(1, 1, 1, 1), dist);

				return col;
			}

			ENDCG
		}
	}
}
