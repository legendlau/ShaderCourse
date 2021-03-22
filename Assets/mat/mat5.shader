Shader "Unlit/mat5"
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

			/*
		mat3 rgb2yuv = mat3(0.2126, 0.7152, 0.0722,
                    -0.09991, -0.33609, 0.43600, 
                    0.615, -0.5586, -0.05639);

                    // YUV to RGB matrix
		mat3 yuv2rgb = mat3(1.0, 0.0, 1.13983, 
                    1.0, -0.39465, -0.58060, 
                    1.0, 2.03211, 0.0);
            */
			fixed4 frag (v2f i) : SV_Target
			{
				float3x3 rgb2yuv = float3x3(0.2126, 0.7152, 0.0722,
                    -0.09991, -0.33609, 0.43600, 
                    0.615, -0.5586, -0.05639);

                float3x3 yuv2rgb = float3x3(1.0, 0.0, 1.13983, 
                    1.0, -0.39465, -0.58060, 
                    1.0, 2.03211, 0.0);

                    /*
                float3x3 yuv2rgb = float3x3(1.0, -0.09991, 0.615, 
                    0.0, -0.33609, -0.5586, 
                    1.13983,  -0.43600, -0.05639);
                    */

               //-1 1
               //xy 0 1 ---> [-1, 1] 颜色范围
                
			   //yuv  亮度  uv 

			   float2 uv1 = i.uv;
			   uv1 -= float2(0.5, 0.5);
			   uv1 *= float2(2, 2);

			   float3 col = mul(yuv2rgb , float3(0.5, uv1.x, uv1.y));
			   return fixed4(col, 1);

			   /*
				//0.15 0.25 0.4
				//0.05

				fixed2 offsetpos = i.uv.xy-center;
				fixed theta = atan2(offsetpos.y, offsetpos.x);
				fixed radius = length(offsetpos);
				//fixed coff = max(step(radius, 0.3) - step(radius, 0.35), 0);
				fixed coff = max(step(radius, 0.16)-step(radius, 0.15), 0);
				fixed coff2 = max(step(radius, 0.26)-step(radius, 0.25), 0); 
				fixed coff3 = max(step(radius, 0.41)-step(radius, 0.4), 0); 
				fixed rate = min(coff+coff2+coff3, 1);

				fixed4 col = lerp(fixed4(0, 0, 0, 1), fixed4(1, 1, 1, 1), rate);


			 	fixed3 influenced_color_a = fixed3(0.880,0.793,0.581);
			    fixed3 influencing_color_A = fixed3(0.0,0.0,0.0); 


			    fixed2 uv1 = i.uv-center;
			    fixed theta1 = _Time.y;
			    float2x2 mat1 = float2x2(cos(theta1), -sin(theta1), sin(theta1), cos(theta1));
			    uv1 = mul( mat1,  uv1) + fixed2(0.5, 0.5);

				fixed3 col1 = lerp(
				influencing_color_A,	
				influenced_color_a,
				rectRange(fixed2(0.5, 0.5), fixed2(0.4, 0.02), uv1) );

				fixed4 col2 = fixed4(col1, 1);

				return fixed4(col.rgb+col2.rgb, 1);
				*/


			}

			ENDCG
		}
	}
}
