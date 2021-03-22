// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/tankPlayerShader5" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NormTex ("NormTex (RGB)", 2D) = "white" {}
	}
	
	SubShader {
		Tags { 
			"Queue"="Geometry+5" 
			"IgnoreProjector"="True"
		 }

		Pass {
			Name "BASE"
	        Lighting off
			
			LOD 200
			CGPROGRAM
			
			#pragma vertex vert 
	        #pragma fragment frag
	        #include "UnityCG.cginc"

			struct VertIn {
	        	float4 vertex : POSITION;
	        	float4 texcoord : TEXCOORD0;
	        	float3 normal : NORMAL;
				float4 tangent : TANGENT;
	        };
	        struct v2f {
	        	float4 pos : SV_POSITION;
	        	float2 uv : TEXCOORD0;

				float4 posWorld : TEXCOORD1;
				float3 tangentWorld : TEXCOORD2;
				float3 normalWorld : TEXCOORD3;
				float3 binormalWorld : TEXCOORD4;

	        };
	        
	        uniform sampler2D _MainTex;
	        uniform sampler2D _NormTex;

	        v2f vert(VertIn v) 
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, v.texcoord);

				float4x4 modelMatrix = unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject;

				o.posWorld = mul(modelMatrix, v.vertex);
				
				float3 tangentWorld = normalize(mul(modelMatrix, float4(v.tangent.xyz, 0.0)).xyz);
				o.tangentWorld = tangentWorld;
				float3 normalWorld = normalize(mul(float4(v.normal, 0), modelMatrixInverse).xyz);
				o.normalWorld = normalWorld;

				o.binormalWorld = normalize(cross(normalWorld, tangentWorld) * v.tangent.w);

				return o;
			}
			
			fixed4 frag(v2f i) : Color {
				const fixed3 lightDir = normalize(fixed3(1, 1, 1));
				fixed3 normal = UnpackNormal(tex2D(_NormTex, i.uv));

				float3x3 local2WorldTranspose = float3x3(
					i.tangentWorld,
					i.binormalWorld,
					i.normalWorld
				);
				float3 normalDirection = normalize(mul(normal, local2WorldTranspose));

				float diffCoff = max(0.0, dot(normalDirection, lightDir));

				const float amColor = 0.5;

				fixed4 retCol = tex2D(_MainTex, i.uv)*(diffCoff+amColor);
				//fixed4 retCol = tex2D(_MainTex, i.uv)*(amColor);
				return  retCol;
			}
	        ENDCG
		}

	} 
	FallBack "Diffuse"
}
