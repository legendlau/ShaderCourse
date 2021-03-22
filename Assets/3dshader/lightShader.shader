Shader "Custom/lightShade"
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


			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
				o.objectPos = v.vertex;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//return float4(_WorldSpaceLightPos0.rgb, 1) ;

				//float3 col = ShadeVertexLights(i.objectPos, i.normal);
				//return float4(col, 1);
				//fixed4 col = tex2D(_MainTex, i.uv);
				float3 viewDir = normalize( UnityObjectToViewPos (i.objectPos));
				//float3 objPos = i.objectPos;
				float3 viewSpaceLightPos = normalize( mul(UNITY_MATRIX_V, _WorldSpaceLightPos0).xyz);


				float3 viewN = normalize (mul ((float3x3)UNITY_MATRIX_IT_MV, i.normal));
				float3 toLight = viewSpaceLightPos;
				float lengthSq = dot(toLight, toLight);
				toLight *= rsqrt(lengthSq);

				//float atten = 1.0 / (1.0 + lengthSq * unity_LightAtten[0].z);
				float diff = max (0, dot (viewN, toLight));

				float3 diffuseColor  = float3(0.7, 0.7, 0.7)*(diff * 1 );

				float3 ambientColor = float3(0.2, 0.2, 0.2);

				float3 h = normalize(-viewDir+viewSpaceLightPos);
				float nh = max (0, dot (viewN, h));
				float spec = pow (nh, 20.0) * 1;


				return float4(diffuseColor+ambientColor+float3(1, 0, 0) * spec, 1);
				//return float4(float3(spec, 0, 0), 1);
			}
			ENDCG
		}
	}
}
