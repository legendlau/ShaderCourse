Shader "Custom/3dbump1"
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
				const float3 toLight = normalize(float3(1, 1, 1));

				float stepP = 10.0/256.0;

				float l = tex2D(_MainTex, i.uv+float2(-stepP, 0)).r;
				float r = tex2D(_MainTex, i.uv+float2(stepP, 0)).r;
				float d = tex2D(_MainTex, i.uv+float2(0, -stepP)).r;
				float u = tex2D(_MainTex, i.uv+float2(0, stepP)).r;

				//float dx = (r-l)/(2*stepP);
				//float dy = (u-d)/(2*stepP);
				const float he = 1;
				float2 dx = normalize(float2(he*(l-r), 2*stepP));
				float2 dy = normalize(float2(he*(d-u), 2*stepP));

				//90 
				//cos  -sin    w
				//sin  cos     h 
				//=  -h,  w
				// Plane   Y  x  Z
				//x Y     Z Y 

				float3 normalDir = normalize(float3(dx.x,  dx.y+dy.y , dy.x));



				//float3 viewDir = normalize( UnityObjectToViewPos (i.objectPos));
				//float3 viewSpaceLightPos = normalize( mul(UNITY_MATRIX_V, _WorldSpaceLightPos0).xyz);


				//float3 viewN = normalize (mul ((float3x3)UNITY_MATRIX_IT_MV, i.normal));
				//float3 toLight = viewSpaceLightPos;
				//float lengthSq = dot(toLight, toLight);
				//toLight *= rsqrt(lengthSq);

				float diff = max (0, dot (normalDir, toLight));

				float3 diffuseColor  = float3(0.7, 0.7, 0.7)*(diff * 1 );

				return float4(diffuseColor, 1);
			}
			ENDCG
		}
	}
}
