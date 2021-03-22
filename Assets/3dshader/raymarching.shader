Shader "Custom/raymarching"
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
			#pragma multi_compile_fwdbase 
			// make fog work
			//#pragma multi_compile_fog

			#define MIN_HEIGHT -2
			#define MAX_HEIGHT 2

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1; 
				float4 vertex : SV_POSITION;
				float4 objectPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			//float4 _WorldSpaceLightPos0;


			static const float3 sundir = normalize(float3(1.0, 0.5, 1.0));

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
				o.objectPos = v.vertex;
				return o;
			}



			float myrand(float2 pos) {
           
            	return frac(sin(dot(pos.xy, float2(12.9898, 72.833)))*43758.5453123);
            }

			float noise2(float2 pos) {
            	float2 intPart = floor(pos);
            	float2 fracPart = frac(pos);

            	float a = myrand(intPart);
            	float b = myrand(intPart+float2(1, 0));
            	float c = myrand(intPart+float2(0, 1));
            	float d = myrand(intPart+float2(1, 1));

            	float2 u = fracPart * fracPart * (float2(3, 3) - 2*fracPart);
            	 
				return lerp(a, b, u.x) + (c-a)*u.y*(1-u.x) + (d-b)*u.x*u.y;
            }



			float noise3D(float3 pos) {
				float zrate = (sin(pos.z)+1)/2;

				float p1 = noise2(pos);
				float p2 = noise2(pos*2);

				return lerp(p1, p2, zrate);
			}

			float brownNoise3D(float3 pos) {
				float3 pos1 = pos * 3;
				int num = 5;

				float value = 0;
				float am = 0.5;
				float fre = 1;
				for(int i  = 0; i < num; i++) {
					value += am * noise3D(fre*pos1);
					am *= 0.5;
					fre *= 2;
				}
				return value;
			}


			float denSi(float3 pos) {

				float edge = 1.0-smoothstep(MIN_HEIGHT, MAX_HEIGHT, pos.y);
				float den = 3*brownNoise3D(pos) - 1.5;
				den = clamp(den, 0, 1);
				return den ;
			}

			float4 raymarching(float3 ro, float3 rd, float t) {
				float4 sum = float4(0, 0, 0, 0);
				float3 pos = ro + rd * t;
				float rate = 0.5;
				for(int i = 0; i < 10; i++) {
					if(sum.a > 0.99 || (pos.y < (MIN_HEIGHT)) || (pos.y > (MAX_HEIGHT)) ) {
						break;
					}
					float den = denSi(pos);

					float4 col = float4(1.0, 0.95, 0.8, 1) * den * rate;
					sum += col * (1.0 - sum.a);
					t += max(0.05, 0.02*t);
					rate *= 0.7;
					pos = ro + rd * t;
				} 

				sum = clamp(sum, 0.0, 1.0);
				return sum;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//-1 1
				float2 p = i.uv*2 -float2(1, 1);
				//world Space 
				float3 ro = float3(0, 0, 0);
				float3 target = float3(0, 0, 1);

				float3 rd = normalize(float3(p.x, p.y, 1));
				float sun = dot(sundir, rd);

				float3 col = lerp(float3(0.78,0.78,0.7), float3(0.3,0.4,0.5), p.y * 0.5 + 0.5);
				col += 0.5*float3(1.0,0.5,0.1)*pow(sun, 8.0);

				float4 cloud = raymarching(ro, rd, 2);
				col = cloud.rgb + (1-cloud.a) * col;
				//col = float3(cloud.a, cloud.a, cloud.a);
				return float4(col, 1);

				 
			}
			ENDCG
		}
	}
}
