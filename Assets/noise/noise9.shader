Shader "Unlit/noise9"
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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

            float myrand(float2 pos) {
           
            	return frac(sin(dot(pos.xy, float2(12.9898, 72.833)))*43758.5453123);
            }

			fixed3 rgb2hsb(fixed3  c ){
			    fixed4 K = fixed4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			    fixed4 p = lerp(fixed4(c.bg, K.wz), 
			                 fixed4(c.gb, K.xy), 
			                 step(c.b, c.g));
			    fixed4 q = lerp(fixed4(p.xyw, c.r), 
			                fixed4(c.r, p.yzx), 
			                 step(p.x, c.r));
			    float d = q.x - min(q.w, q.y);
			    float e = 1.0e-10;
			    return fixed3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), 
			                d / (q.x + e), 
			                q.x);
			}

			fixed3 hsb2rgb(fixed3  c ){
			   fixed3  rgb = clamp(abs(fmod(c.x*6.0+fixed3(0.0,4.0,2.0),
			                             6.0)-3.0)-1.0, 
			                     0.0, 
			                     1.0 );
			    rgb = rgb*rgb*(3.0-2.0*rgb);
			    return c.z * lerp(fixed3(1.0, 1.0, 1.0), rgb, c.y);
			}

			fixed step1(fixed a, fixed b, fixed x) {
				float t = saturate((x - a)/(b - a));
				return t;
			}

			fixed rectRange(fixed2 st, fixed2 size, fixed2 pos){
				fixed2 offs = pos-st;
				fixed av = step(0, offs.x)*step(0, offs.y);
				fixed bv = step(offs.x, size.x)*step(offs.y, size.y);
				return av*bv;
			}

			 float2 myrand3(float2 st) {
            	float2 st1 = float2( dot(st,float2(127.1,311.7)),
              		dot(st,float2(269.5,183.3)) );

              	return -1.0 + 2.0*frac(sin(st1)*43758.5453123);	
            }
			float noise3(float2 pos) {
				float2 i = floor(pos);
            	float2 f = frac(pos);
            	float2 u = f * f * (float2(3, 3) - 2*f);

            	return lerp( lerp( dot( myrand3(i + float2(0.0,0.0) ), f - float2(0.0,0.0) ), 
                     	dot( myrand3 (i + float2(1.0,0.0) ), f - float2(1.0,0.0) ), u.x),

                		lerp( dot( myrand3(i + float2(0.0,1.0) ), f - float2(0.0,1.0) ), 
                     dot( myrand3(i + float2(1.0,1.0) ), f - float2(1.0,1.0) ), u.x), u.y);
            		
			}

            float noise2(float2 pos) {
            	float2 intPart = floor(pos);
            	float2 fracPart = frac(pos);

            	float a = myrand(intPart);
            	float b = myrand(intPart+float2(1, 0));
            	float c = myrand(intPart+float2(0, 1));
            	float d = myrand(intPart+float2(1, 1));

            	float2 u = fracPart * fracPart * (float2(3, 3) - 2*fracPart);
            	 
				return lerp(a, b, u.x) + (c-a)*u.y*(1-u.x) + (d-b)*u.x*u.y;

            	//return lerp(myrand2(intPart), myrand2(floor(v+1)), smoothstep(0, 1, fracPart));
            	//return u.x;
            }

            float myrand2(float x) {
            	return frac(sin(x)*43758.5453123);
            }

			float noise1(float v) {
            	float intPart = floor(v);
            	float fracPart = frac(v);
            	return lerp(myrand2(intPart), myrand2(floor(v+1)), smoothstep(0, 1, fracPart));
            }
			float circle2(float2 st, float radius) {
				fixed2 st1 = st-fixed2(0.5, 0.5);
				float theta = atan2(st1.y, st1.x);

            	//fixed l = length(st1)+noise3(st1*float2(50, 50))*radius*0.2;
            	fixed l = length(st1)+noise1(theta*50)*radius*0.2;
            	return step(l, radius);
			}


            float circle(fixed2 st, fixed radius) {
            	fixed2 st1 = st-fixed2(0.5, 0.5);

            	fixed l = length(st1);
            	return step(l, radius);
            }

            float crossFunc(fixed2 st) {
            	fixed2 st1 = st-fixed2(0.5, 0.5);
            	//-0.5 0.5
            	fixed r0 = rectRange(fixed2(-0.3, -0.3), fixed2(0.6, 0.6), st1);
            	/*
            	fixed r1 = rectRange(fixed2(0.3, -0.1), fixed2(0.2, 0.2), st1);
            	fixed r2 = rectRange(fixed2(-0.5, -0.1), fixed2(0.2, 0.2), st1); 
            	fixed r3 = rectRange(fixed2(-0.1, -0.5), fixed2(0.2, 0.2), st1); 
            	fixed r4 = rectRange(fixed2(-0.1, 0.3), fixed2(0.2, 0.2), st1); 
            	*/
            	return min(r0, 1);
            }

            float rectRangeUp(fixed2 st, fixed2 size, fixed2 pos) {
	            fixed2 offs = pos-st;
				fixed av = step(0, offs.x)*step(0, offs.y);
				fixed bv = step(offs.x, size.x)*step(offs.y, size.y);
				fixed up = step(pos.x-pos.y, 0);
				return av*bv*up;	
            }

            //1 up 0 down
            float triangle2(fixed2 st, fixed2 size, fixed2 pos,  fixed up ) 
            {
            	return rectRangeUp(st, size, pos);
            }



            /*
            vec2 random2(vec2 st){
    st = vec2( dot(st,vec2(127.1,311.7)),
              dot(st,vec2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(st)*43758.5453123);
}
            */

           


            float fengche(fixed2 pos, float2 randPos) {
            	float2 pos1 = pos * fixed2(2, 2);
				float2 intPart = floor(pos1);
				float2 pos2 = frac(pos1);
				fixed xp = intPart.x;
				fixed yp = intPart.y;

				fixed partx = step(xp, 0);
				fixed party = step(yp, 0);

				float PI90 = -3.14159/2;
				//float theta = 0 + (1-partx)*party * PI90 + (1-partx)*(1-party)*2*PI90 + partx*(1-party)*3*PI90 ;


				float theta = floor(myrand(randPos)*4) * PI90;
				pos2 -= fixed2(0.5, 0.5);

				float2x2 mat1 = float2x2(cos(theta), -sin(theta), sin(theta), cos(theta));
			   	pos2 = mul( mat1,  pos2);

				fixed inRect = triangle2(fixed2(-0.5, -0.5), fixed2(1, 1),  pos2, 1);
				return inRect;
            }

           	float band(fixed2 pos, float2 randPos) {
           		float inWhite = step(myrand(randPos), 0.5);
           		return rectRange(float2(0, 0), float2(1, 1), pos) * inWhite;
           	}

           	/*
           	    return mix(a, b, u.x) + 
            (c - a)* u.y * (1.0 - u.x) + 
            (d - b) * u.x * u.y;
            */

            /*
            float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( dot( random2(i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ), 
                     dot( random2(i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
                mix( dot( random2(i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ), 
                     dot( random2(i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
}
				*/

			


			float lines(float2 pos, float2 intPos) {
				float drawLine = step(fmod(intPos.y, 2), 0);
				return drawLine;
			}

			float2 rotate(float theta, float2 pos) {
			    float2x2 mat1 = float2x2(cos(theta), -sin(theta), sin(theta), cos(theta));
			    return mul(mat1, pos);
			}

			float drops(float2 pos ) {
				float col =  smoothstep(0.18, 0.2, noise3(pos*float2(5, 5)));
				col += smoothstep(0.18, 0.2, noise3(pos*float2(10, 10)));
				col -= smoothstep(0.18, 0.2, noise3(pos*float2(20, 20)));
				return col;
			}

			/*
			vec2 skew (vec2 st) {
    vec2 r = vec2(0.0);
    r.x = 1.1547*st.x;
    r.y = st.y+0.5*r.x;
    return r;
}
			*/
			float2 skew(float2 pos) {
				float2 r = float2(0, 0);
				r.x = 1.1547 * pos.x;
				r.y = pos.y + 0.5*r.x;
				return r;
			}

			/*
			vec3 simplexGrid (vec2 st) {
    vec3 xyz = vec3(0.0);

    vec2 p = fract(skew(st));
    if (p.x > p.y) {
        xyz.xy = 1.0-vec2(p.x,p.y-p.x);
        xyz.z = p.y;
    } else {
        xyz.yz = 1.0-vec2(p.x-p.y,p.y);
        xyz.x = p.x;
    }

    return fract(xyz);
}
			*/

			float3 simplexGrid(float2 st) {
				float3 xyz = float3(0, 0,0);
				float2 p = frac(skew(st));
				if(p.x > p.y) {
					xyz.xy = p;
					//xyz.xy = float2(1.0, 1)-float2(p.x, p.y-p.x);
					//xyz.z = p.y;
				}else {
					//xyz.yz = float2(1.0, 1)-float2(p.x-p.y, p.y);
					//xyz.x = p.x;
					xyz.yz = p;
				}
				return xyz;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv1 = i.uv * float2(10, 10);
				//uv1 = skew(uv1);

				float3 col = simplexGrid(uv1);
				//col.rg = frac(uv1);
				//col.b = 0;


				return fixed4(col, 1);
			}

			ENDCG
		}
	}
}
