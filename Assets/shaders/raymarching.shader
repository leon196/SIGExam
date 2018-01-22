Shader "Hidden/raymarching"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;

			// Raymarching constants
			#define STEPS 30.
			#define VOLUME .001
			#define PI 3.14159
			#define TAU (2.*PI)
			#define DENSITY .02
			#define MIN_DIST .04
			
			// SDF shorcuts
			#define sdist(p,r) (length(p)-r)
			#define repeat(p,r) (fmod(abs(p),r)-r/2.)

			// Jonathan Giroux
			float pyramid (float3 p, float s) {
				return dot((p),normalize(sign(p)))-s;
			}

			float amod (in out float2 p, float count) {
				float an = TAU/count;
				float a = atan2(p.y,p.x)+an/2.;
				float c = floor(a/an);
				a = fmod(abs(a),an)-an/2.;
				p = float2(cos(a),sin(a))*length(p);
				return c;
			}

			// Inigo Quilez 
			float hash( float n )
			{
			  return frac(sin(n)*43758.5453);
			}

			// Inigo Quilez 
			float noiseIQ( float3 x )
			{
			  float3 p = floor(x);
			  float3 f = frac(x);
			  f       = f*f*(3.0-2.0*f);
			  float n = p.x + p.y*57.0 + 113.0*p.z;
			  return lerp(lerp(lerp( hash(n+0.0), hash(n+1.0),f.x),
			   lerp( hash(n+57.0), hash(n+58.0),f.x),f.y),
			  lerp(lerp( hash(n+113.0), hash(n+114.0),f.x),
			   lerp( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
			}

			// 2D rotation 
			void rot (in out float2 p, float a) { float c=cos(a),s=sin(a); p = mul(float2x2(c,-s,s,c), p); }

			// Smooth minimum
			float smin (float a, float b, float r) {
				float h = clamp(.5+.5*(b-a)/r, 0., 1.);
				return lerp(b,a,h)-r*h*(1.-h);
			}

			float sphere (float3 p) {
				return sdist(p, 1.);
			}

			float sphereRepeat (float3 p) {
				p.y = repeat(p.y, 1.);
				return sdist(p, .5);
			}

			float polarModulo (float3 p) {
				amod(p.xz, 5.);
				p.x -= 1.;
				return sdist(p, .5);
			}

			float tubeTwist (float3 p) {
				rot(p.xz, p.y);
				amod(p.xz, 8.);
				p.x -= 1.;
				return sdist(p.xz, .1);
			}

			float tubeWeb (float3 p) {
				float scene = 1000.;
				amod(p.xz, 8.);
				p.x = repeat(p.x, .5);
				scene = min(scene, sdist(p.yz, .1));
				scene = min(scene, sdist(p.yx, .1));
				return scene;
			}

			float cloud (float3 p) {
				float n = noiseIQ(p*4.)*noiseIQ(p*10.);
				return sdist(p, 1.+n);
			}

			float map (float3 p) {
				float scene = 1000.;

				scene = sphere(p);
				// scene = sphereRepeat(p);
				// scene = pyramid(p, .5);
				// scene = polarModulo(p);
				// scene = tubeTwist(p);
				// scene = tubeWeb(p);
				// scene = cloud(p);

				return scene;
			}

			float3 LookAt (float3 p, float3 t, float2 uv) {
				float3 forward = normalize(t-p);
				float3 right = normalize(cross(float3(0,1,0), forward));
				float3 up = normalize(cross(forward, right));
				return normalize(forward + uv.x * right + uv.y * up);
			}

			fixed4 raymarching (float2 uv) {
				float3 eye = float3(.5,2,-3);
				float3 ray = LookAt(eye, float3(0,0,0), uv);
				float3 pos = eye;
				float shade = 0.;
				for (float i = 0.; i <= 1.; i += 1./STEPS) {
					float dist = map(pos);
					if (dist < VOLUME) {
						// shade += DENSITY;
						shade = 1.-i;
						break;
					}
					// dist = max(MIN_DIST, dist);
					pos += ray * dist;
				}
				fixed4 color = fixed4(1,1,1,1);
				color *= shade;
				color = 1.-color;
				return color;
			}

			fixed4 frag (v2f_img i) : SV_Target
			{
				float2 uv = i.uv*2.-1.;
				uv.x *= _ScreenParams.x/_ScreenParams.y;
				return raymarching(uv);
			}
			ENDCG
		}
	}
}
