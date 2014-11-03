Shader "Custom/Menbrane" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_T ("Tension", Float) = 1.0
		_Dt ("Delta T", Float) = 0.01
		_Dx ("Delta X", Float) = 0.01
		_K ("Damping", Vector) = (0, 0, 0, 0)
		_Gain ("Height Gain", Float) = 1
	}
	SubShader { 			
		ZTest Always Cull Off ZWrite Off Fog { Mode Off }
		
		CGINCLUDE
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _T;
			float _Dt;
			float _Dx;
			float4 _K;
			float _Gain;
			
			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			struct vs2ps {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			
			vs2ps vert(appdata IN) {
				vs2ps OUT;
				OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.uv = IN.uv;
				return OUT;
			}
		ENDCG
		
		Pass {
			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag

			float4 frag(vs2ps IN) : COLOR {
				float2 dTex = _MainTex_TexelSize.xy;
				float4 h1 = tex2D(_MainTex, IN.uv);
				float4 h_x2 = tex2D(_MainTex, IN.uv + float2( 1,  0) * dTex);
				float4 h_x0 = tex2D(_MainTex, IN.uv + float2(-1,  0) * dTex);
				float4 h_y2 = tex2D(_MainTex, IN.uv + float2( 0,  1) * dTex);
				float4 h_y0 = tex2D(_MainTex, IN.uv + float2( 0, -1) * dTex);
				
				// h(t), v(t)
				float h = h1.x;
				float v = h1.y;
				float dhdx = (h_x2.x + h_x0.x + h_y2.x + h_y0.x - 4.0 * h) / _Dx;
				float f = _T * dhdx;
				v = (v + f * _Dt) * (1.0 - _K.y * _Dt);
				h = (h + v * _Dt) * (1.0 - _K.x * _Dt);
				return float4(h, v, 0, 0);				
			}
			ENDCG
		}
		Pass {
			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag

			float4 frag(vs2ps IN) : COLOR {
				float2 dtex = _MainTex_TexelSize.xy;			
				float hx0 = tex2D(_MainTex, IN.uv + float2(-0.5, 0) * dtex).r;
				float hx1 = tex2D(_MainTex, IN.uv + float2(+0.5, 0) * dtex).r;
				float hy0 = tex2D(_MainTex, IN.uv + float2(0, -0.5) * dtex).r;
				float hy1 = tex2D(_MainTex, IN.uv + float2(0, +0.5) * dtex).r;
				
				float dhdx = _Gain * (hx1 - hx0) / _Dx;
				float dhdy = _Gain * (hy1 - hy0) / _Dx;
				float3 n = normalize(float3(-dhdx, -dhdy, 1.0));
				//return float4(0.5 * (n + 1.0), 1.0);
				return float4(n, 1.0);
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
