Shader "Unlit/Wave"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_OffPosX ("OffTex", float) = 0.0
		_OffPosY ("OffTex", float) = 0.0
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
			float _OffPosX;
			float _OffPosY;

			float shiftY(float2 xzPos) {
				float t = _Time.y;
				const float2 dir = normalize(float2(0.8, 2));
				float dv = dot(xzPos, dir);
				float y = (sin(dv*1.0+t*1.0)+sin(dv*2.3+t*1.5)+sin(dv*3.3+t*0.4))/3.0;
				return y;
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				float y = shiftY(v.vertex.xz);
				float4 ver = float4(v.vertex);
				ver.y = y*0.5;

				float4 pos = mul(UNITY_MATRIX_MVP, ver);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.vertex = pos;
				UNITY_TRANSFER_FOG(o,o.vertex);

				return o;
			}

			//perlin noise sine Off
			float2 sinOffSet(float2 uv) {
				float t = _Time.y;
				float tm = 0.5*sin(0.5*t+uv) + 0.25*sin(t+uv);

				//tm *= 2;
				//uv += float2(tm, tm);
				const float2 dir1 = normalize(float2(0.5, 1.8));
				const float2 dir2 = normalize(float2(3.2, 0.7));
				float xv = dot(uv, dir1);
				float yv = dot(uv, dir2);
				float sx = (sin(1.1*xv+t*1)+sin(2.2*xv+t*1.5)+sin(2.6*xv+1+t*0.4))/3.0;
				float sy = (sin(1.5*yv+t*3)+sin(2.4*yv+t*1.2)+sin(3.2*yv+1+t*0.4))/3.0;
				//float sy = 0.5*sin(1*uv.y+tm)+0.25*sin(2*uv.y+tm)+0.125*sin(4*uv.y+tm);
				//float sx = ((sin(uv.x)+sin(2.2*uv.x+0.5+t)+sin(2.9*uv.x+1.2)+sin(4.6*uv.x+8))/4+1);
				//float sy = ((sin(uv.y)+sin(2.2*uv.y+0.5+t)+sin(2.9*uv.y+1.2)+sin(4.6*uv.y+8))/4+1);
				return float2(sx, sy);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float2 reUV = i.uv * 5;
				float2 uv1 = reUV + float2(_OffPosX, _OffPosY);
				// sample the texture
				fixed4 col = tex2D(_MainTex, reUV + 0.25*sinOffSet(reUV));
				fixed4 col1 = tex2D(_MainTex, uv1 + 0.25*sinOffSet(uv1));
				const float3 deepBlue = float3(0, 0.43, 0.745);
				const float3 whiteWave = float3(1, 1, 1);
				const float3 darkWave = float3(0, 0.4, 0.72);
				float3 realCol = col1.r * darkWave + (1-col1.r)* deepBlue;
				realCol = col.r * whiteWave + (1-col.r) * realCol;


				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return float4(realCol, 1);
			}
			ENDCG
		}
	}
}
