Shader "Custom/Color" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1, 1, 1, 1)
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
			
			sampler2D _MainTex;
			float4 _Color;
			
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
				float4 c = tex2D(_MainTex, IN.uv);
				return c * _Color;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
