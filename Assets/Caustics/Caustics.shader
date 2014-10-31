Shader "Custom/Caustics" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "black" {}
		_CausticTex ("Caustics Map", 2D) = "black" {}
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
			float4 _CausticTex0_TexelSize;
			
			sampler2D _MainTex;
			sampler2D _CausticTex0;
			sampler2D _CausticTex1;
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
				float2 dx = _CausticTex0_TexelSize.xy;
				float I = 0.0;
				I += tex2D(_CausticTex0, IN.uv + float2(0, +3) * dx).r;
				I += tex2D(_CausticTex0, IN.uv + float2(0, +2) * dx).g;
				I += tex2D(_CausticTex0, IN.uv + float2(0, +1) * dx).b;
				I += tex2D(_CausticTex0, IN.uv).a;
				I += tex2D(_CausticTex1, IN.uv + float2(0, -1) * dx).r;
				I += tex2D(_CausticTex1, IN.uv + float2(0, -2) * dx).g;
				I += tex2D(_CausticTex1, IN.uv + float2(0, -3) * dx).b;
				return I * _IFact;
			}
			ENDCG
		}
	} 
}
