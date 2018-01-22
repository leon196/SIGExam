Shader "Hidden/filter"
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

			float rand(float2 co) {
			  return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
			}

			float colorDistance (float4 a, float4 b) {
				return (abs(a.r-b.r)+abs(a.g-b.g)+abs(a.b-b.b))/3.;
			}

			// page 1

			float2 applyMirror (float2 uv) {
				uv.y = 1.-uv.y;
				return uv;
			}

			float2 applySymmetry (float2 uv) {
				uv.y = abs(uv.y-.5)+.5;
				return uv;
			}

			float2 applyRotation (float2 uv) {
				uv -= .5;
				uv.x *= _ScreenParams.x/_ScreenParams.y;
				float a = atan2(uv.y,uv.x);
				a += .6;
				uv = float2(cos(a),sin(a))*length(uv);
				uv.x *= _ScreenParams.y/_ScreenParams.x;
				uv += .5;
				return uv;
			}

			float2 applyZoom (float2 uv) {
				uv -= .5;
				uv *= .5;
				uv += .5;
				return uv;
			}

			float2 applyZoomDistortion (float2 uv) {
				uv -= .5;
				float l = length(uv);
				uv *= smoothstep(.0,.5,l);
				uv += .5;
				return uv;
			}

			float2 applyRepeat (float2 uv) {
				float s = 4.;
				float c = .5;
				uv -= c/2.;
				uv = fmod((uv+c/2.)*s, c);
				uv += c/2.;
				return uv;
			}

			float2 applySpiral (float2 uv) {
				uv -= .5;
				uv.x *= _ScreenParams.x/_ScreenParams.y;
				float l = length(uv)-.1;
				float a = atan2(uv.y,uv.x);
				a += l*10.;
				uv = float2(cos(a),sin(a))*length(uv);
				uv += .5;
				return uv;
			}

			float2 applyRayon (float2 uv) {
				uv -= .5;
				uv.x *= _ScreenParams.x/_ScreenParams.y;
				float l = length(uv)+1.;
				l = exp(l);
				float a = 4.*atan2(uv.y,uv.x)/3.14159;
				uv = fmod(abs(float2(a,l))+.5, 1.);
				return uv;
			}

			// page 2

			float2 applyClamp (float2 uv) {
				uv.y = clamp(uv.y, .56, .7);
				return uv;
			}

			float2 applyDoubleFrequence (float2 uv) {
				uv -= .5;
				float dir = sin(abs(uv.y*1000.));
				uv.x += sign(dir)*.05;
				uv += .5;
				return uv;
			}

			float2 applyPixel (float2 uv) {
				float2 lod = _ScreenParams.xy/16.;
				return floor(uv*lod)/lod;
			}

			float2 applyWave (float2 uv) {
				uv.x += sin(uv.y*100.)*.05;
				return uv;
			}

			float2 applyPli (float2 uv) {
				uv -= .5;
				uv.y += abs(uv.x)*.5;
				uv += .5;
				return uv;
			}

			float2 applyColumn (float2 uv) {
				float lod = 1.;
				uv.x += (sin(floor(uv.y*20.*lod)/lod))*.1;
				return uv;
			}

			float2 applyCrash (float2 uv) {
				float lod = _ScreenParams.xy/8.;
				uv += (rand(floor(uv*lod)/lod)*2.-1.)*.1;
				return uv;
			}

			float2 applyScanline (float2 uv) {
				uv.x += (rand(uv.yy)*2.-1.)*.1*smoothstep(.0,1.,sin(uv.y*5.));
				return uv;
			}

			float2 applyDirectionCouleur (float2 uv) {
				fixed4 color = tex2D(_MainTex, uv);
				float a = 3.14159*2.*Luminance(color)+_Time.y;
				uv += float2(cos(a),sin(a))*.05;
				return uv;
			}

			// page 3

			fixed4 applyBlackWhite (fixed4 color) {
				return fixed4(1,1,1,1) * Luminance(color);
			}

			fixed4 applySeuil (fixed4 color) {
				float s = step(.8, Luminance(color));
				return fixed4(s,s,s,s);
			}

			float4 applySeuils (float4 color) {
				float lod = 4.;
				color = ceil(color*lod)/lod;
				return color;
			}

			float4 applySonar (float4 color, float2 uv) {
				uv -= .5;
				uv.x *= _ScreenParams.x/_ScreenParams.y;
				color *= .5+.5*smoothstep(-1.,-.9,sin(length(uv)*200.));
				return color;
			}

			float4 applyGrille (float4 color, float2 uv) {
				uv.x *= _ScreenParams.x/_ScreenParams.y;
				color *= .5+.5*smoothstep(-1.,-.9,sin(uv.y*200.));
				color *= .5+.5*smoothstep(-1.,-.9,sin(uv.x*200.));
				return color;
			}

			float4 applyTamponLaPoste (float4 color, float2 uv) {
				uv.x *= _ScreenParams.x/_ScreenParams.y;
				color *= .5+.5*smoothstep(-1.,-.9,sin(uv.y*200.+sin(uv.x*30.)*2.));
				return color;
			}

			float4 applyNegativeLocale (float4 color, float2 uv) {
				uv -= .5;
				uv.x *= _ScreenParams.x/_ScreenParams.y;
				float l = step(length(uv-float2(0,.1)), .15);
				color = lerp(color, 1.-color, l);
				return color;
			}

			float4 applyAberrationChromatique (float4 color, float2 uv) {
				float scale = .01;
				float a = 0.;
				float2 uvR = float2(cos(a),sin(a))*scale;
				a += 3.14159;
				float2 uvG = float2(cos(a),sin(a))*scale;
				a += 3.14159;
				float2 uvB = float2(cos(a),sin(a))*scale;
				color.r = tex2D(_MainTex, uv+uvR).r;
				color.g = tex2D(_MainTex, uv+uvG).g;
				color.b = tex2D(_MainTex, uv+uvB).b;
				return color;
			}

			float4 applyChromaKey (float4 color) {
				float lum = Luminance(color);
				float chromaKey = colorDistance(color, float4(1,1,0,0));
				color = lerp(float4(0,1,0,1)*lum, color, smoothstep(.1,.4, chromaKey));
				return color;
			}

			fixed4 frag (v2f_img i) : SV_Target
			{
				float2 uv = i.uv;

				// page 1
				// uv = applyMirror(uv);
				// uv = applySymmetry(uv);
				// uv = applyRotation(uv);
				// uv = applyZoom(uv);
				// uv = applyZoomDistortion(uv);
				// uv = applyRepeat(uv);
				// uv = applySpiral(uv);
				// uv = applyRayon(uv);

				// page 2
				// uv = applyClamp(uv);
				// uv = applyPli(uv);
				// uv = applyDirectionCouleur(uv);
				// uv = applyPixel(uv);
				// uv = applyWave(uv);
				// uv = applyColumn(uv);
				// uv = applyCrash(uv);
				// uv = applyScanline(uv);
				// uv = applyDoubleFrequence(uv);

				fixed4 color = tex2D(_MainTex, uv);

				// page 3 
				// color = applyBlackWhite(color);
				// color = applySeuil(color);
				// color = applySeuils(color);
				// color = applySonar(color, uv);
				// color = applyGrille(color, uv);
				// color = applyTamponLaPoste(color, uv);
				// color = applyNegativeLocale(color, uv);
				// color = applyAberrationChromatique(color, uv);
				// color = applyChromaKey(color);
				
				return color;
			}
			ENDCG
		}
	}
}
