#ifndef SKELETONEFFECT_PASS_INCLUDED
#define SKELETONEFFECT_PASS_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes {
    float4 positionOS    : POSITION;
    float3 normalOS      : NORMAL;
    float4 tangentOS     : TANGENT;
    float2 texcoord      : TEXCOORD0;
    float2 texcoord2     : TEXCOORD1;
    float4 color         : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings {
    float4 positionCS: SV_POSITION;
    float4 uv0 : TEXCOORD1;
    float4 uv2 : TEXCOORD2;
};

struct OutEffectVaryings {
    float4 positionCS: SV_POSITION;
    float4 uv0 : TEXCOORD1;
    float3 normalWS : TEXCOORD2;
    float3 viewDirestionWS :TEXCOORD3;
};

struct OutLineVaryings {
    float4 positionCS: SV_POSITION;
};

Varyings Vertex(Attributes input) {
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.positionCS = TransformWorldToHClip(positionWS);
    output.uv0.xy = input.texcoord;
    output.uv0.zw = input.texcoord2;
    output.uv2.xy = TRANSFORM_TEX(input.texcoord, _BadyNoise);
    return output;
};

half4 Fragment(Varyings input) : SV_Target {
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float fadeoutMask = (input.uv0.w - _FadeoutEnd) / _FadeoutStart;
    fadeoutMask = saturate(fadeoutMask);

    half noise = SAMPLE_TEXTURE2D(_BadyNoise, sampler_BadyNoise, input.uv2.xy + float2(0, _Time.y * _BadyNoiseSpeed)).r;
    half stepNoise = smoothstep(fadeoutMask + _BadyFeatherValue * 0.1, fadeoutMask - _BadyFeatherValue * 0.1, noise);

    half aplha = saturate(stepNoise + fadeoutMask) * _BaseColor.a * fadeoutMask;

    return half4(_BaseColor.rgb, aplha);
};

OutLineVaryings OutlineVertex(Attributes input) {
    OutLineVaryings output = (OutLineVaryings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    float3 normalVS = mul((float3x3)UNITY_MATRIX_IT_MV, input.normalOS);
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    output.positionCS = mul(UNITY_MATRIX_P, float4(vertexInput.positionVS + normalVS * _OutlineWidth * input.color.r * 0.1, 1.0));
    return output;
}

half4 OutlineFragment(OutLineVaryings input) : SV_Target {
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    return _OutlineColor;
};

OutEffectVaryings OutEffectVertex(Attributes input) {
    OutEffectVaryings output = (OutEffectVaryings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    float3 normalVS = mul((float3x3)UNITY_MATRIX_IT_MV, input.normalOS);
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    output.positionCS = mul(UNITY_MATRIX_P, float4(vertexInput.positionVS + normalVS * _OutEffectWidth * input.color.g * 0.1 * _OutEffectSamplePercent, 1.0));
    output.uv0.xy = TRANSFORM_TEX(float2(vertexInput.positionWS.x, vertexInput.positionWS.y), _OutEffectNoise);

    return output;
}

half4 OutEffectFragment(OutEffectVaryings input) : SV_Target {
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    half mask = SAMPLE_TEXTURE2D(_OutEffectNoise, sampler_OutEffectNoise, input.uv0.xy - float2(0, _Time.y * _OutEffectSpeed)).r;
    half dither = frac((sin(input.uv0.x + input.uv0.y) * 99 + 11) * 99);
    half clipRate = _DitherIntensity - dither * 0.3;
    clip(mask - clipRate);
    half4 finalCol = half4(_OutEffectColor.rgb, mask * (1 - _OutEffectSamplePercent) * _OutEffectColor.a);
    return finalCol;
};

#endif