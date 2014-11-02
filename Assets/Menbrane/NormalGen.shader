Shader "Custom/NormalGen" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Dx ("Delta X", Float) = 1
		_Gain ("Height Gain", Float) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass {
			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			float4 _MainTex_TexelSize;

			sampler2D _MainTex;
			float _Dx;
			float _Gain;
			
			struct Input {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			
			Input vert(Input IN) {
				Input OUT;
				OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.uv = IN.uv;
				return OUT;
			}

			float4 frag(Input IN) : COLOR {
				float2 dtex = _MainTex_TexelSize.xy;			
				float hx0 = tex2D(_MainTex, IN.uv + float2(-0.5, 0) * dtex).r;
				float hx1 = tex2D(_MainTex, IN.uv + float2(+0.5, 0) * dtex).r;
				float hy0 = tex2D(_MainTex, IN.uv + float2(0, -0.5) * dtex).r;
				float hy1 = tex2D(_MainTex, IN.uv + float2(0, +0.5) * dtex).r;
				
				float dhdx = _Gain * (hx1 - hx0) / _Dx;
				float dhdy = _Gain * (hy1 - hy0) / _Dx;
				float3 n = normalize(float3(-dhdx, -dhdy, 1.0));
				return float4(0.5 * (n + 1.0), 1.0);
			}
			ENDCG
		}
	} 
}
