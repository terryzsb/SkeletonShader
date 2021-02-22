#ifndef SKELETONEFFECT_INPUT_INCLUDED
#define SKELETONEFFECT_INPUT_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
float _OutlineWidth;
float _BadyFeatherValue;
float _BadyNoiseSpeed;
float _FadeoutStart;
float _FadeoutEnd;
float _OutEffectFeatherValue;
float _OutEffectWidth;
float _OutEffectSpeed;
float _DitherIntensity;

half4 _BaseColor;
half4 _OutlineColor;
half4 _OutEffectColor;
float4 _BadyNoise_ST;
float4 _OutEffectNoise_ST;
CBUFFER_END

float _OutEffectSamplePercent;

TEXTURE2D(_BadyNoise);
SAMPLER(sampler_BadyNoise);
TEXTURE2D(_OutEffectNoise);
SAMPLER(sampler_OutEffectNoise);
#endif