// adapted from http://bl.ocks.org/robinhouston/ed597847175cf692ecce

Shader "Custom/ReactionDiffusion" {
        Properties {  
         _MainTex ("_MainTex", 2D) = "white" {}
         
         brushPosition ("brushPosition", Vector) = (0,0,0.0,1.0)
         brushSize("brushSize", Float) = 0.25
         diffuseA ("diffuseA", Range(0,2.5)) = 0.2
         diffuseB ("diffuseB", Range(0,2.5)) = 0.1
         feed ("feed", Range(0,0.1)) = 0.0545
         kill ("kill", Range(0,0.15)) = 0.062
         clear ("clear", Range(0,1)) = 0

			inInit ("initYet", float) = 0

     } 

    SubShader { 
        Pass {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_TexelSize;
            uniform float clear;
            
            uniform float diffuseA;
 			uniform float diffuseB;
 			uniform float deltaT;
            uniform float feed;
            uniform float kill;
                      
            uniform float4 brushPosition;   
            uniform float  brushSize;           

			float inInit;

			float4 InitReact(float2 pos) {
				float2 gd = float2(pos);

				if (length(gd-float2(0.5, 0.5)) < 0.1) {
					return float4(0, 1, 0, 0);
				}

            		return float4(1, 0, 0, 1);
			}


            fixed4 frag(v2f_img i) : SV_Target { 
            	if(inInit < 0.5) {
					return InitReact(i.uv);
            	}

           		float step_x = _MainTex_TexelSize.x;
				float step_y = _MainTex_TexelSize.y;

	        	if(clear==1.0){
	                return fixed4(0.0,0.0,0.0,1.0);
	        	}

	   			// texel coordinate
	   		    float2 tc = i.uv;
	                        
	   			// current quantity: center            
	            float2 val = tex2D(_MainTex, tc).rg ;
	            
	            // current quantity: left-right, up-down neighbor
				float2 val0 = tex2D(_MainTex, tc+float2(-step_x, 0.0)).rg;
	            float2 val1 = tex2D(_MainTex, tc+float2(step_x, 0.0)).rg;
	            float2 val2 = tex2D(_MainTex, tc+float2(0.0, -step_y)).rg;
	            float2 val3 = tex2D(_MainTex, tc+float2(0.0, step_y)).rg;
	        	        	
	        	// calculate laplace        	
	        	float2 laplace = val0+val1+val2+val3 - 4*val;
	        	
	        	// calculate delta quantities
	        	float du = diffuseA * laplace.r - val.r*val.g*val.g + feed*(1.0 - val.r);
	            float dv = diffuseB * laplace.g + val.r*val.g*val.g - (feed+kill)*val.g;

	            // calculate new quantities	            
	            float dt = 1;
	        	float2 dst = val + float2(du, dv)* dt;
	        	
	        	// apply brush if user clicked anywhere on screen
	   			if(brushPosition.x > 0.0 && brushPosition.y > 0.0){
	                float2 diff = i.uv - brushPosition.xy;
	                float dist = dot(diff, diff);
	                if(dist < brushSize){
	                    dst.g = 0.2;
	                }
	            }

	            return float4(dst, 0.0, 1.0);
            }
            ENDCG
        }
    }
}