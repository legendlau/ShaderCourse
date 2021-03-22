Shader "Unlit/sim3"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MainTex1 ("Texture", 2D) = "white" {}
		_MainTex2 ("Texture", 2D) = "white" {}

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11 and Xbox360 because it uses wrong array syntax (type[size] name)
#pragma exclude_renderers d3d11 xbox360
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

			sampler2D _MainTex1;
			sampler2D _MainTex2;
			 
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}


			float lum(float3 col) {
				return dot(col, float3(0.299, 0.587, 0.114));
			}

			float4 waterColor(float2 pos) {
				float4 bc = tex2D(_MainTex, pos);
				float4 n = tex2D(_MainTex1, pos);

				float nv = n.r;
				float3 bcolor = bc.rgb;
				float3 ret = nv * bcolor*0.5 + bcolor;

				float lv = lum(ret);
				float4 gv  = tex2D(_MainTex2, float2(lv, 0.5));

				float3 retC = 1.5* gv.r * float3(0.4, 0.61, 0.61);


				return float4(retC, 1);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float2 pos = i.uv;
				return waterColor(pos);
			}

			ENDCG
		}
	}
}
