Shader "Unlit/frac3"
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

			 float2 myrand4(float2 st) {
            	float2 st1 = float2( dot(st,float2(127.1,311.7)),
              		dot(st,float2(269.5,183.3)) );

              	return frac(sin(st1)*43758.5453123);	
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

			fixed rectRange2(fixed2 st, fixed2 size, fixed2 pos){
				fixed2 offs = pos-st + 0.04*float2(noise2(pos*float2(50, 50)), noise2(pos*float2(40, 40)));
				fixed av = step(0, offs.x)*step(0, offs.y);
				fixed bv = step(offs.x, size.x)*step(offs.y, size.y);
				return av*bv;
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



			float cellularValue(float2 pos) {

				float2 points[4] = {
					float2(0.2, 0.4),	
					float2(0.4, 0.2),
					float2(0.5, 0.7),
					float2(0.7, 0.4),
				};

				float minDist = 1;
				for(int i = 0; i < 4; i++) {
					minDist = min(minDist, distance(pos, points[i]));
				}
				return minDist;
			}
			float cellularValue3(float2 pos) {
				float2 pos1 = pos * 10;

				float2 intPart = floor(pos1);
				float2 fracPart = frac(pos1);
				float2 centerPos = myrand4(intPart);

				float minDist = 1;
				minDist = min(minDist, distance(fracPart, centerPos));

				return minDist;
			}

			float cellularValue2(float2 pos) {
				float2 pos1 = pos * 10;

				float2 intPart = floor(pos1);
				float2 fracPart = frac(pos1);

				float2 points[9] = {
					myrand4(intPart),
					myrand4(intPart+float2(-1, 1))+float2(-1, 1),
					myrand4(intPart+float2(-1, 0))+float2(-1, 0),
					myrand4(intPart+float2(-1, -1))+float2(-1, -1),
					myrand4(intPart+float2(0, -1))+float2(0, -1),
					myrand4(intPart+float2(1, -1))+float2(1, -1),
					myrand4(intPart+float2(1, 0))+float2(1, 0),
					myrand4(intPart+float2(1, 1))+float2(1, 1),
					myrand4(intPart+float2(0, 1))+float2(0, 1),
				};
				float minDist = 1;
				for(int i = 0; i < 9; i++) {
					minDist = min(minDist, distance(fracPart, points[i]));
				}


				return minDist;
			}

			float cellularValue4(float2 pos) {
				float2 pos1 = pos*10;
				float2 intPart = floor(pos1);
				float2 fracPart = frac(pos1);

				float timeV = _Time.y * 0.1;
				float2 offP[9] = {
					float2(noise2(intPart*timeV), noise2(intPart*timeV)),
					float2(noise2((intPart+float2(-1, 1))*timeV), noise2((intPart+float2(-1, 1))*timeV)),
					float2(noise2((intPart+float2(-1, 0))*timeV), noise2((intPart+float2(-1, 0))*timeV)),
					float2(noise2((intPart+float2(-1, -1))*timeV), noise2((intPart+float2(-1, -1))*timeV)),
					float2(noise2((intPart+float2(0, -1))*timeV), noise2((intPart+float2(0, -1))*timeV)),
					float2(noise2((intPart+float2(1, -1))*timeV), noise2((intPart+float2(1, -1))*timeV)),
					float2(noise2((intPart+float2(1, 0))*timeV), noise2((intPart+float2(1, 0))*timeV)),
					float2(noise2((intPart+float2(1, 1))*timeV), noise2((intPart+float2(1, 1))*timeV)),
					float2(noise2((intPart+float2(0, 1))*timeV), noise2((intPart+float2(0, 1))*timeV)),
				};

				//intPart = intPart + 
				float2 points[9] = {
					myrand4(intPart),
					myrand4(intPart+float2(-1, 1)),
					myrand4(intPart+float2(-1, 0)),
					myrand4(intPart+float2(-1, -1)),
					myrand4(intPart+float2(0, -1)),
					myrand4(intPart+float2(1, -1)),
					myrand4(intPart+float2(1, 0)),
					myrand4(intPart+float2(1, 1)),
					myrand4(intPart+float2(0, 1)),
				};

				float2 fixP[9] = {
					float2(0, 0),
					float2(-1, 1),
					float2(-1, 0),
					float2(-1, -1),
					float2(0, -1),
					float2(1, -1),
					float2(1, 0),
					float2(1, 1),
					float2(0, 1),
				};

				float minDist = 1;
				for(int i = 0; i < 9; i++) {
					minDist = min(minDist, distance(fracPart, min(float2(1, 1), max(float2(0, 0), points[i]+offP[i]))+fixP[i] ) );
				}


				return minDist;
			}


			float cellularValue5(float2 pos) {

				float2 pos1 = pos*10;
				float2 intPart = floor(pos1);
				float2 fracPart = frac(pos1);

				float timeV = _Time.y * 1;
				float para1 = 6.21;

				float2 fixP[9] = {
					float2(0, 0),
					float2(-1, 1),
					float2(-1, 0),
					float2(-1, -1),
					float2(0, -1),
					float2(1, -1),
					float2(1, 0),
					float2(1, 1),
					float2(0, 1),
				};

				float minDist = 2;
				float2 offP = float2(0.5, 0.5);
				for(int i = 0; i < 9; i++) {
					float2 intPart1 = intPart + fixP[i];
					float randV = myrand(intPart1)*para1;
					float theta = randV + timeV; 
					float2 points = float2(sin(theta)*0.5, cos(theta)*0.5);
					float2 fix = fixP[i];

					float2 centerPos = points + offP + fix;

					 minDist = min(minDist, distance(fracPart, centerPos));
				}
				return minDist;
			}


			float2 cellularValue6(float2 pos) {

				float2 pos1 = pos*10;
				float2 intPart = floor(pos1);
				float2 fracPart = frac(pos1);

				float timeV = _Time.y * 1;
				float para1 = 6.21;

				float2 fixP[9] = {
					float2(0, 0),
					float2(-1, 1),
					float2(-1, 0),
					float2(-1, -1),
					float2(0, -1),
					float2(1, -1),
					float2(1, 0),
					float2(1, 1),
					float2(0, 1),
				};

				float minDist = 2;
				float2 color1 = float2(0, 0);

				float2 offP = float2(0.5, 0.5);
				for(int i = 0; i < 9; i++) {
					float2 intPart1 = intPart + fixP[i];
					float randV = myrand(intPart1)*para1;
					float theta = randV + timeV; 
					float2 points = float2(sin(theta)*0.5, cos(theta)*0.5);
					float2 fix = fixP[i];
					float2 centerPos = points + offP + fix;

					 float dist = distance(fracPart, centerPos);
					 if(dist < minDist) {
					 	color1 = centerPos;
					 	minDist = dist;
					 } 
				}

				//return max(color1.r, color1.g);
				return color1;
				//return color1.g;
			}

			float cellularValue7(float2 pos) {

				float2 pos1 = pos*10;
				float2 intPart = floor(pos1);
				float2 fracPart = frac(pos1);

				float timeV = _Time.y * 1;
				float para1 = 6.21;

				float2 fixP[9] = {
					float2(0, 0),
					float2(-1, 1),
					float2(-1, 0),
					float2(-1, -1),
					float2(0, -1),
					float2(1, -1),
					float2(1, 0),
					float2(1, 1),
					float2(0, 1),
				};

				float minDist = 2;
				float2 color1 = float2(0, 0);

				float2 offP = float2(0.5, 0.5);
				for(int i = 0; i < 9; i++) {
					float2 intPart1 = intPart + fixP[i];
					float randV = myrand(intPart1)*para1;
					float theta = randV + timeV; 
					float2 points = float2(sin(theta)*0.5, cos(theta)*0.5);
					float2 fix = fixP[i];
					float2 centerPos = points + offP + fix;

					 float dist = distance(fracPart, centerPos);

					 /*
					 if(dist < minDist) {
					 	color1 = centerPos;
					 	minDist = dist;
					 } 
					 */
					 minDist = min(minDist, dist);
				}

				//return max(color1.r, color1.g);
				//return color1;
				//return color1.g;

				//return color1.g;
				//return (1- step(minDist, 0.8))*minDist;
				//return (1-step(minDist, 0.5)) * minDist;
				return minDist*minDist*minDist;
				//return minDist;
			}

			float fracValue(float2 pos) {
				int num = 4;

				//0 1 0 1
				float cx = 0.5;
				float cy = 0.5;
				float sxy = 1/6.0;

				float2 pos1 = pos;
				for(int i = 0; i < num; i++) {
					float sxy2 = sxy*2;
					float inRect = rectRange(float2(cx-sxy, cy-sxy), float2(sxy, sxy)*2, pos1);
					if(inRect) {
						return 0;
					}
					if(pos1.x < (cx-sxy) && pos1.y < (cy-sxy)) {
						cx = cx - sxy2;
						cy = cy - sxy2;
					}else if((pos1.x > (cx-sxy)) && (pos1.x < (cx+sxy)) && (pos1.y < (cy-sxy))) {
						cx = cx;
						cy = cy - sxy2;
					}else if(pos1.x > (cx+sxy) && pos1.y < cy-sxy) {
						cx += sxy2;
						cy -= sxy2;
					}else if(pos1.x > (cx+sxy) && pos1.y > (cy-sxy) && pos1.y < (cy+sxy)) {
						cx += sxy2;

					}else if(pos1.x > cx+sxy && pos1.y > cy+sxy) {
						cx += sxy2;
						cy += sxy2;
					}else if(pos1.x > cx-sxy && pos1.x < cx+sxy && pos1.y > cy+sxy) {
						cy += sxy2;
					}else if(pos1.x < cx-sxy && pos1.y > cy + sxy) {
						cx -= sxy2;
						cy += sxy2;
					}
					else {
						cx -= sxy2;

					}
					sxy = sxy/3;
				}
				return 1;
			}

			float fracValue2(float2 pos) {
				int num = 5;
				float ca = 0;
				float cb = 1;

				for(int i = 0; i < num; i++) {
					float mid = (ca+cb)/2;
					float width = (cb-ca)/10;
					float wid2 = width/2;
					float left = mid-wid2;
					float right = mid+wid2;
					float inMid = step(pos.x, right) * step(left, pos.x);
					if(inMid) {
						return 0;
					}else {
						if(pos.x < left) {
							cb = left;
						}else {
							ca = right;
						}
					}
				}
				return 1;
			}

			/*
			float sign (fPoint p1, fPoint p2, fPoint p3)
{
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

bool PointInTriangle (fPoint pt, fPoint v1, fPoint v2, fPoint v3)
{
    bool b1, b2, b3;

    b1 = sign(pt, v1, v2) < 0.0f;
    b2 = sign(pt, v2, v3) < 0.0f;
    b3 = sign(pt, v3, v1) < 0.0f;

    return ((b1 == b2) && (b2 == b3));
}
			*/

			float TriSign(float2 p1, float2 p2, float2 p3) {
		   		return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
			}

			float PointInTriangle(float2 pt, float2 p1, float2 p2, float2 p3) {
				float b1 = 1-step(TriSign(pt, p1, p2), 0);
				float b2 = 1-step(TriSign(pt, p2, p3), 0);
				float b3 = 1-step(TriSign(pt, p3, p1), 0);

				//return (1-(b1-b2));
				//return 1-b3;
				return (b2==b3) && (b1 == b2);
			}


			float fracValue3(float2 pos) {
				int num = 4;
				float2 ap = float2(0, 0);
				float2 bp = float2(1, 0);

				float tan60 = 1.732;

				float find = 0;
				for(int i = 0; i < num; i++) {
					float2 baDir = bp-ap;
					float len = length(baDir);
					float2 danwei = baDir/len;
					float2 chuizhiDir = rotate(1.57, danwei);

					float2 pa = pos-ap;
					float touying = dot(pa, danwei);
					float left = len/3;
					float right = len*2/3;
					float mid = len/2;
					float halfEdge = len/6;

					float2 chuizhi = pa-touying*danwei;
					float chuiLen = length(chuizhi);

					float2 lp = ap + left*danwei;
					float2 rp = ap + right*danwei;

					float2 cp = ap + mid*danwei + chuizhiDir*tan60*halfEdge;
					//float2 ep = ap + danwei;

					//float tpoint = step(length(pos-lp), 0.02) + step(length(pos-rp), 0.02)+step(length(pos-cp), 0.02);
					//return step(length(pos-ep), 0.02);
					//return ;

					float inTri = PointInTriangle(pos, lp, rp, cp);
					//float inTri = 0;
					//return inTri+tpoint; 
					if(inTri == 1) {
						find = 1;
						break;
					}else {
						if(touying > left && touying < mid) {
							ap = lp;
							bp = cp;
						}else if(touying > mid && touying < right){
							ap = cp;
							bp = rp;
						}else if(touying > 0 && touying < left) {
							bp = lp;
						}else if(touying > right && touying < 1) {
							ap = rp;
						}else {
							break;
						}
					}


					/*
					float inMid = step(touying, right) * step(left, touying);
					if(inMid) {
						float height = len/6 * tan60;

						float inTri = PointInTriangle(float2(touying, chuiLen), float2(left, 0), float2(right, 0), float2(0, height));
						if(inTri > 0) {
							return 1;
						}else if(touying < mid){
							float2 apNew = danwei*left+ap;
							float2 bpNew = danwei*mid+ap+chuizhiDir*height;
							ap = apNew;
							bp = bpNew;	
						}else {
							float2 apNew = danwei*mid+ap+chuizhiDir*height;	
							float2 bpNew = danwei*right+ap;
							ap = apNew;
							bp = bpNew;
						}
					}else if(step(0, touying) * step(touying, left)) {
						bp = danwei*left +ap;

					}else if(step(right, touying) * step(touying, 1)) {
						ap = danwei*right+ap;
					}else {
						return 0;
					}
					*/
				}

				return find;
			}

			fixed4 frag (v2f i) : SV_Target
			{

				float cv = fracValue3(i.uv);
				return fixed4(cv, cv ,cv ,1);
			}

			ENDCG
		}
	}
}
