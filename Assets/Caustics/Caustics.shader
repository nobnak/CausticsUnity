Shader "Custom/Caustics" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "black" {}
		_BumpMap ("Normal Map", 2D) = "white" {}
		_CausticTex ("Caustics Map", 2D) = "black" {}
		_ViewDir ("View Dir", Vector) = (0, 0, 1, 0)
		_IFact ("Intensity Factor", Float) = 1
		_Refraction ("Refraction Factor", Float) = 0.7518
		_Height ("Height", Float) = 0.1
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
			float4 _BumpMap_TexelSize;
			float4 _CausticTex_TexelSize;
			
			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _CausticTex;
			float3 _ViewDir;
			float _IFact;
			float _Refraction;
			float _Height;

			struct Input {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			struct vs2ps {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			
			vs2ps vert(Input IN) {
				vs2ps OUT;
				OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.uv = IN.uv;
				return OUT;
			}
			
			float4 frag(vs2ps IN) : COLOR {
				float3 n = UnpackNormal(tex2D(_BumpMap, IN.uv));
				n.z *= -1;
				float3 rr = refract(_ViewDir, n, _Refraction);
				rr.xy /= rr.z;
				
				float2 uvG = IN.uv + rr.xy * _Height;
				float4 cMain = tex2D(_MainTex, uvG);
				float caustic = tex2D(_CausticTex, uvG).r;
				return cMain * (1.0 + caustic * _IFact);
			}
			ENDCG
		}
	} 
}
