Shader "Unlit/sim1"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MainTex1 ("Texture", 2D) = "white" {}
		hatch_y_offset ("YOff", float) = 5.0
		lum_threshold_1 ("th1", float) = 1.0
		lum_threshold_2 ("th2", float) = 0.7
		lum_threshold_3 ("th3", float) = 0.5
		lum_threshold_4 ("th4", float) = 0.3
		inInit ("initYet", float) = 0
		gridNum ("gridNum", int) = 8
		doAnim ("doAnim", float) = 0


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
			float inInit;
			int gridNum;
			float doAnim ;

			float hatch_y_offset;
			float lum_threshold_1;
			float lum_threshold_2;
			float lum_threshold_3;
			float lum_threshold_4;
			 
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}


			float InitGame(float2 pos) {

				float2 gd = floor(pos);
				if(abs(gd.x - 4) < 0.1 && abs(gd.y - 4) < 0.1) {
					return 1;
				}
				if(abs(gd.x-5) < 0.1 && abs(gd.y -4) < 0.1 ) {
					return 1;
				}

				if(abs(gd.x-6) < 0.5 && abs(gd.y-4) < 0.1) {
					return 1;
				}

				if(abs(gd.x-6) < 0.5 && abs(gd.y-5) < 0.1) {
					return 1;
				}

				if(abs(gd.x-5) < 0.5 && abs(gd.y-6) < 0.1) {
					return 1;
				}
				return 0;
				//return fmod(gd.y, 2);
			}

			float aniGame(float2 pos) {
				float2 pos1 = floor(pos * gridNum);
				pos1 += float2(0.2, 0.2);

				//return tex2D(_MainTex, pos1/gridNum).r;
				//return (pos1/gridNum).y;


				int whiteNeibor = 0;
				for(int i = -1; i < 2; i++) {
					for(int j = -1; j < 2; j++) {
						if(i == 0 && j == 0) {
						}else {
							float2 pos2 = pos1+float2(i, j);
							if(pos2.x < 0 || pos2.y < 0 || pos2.x > gridNum || pos2.y > gridNum) {
							}else {
								float4 col = tex2D(_MainTex, pos2/gridNum );
								if(col.r > 0.2) {
									whiteNeibor++;
								}
							}	
						}
					}
				}

				//return whiteNeibor/8.0;


				float4 col = tex2D(_MainTex, pos1/gridNum);
				if(col.r > 0.2) {
					if(whiteNeibor < 1.8 || whiteNeibor > 3.2) {
						return 0;
					}else {
						return 1;
					}
				}else {
					if(abs(whiteNeibor -3) < 0.2) {
						return 1;
					}else {
						return 0;
					}
				}
				return 0;

			}

			float simpleAnim(float2 pos) {
				return tex2D(_MainTex, pos);
			}

			float lifeGame(float2 pos) {
				float2 pos1 = pos*gridNum;
				if(inInit < 0.5) {
					return InitGame(pos1); 
				}else {
					return aniGame(pos);
					/*
					if(doAnim > 0.1) {
					//return tex2D(_MainTex, pos);
					//return fmod(floor(pos1.x), 2); 
						//return aniGame(pos);
						return simpleAnim(pos);
					}else {
					}
					return tex2D(_MainTex, pos);
					*/

				}

			}



			fixed4 frag (v2f i) : SV_Target
			{
				float2 pos1 = i.uv;
				float v = lifeGame(pos1);
				return float4(v, v, v, 1);
			}

			ENDCG
		}
	}
}
