Shader "Custom/CausticsGen" {
	Properties {
		_BumpMap ("Normal Map", 2D) = "white" {}
		_Refraction ("Refraction Factor", Float) = 0.7518
		_Height ("Height", Float) = 0.1
		_LightDir ("Light Direction", Vector) = (0, 0, 1, 0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
	
			float4 _TexelSize;

			sampler2D _BumpMap;
			float3 _LightDir;

			struct Input {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			struct vs2ps {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			struct Output {
				float4 intensity0 : COLOR0;
				float4 intensity1 : COLOR1;
			};

			vs2ps vert(Input IN) {
				vs2ps OUT;
				OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.uv = IN.uv;
				return OUT;
			}
			Output frag(vs2ps IN) {
				Output OUT;
				
				return OUT;
			}
			ENDCG
		}
	} 
}
