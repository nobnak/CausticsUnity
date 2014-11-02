Shader "Custom/Menbrane" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_T ("Tension", Float) = 1.0
		_Dt ("Delta T", Float) = 0.01
		_Dx ("Delta X", Float) = 0.01
		_K ("Damping", Vector) = (0, 0, 0, 0)
	}
	SubShader { 			
		ZTest Always Cull Off ZWrite Off Fog { Mode Off }
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _T;
			float _Dt;
			float _Dx;
			float4 _K;
			
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
	} 
	FallBack "Diffuse"
}
