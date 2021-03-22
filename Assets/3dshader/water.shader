Shader "Custom/water"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Cube ("EnvMap (RGB)", Cube) = "" {TexGen CubeReflect}
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
				float4 vertex : SV_POSITION;
				float3 viewDir : TEXCOORD2;
			};

			sampler2D _MainTex;
			samplerCUBE _Cube;


			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, v.uv);

				float4x4 modelMatrix = unity_ObjectToWorld;
				o.viewDir = normalize(-_WorldSpaceCameraPos + mul(modelMatrix, v.vertex).xyz);

				return o;
			}




			
			fixed4 frag (v2f input) : SV_Target
			{
				float2 uv = input.uv;
				uv.x += cos(uv.x*2+_Time.y*2)*0.02 + cos(uv.x*4+_Time.y*2)*0.01;
				uv.y += cos(uv.y*2+_Time.y*2)*0.02 + cos(uv.y*4+_Time.y*2)*0.01;
				float4 col = tex2D(_MainTex, uv);

				fixed4 tex1 = texCUBE(_Cube, input.viewDir);
				float4 col2 = col + 0.7 * tex1;

				return col2;
			}
			ENDCG
		}
	}
}
