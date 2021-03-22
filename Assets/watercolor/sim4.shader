Shader "Unlit/sim4"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MainTex1 ("Texture", 2D) = "white" {}
		_MainTex2 ("Texture", 2D) = "white" {}

		inInit ("initYet", float) = 0
		gridNum ("gridNum", int) = 16
		Da ("Da", float) = 1.0
		Db ("Db", float) = 0.5
		Feed ("Feed", float) = 0.055
		Kill ("Kill", float) = 0.062

		offX ("offX", float) = 10
		offY ("offY", float) = 10


		pointSize ("pointSize", float) = 5

		delta ("delta", float) = 1

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

			float inInit;
			int gridNum;
			float Da;
			float Db;
			float Feed;
			float Kill;

			float offX;
			float offY;
			float pointSize;
			float delta;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			//A =1 B = 0
			//B = 1
			float4 InitReact(float2 pos) {
				float2 gd = floor(pos);

				if (length(gd-offX) < pointSize) {
					return float4(0, 1, 0, 0);
				}

				/*
				if(abs(gd.x- offX) < pointSize && abs(gd.y - offY) < pointSize ) {
					return float4(0, 1, 0, 0);
				}
				*/

				/*
				if(abs(gd.x - 4-offX) < 0.1 && abs(gd.y - 4-offY) < 0.1) {
					return float4(1, 1, 0, 1);
				}

				if(abs(gd.x - 4-offX) < 0.1 && abs(gd.y - 5-offY) < 0.1) {
					return float4(0, 1, 0, 1);
				}

				if(abs(gd.x - 5-offX) < 0.1 && abs(gd.y - 4-offY) < 0.1) {
					return float4(0, 1, 0, 1);
				}

				if(abs(gd.x - 5-offX) < 0.1 && abs(gd.y - 5-offY) < 0.1) {
					return float4(0, 1, 0, 1);
				}
				*/
				/*
				if(abs(gd.x - 7-offX) < 0.1 && abs(gd.y - 4-offY) < 0.1) {
					return float4(0, 1, 0, 1);
				}

				if(abs(gd.x - 7-offX) < 0.1 && abs(gd.y - 5-offY) < 0.1) {
					return float4(0, 1, 0, 1);
				}
				*/

				return float4(1, 0, 0, 1);
			}

			float4 reactNow(float2 pos) {
				//return float4(0, 0, 0, 1);
				float2 pos1 = floor(pos*gridNum);
				pos1 += float2(0.2, 0.2);


				float4 colNow = tex2D(_MainTex, pos1/gridNum);
				/*
				float weight[9] = {
					0.05,
					0.2,
					0.05,
					0.2, 
					-1,
					0.2,
					0.05,
					0.2,
					0.05,
				};

				float2 result = float2(0, 0);
				int count = 0;
				for(int i = -1; i < 2; i++) {
					for(int j = -1; j < 2; j++) {
						result += weight[count] * tex2D(_MainTex, (pos1+float2(i, j))/gridNum );
						count++;
					}
				}
				*/
				float2 col1 = tex2D(_MainTex, (pos1+float2(-1, 0))/gridNum);
				float2 col2 = tex2D(_MainTex, (pos1+float2(1, 0))/gridNum);
				float2 col3 = tex2D(_MainTex, (pos1+float2(0, -1))/gridNum);
				float2 col4 = tex2D(_MainTex, (pos1+float2(0, 1))/gridNum);
				float2 lapl = col1 + col2 + col3 + col4 - 4.0 * colNow;


				float du = Da*lapl.r - colNow.r*colNow.g*colNow.g + Feed*(1.0 - colNow.r);
				float dv = Db*lapl.g + colNow.r*colNow.g*colNow.g - (Feed+Kill)*colNow.g;

				float2 dst = colNow.rg + delta*float2(du, dv);
				return float4(dst, 0, 1);

				//float2 changeVal = result.rg * float2(Da, Db) + float2(-colNow.r*colNow.g*colNow.g, colNow.r*colNow.g*colNow.g)+float2(Feed*(1-colNow.r), -(Kill+Feed)*colNow.g);
				//float2 newCol = colNow.rg +  changeVal * delta;
				//return float4(newCol, 0, 1);
			}

			//Init
			//Anim
			//SwitchTexture 
			float4 reactionDiffusion(float2 pos) {
				if(inInit < 0.5) {
					return InitReact(pos * gridNum);
				}else {
					return reactNow(pos);
				}
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float2 pos = i.uv;
				//return waterColor(pos);
				return reactionDiffusion(pos);
			}

			ENDCG
		}
	}
}
