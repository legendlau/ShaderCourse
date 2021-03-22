Shader "Unlit/art2"
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
            	fixed r0 = rectRange(fixed2(-0.3, -0.3), fixed2(0.6, 0.6), st1);
            	/*
            	fixed r1 = rectRange(fixed2(0.3, -0.1), fixed2(0.2, 0.2), st1);
            	fixed r2 = rectRange(fixed2(-0.5, -0.1), fixed2(0.2, 0.2), st1); 
            	fixed r3 = rectRange(fixed2(-0.1, -0.5), fixed2(0.2, 0.2), st1); 
            	fixed r4 = rectRange(fixed2(-0.1, 0.3), fixed2(0.2, 0.2), st1); 
            	*/
            	return min(r0, 1);
            }

            float rectRangeUp(fixed2 st, fixed2 size, fixed2 pos) {
	            fixed2 offs = pos-st;
				fixed av = step(0, offs.x)*step(0, offs.y);
				fixed bv = step(offs.x, size.x)*step(offs.y, size.y);
				fixed up = step(pos.x-pos.y, 0);
				return av*bv*up;	
            }

            //1 up 0 down
            float triangle2(fixed2 st, fixed2 size, fixed2 pos,  fixed up ) 
            {
            	return rectRangeUp(st, size, pos);
            }

            float fengche(fixed2 pos) {
            	float2 pos1 = pos * fixed2(2, 2);
				float2 intPart = floor(pos1);
				float2 pos2 = frac(pos1);
				fixed xp = intPart.x;
				fixed yp = intPart.y;

				fixed partx = step(xp, 0);
				fixed party = step(yp, 0);

				float PI90 = -3.14159/2;
				float theta = 0 + (1-partx)*party * PI90 + (1-partx)*(1-party)*2*PI90 + partx*(1-party)*3*PI90 ;

				pos2 -= fixed2(0.5, 0.5);

				float2x2 mat1 = float2x2(cos(theta), -sin(theta), sin(theta), cos(theta));
			   	pos2 = mul( mat1,  pos2);

				fixed inRect = triangle2(fixed2(-0.5, -0.5), fixed2(1, 1),  pos2, 1);
				return inRect;
            }

            float myrand(float2 pos) {
            	return frac(sin(dot(pos.xy, float2(12.9898, 72.833)))*43758.5453123);
            }


			fixed4 frag (v2f i) : SV_Target
			{
			   float2 uv1 = i.uv;
			   float deltaY = myrand(uv1);


			   fixed3 col = fixed3(deltaY, deltaY, deltaY);
			   return fixed4(col, 1);

			}

			ENDCG
		}
	}
}
