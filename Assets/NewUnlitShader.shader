Shader "Unlit/NewUnlitShader"
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

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			//uniform float4x4 mat;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				//v.uv.x y z w
				//r g b a
				//u v

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			//float half fixed
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				//fixed4 col = tex2D(_MainTex, i.uv);
				/*
				fixed4 col = fixed4(0, 1, 0, 1);
				col.b = 0.0;
				col.g = 0.0;
				col.x = 0.5;
				*/

				//fixed4 col = fixed4(fixed3(1, 0, 0), 1);


				fixed4 col = fixed4(1, fixed2(1, 0), 1);
				/*
				float t = abs(sin(2*_Time.y));
				col.x = t;
				float t1 = abs(cos(3*_Time.y)); 
				col.y = t1;
				*/
				/*
				col.x = abs(sin(i.uv.x));
				col.y = abs(sin(i.uv.y));
				*/
				col.x = i.uv.x;
				col.y = i.uv.y;
				//col.r;
				//col.g;
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
