Shader "Custom/CausticsGen" {
	Properties {
		_BumpMap ("Normal Map", 2D) = "white" {}
		_Refraction ("Refraction Factor", Float) = 0.7518
		_Height ("Height", Float) = 0.1
		_LightDir ("Light Direction", Vector) = (0, 0, 1, 0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		ZWrite Off ZTest Always Cull Off Fog { Mode Off }
		
		Pass {
			CGPROGRAM
			#define N 4
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			float4 _BumpMap_TexelSize;

			sampler2D _BumpMap;
			float4 _Caustics_TS;
			float2 _UvC_Offset;
			float _Refraction;
			float _Height;
			float3 _LightDir;
			int _NOffset;

			struct Input {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				
			};
			struct vs2ps {
				float4 vertex : POSITION;
				float2 uvC : TEXCOORD0;
				float2 pG : TEXCOORD1;
			};

			vs2ps vert(Input IN) {
				vs2ps OUT;
				OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.uvC = IN.uv + _UvC_Offset;
				OUT.pG = IN.uv * _Caustics_TS.zw;
				return OUT;
			}
			
			float2 GetIntersection(float2 uvC) {
				float3 n = UnpackNormal(tex2D(_BumpMap, uvC));
				n.z *= -1;
				float3 rr = refract(_LightDir, n, _Refraction);
				rr.xy /= rr.z;
				
				return uvC + rr.xy * _Height;
			}
			float4 frag(vs2ps IN) : COLOR {
				float I[N];
				float pGy[N];
				for (int i = 0; i < N; i++) {
					I[i] = 0.0;
					pGy[i] = IN.pG.y + (i + _NOffset);
				}
				
				for (int i = 0; i < N; i++) {
					float2 uvC = IN.uvC + (i + _NOffset) * _Caustics_TS.xy;
					float2 pIntersect = GetIntersection(uvC) * _Caustics_TS.zw;
					float ax = max(0, 1 - abs(IN.pG.x - pIntersect.x));
					for (int j = 0; j < N; j++) {
						float ay = max(0, 1 - abs(pGy[j] - pIntersect.y));
						I[j] += ax * ay;
					}
				}
			
				return float4(I[0], I[1], I[2], I[3]);
			}
			ENDCG
		}
		
		Pass {
			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			float4 _CausticYTex0_TexelSize;
						
			sampler2D _CausticYTex0;
			sampler2D _CausticYTex1;
			
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
				float2 dx = _CausticYTex0_TexelSize.xy;
				float I = 0.0;
				I += tex2D(_CausticYTex0, IN.uv + float2(0, +3) * dx).r;
				I += tex2D(_CausticYTex0, IN.uv + float2(0, +2) * dx).g;
				I += tex2D(_CausticYTex0, IN.uv + float2(0, +1) * dx).b;
				I += tex2D(_CausticYTex0, IN.uv).a;
				I += tex2D(_CausticYTex1, IN.uv + float2(0, -1) * dx).r;
				I += tex2D(_CausticYTex1, IN.uv + float2(0, -2) * dx).g;
				I += tex2D(_CausticYTex1, IN.uv + float2(0, -3) * dx).b;
				
				return float4(I, 0, 0, 1);
			}
			ENDCG
		}
	} 
}
