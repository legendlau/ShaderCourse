Shader "Custom/cubeMap"
{
	Properties
	{
		//_MainTex ("Texture", 2D) = "white" {}
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
				float3 normalDir : TEXCOORD1; 
				float4 vertex : SV_POSITION;
				float3 viewDir : TEXCOORD2;
			};

			samplerCUBE _Cube;


			static const float3 sundir = normalize(float3(1.0, 0.5, 1.0));

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, v.uv);

				float4x4 modelMatrix = unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject;
				o.viewDir = normalize(-_WorldSpaceCameraPos + mul(modelMatrix, v.vertex).xyz);
				o.normalDir = normalize(mul(float4(v.normal, 0.0), modelMatrixInverse).xyz);
				return o;
			}




			
			fixed4 frag (v2f input) : SV_Target
			{
				float3 reflectedDir = reflect(input.viewDir, normalize(input.normalDir));	
				//fixed4 tex1 = texCUBE(_Cube, reflectedDir);
				fixed4 tex1 = texCUBE(_Cube, input.viewDir);
				return tex1;
			}
			ENDCG
		}
	}
}
