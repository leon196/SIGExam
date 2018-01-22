Shader "Unlit/outline"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_OutlineThin ("Outline Thini", Float) = .1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			float _OutlineThin;

			struct attribute
			{
				float4 position : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct varying
			{
				float4 position : SV_POSITION;
			};
			
			varying vert (attribute v)
			{
				varying o;
				o.position = v.position;
				o.position = mul(UNITY_MATRIX_M, o.position);
				o.position.xyz += normalize(v.normal)*_OutlineThin;
				o.position = mul(UNITY_MATRIX_VP, o.position);
				return o;
			}
			
			fixed4 frag (varying i) : SV_Target
			{
				return fixed4(0,0,0,0);
			}
			ENDCG
		}
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct attribute
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct varying
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			varying vert (attribute v)
			{
				varying o;
				o.position = v.position;
				o.position = mul(UNITY_MATRIX_M, o.position);
				o.position = mul(UNITY_MATRIX_VP, o.position);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (varying i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);
				return color;
			}
			ENDCG
		}
	}
}
