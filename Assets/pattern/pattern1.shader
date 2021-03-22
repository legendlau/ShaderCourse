Shader "Unlit/pattern1"
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



            float circle(fixed2 st, fixed radius) {
            	fixed2 st1 = st-fixed2(0.5, 0.5);

            	fixed l = length(st1);
            	return step(l, radius);
            }
            float crossFunc(fixed2 st) {
            	fixed2 st1 = st-fixed2(0.5, 0.5);
            	//-0.5 0.5
            	return rectRange(fixed2(-0.4, -0.1), fixed2(0.8, 0.2), st1);
            }

			fixed4 frag (v2f i) : SV_Target
			{
               
               //frac
               //-1 1

               //xy 0 1 ---> [-1, 1] 颜色范围
                
			   //yuv  亮度  uv 

			   float2 uv1 = i.uv;
			   // == 1 == 1

			   uv1 = frac(fixed2(uv1.x*3, uv1.y*3));
			   //fixed2 colRow = i.uv*3-uv1;

			   fixed inCir = circle(uv1, 0.3);
			   fixed inRect = crossFunc(uv1);

			   fixed2 colRow = i.uv*3;
			   fixed con1 = step(colRow.x, 2) - step(colRow.x, 1);
			   fixed con2 = step(colRow.y, 2) - step(colRow.y, 1);
			   fixed ret = lerp(inCir , inRect, con1*con2);


			   fixed3 col = fixed3(ret, ret, ret);

			   return fixed4(col, 1);


			}

			ENDCG
		}
	}
}
