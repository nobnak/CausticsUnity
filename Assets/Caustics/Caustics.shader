Shader "Custom/Caustics" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "white" {}
		
		_Refraction ("Refraction Factor", Float) = 0.7518
		_Height ("Height", Float) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass {
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			
			float4 _MainTex_TexelSize;
			float4 _BumpMap_TexelSize;
			
			sampler2D _MainTex;
			sampler2D _BumpMap;
			float _Refraction;
			float _Height;

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
			
			fixed4 frag(vs2ps IN) : COLOR {
				float3 v = float3(0, 0, 1);
				float3 n = UnpackNormal(tex2D(_BumpMap, IN.uv));
				n.z *= -1;
				float3 rr = refract(v, n, _Refraction);
				rr.xy /= rr.z;
				
				fixed4 c = tex2D(_MainTex, IN.uv + rr.xy * _Height);
				return c;
			}
			ENDCG
		}
	} 
}
