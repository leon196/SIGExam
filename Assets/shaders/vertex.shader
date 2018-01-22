Shader "Unlit/vertex"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

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
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct varying
			{
				float4 position : SV_POSITION;
				float3 normal : NORMAL;
				float3 view : TEXCOORD1;
				float2 uv : TEXCOORD0;
			};

			float rand(float2 co) {
			  return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
			}

			float3 applyVague (float3 pos) {
				pos.x += sin(pos.y)*.5;
				return pos;
			}

			float3 applyChubby (float3 pos, float3 normal) {
				pos += normal * .5;
				return pos;
			}

			float3 applySkinny (float3 pos, float3 normal) {
				pos += normal * -.5;
				return pos;
			}

			float3 applyTwist (float3 pos) {
				float a = atan2(pos.z, pos.x);
				a += pos.y*.5+.8;
				pos.xz = float2(cos(a),sin(a))*length(pos.xz);
				return pos;
			}

			float3 applyGlitch (float3 pos, float3 normal) {
				pos -= normal * rand(pos.xz) * 2.;
				return pos;
			}

			float3 applyGlitchVoxel (float3 pos, float3 normal) {
				pos = applyGlitch(pos, normal);
				float lod = .5;
				pos = floor(pos*lod)/lod;
				return pos;
			}
			
			varying vert (attribute v)
			{
				varying o;
				o.position = v.position;
				o.position = mul(UNITY_MATRIX_M, o.position);
				float3 p = o.position.xyz;
				float3 normal = normalize(v.normal);

				// p = applyVague(p);
				// p = applyChubby(p, normal);
				// p = applySkinny(p, normal);
				// p = applyTwist(p);
				// p = applyGlitch(p, normal);
				// p = applyGlitchVoxel(p, normal);

				o.position.xyz = p;
				o.view = normalize(_WorldSpaceCameraPos-p);
				o.normal = normal;
				o.position = mul(UNITY_MATRIX_VP, o.position);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 applyBasicShading (fixed4 diffuse, float3 lightDirection, float3 normal)
			{
				float shade = dot(lightDirection, normal);
				return diffuse * shade;
			}

			fixed4 applyToonShading (fixed4 diffuse, float3 lightDirection, float3 normal)
			{
				float shade = dot(lightDirection, normal);
				float lod = 4.;
				shade = ceil(shade*lod)/lod;
				return diffuse * shade;
			}
			
			fixed4 frag (varying i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);
				float3 lightDirection = float3(0,1,0);
				// float3 lightDirection = i.view;

				// color = applyBasicShading(color, lightDirection, i.normal);
				// color = applyToonShading(color, lightDirection, i.normal);
				
				return color;
			}
			ENDCG
		}
	}
}
