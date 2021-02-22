Shader "Test/shd_skeletonEffect_v1" {
    Properties {
        [Header(Bady)]
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _BadyNoise ("Bady Noise", 2D) = "White"{}
        _BadyNoiseSpeed ("Bady Noise Speed", float) = 0.5
        _BadyFeatherValue ("Bady Feather Value", float) = 0.1

        _FadeoutStart ("FadeoutStart", float) = 0.5
        _FadeoutEnd ("FadeoutEnd", float) = 0.1

        [Header(Outline)]
        _OutlineWidth ("Outline Width", float) = 1
        [HDR]_OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)

        [Header(Out Effect)]
        _OutEffectColor ("Out Effect Color", Color) = (1, 1, 1, 1)
        _OutEffectWidth ("Out Effect Width", float) = 1
        _OutEffectNoise ("Out Effect Noise", 2D) = "White"{}
        _OutEffectSpeed ("Out Effect Speed", float) = 0.1
        _OutEffectFeatherValue ("Out Effect Feather value", float) = 0.5
        _DitherIntensity ("Out Effect Dither Intensity", float) = 0.45
    }
    SubShader {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline"}
        Pass {
            Name "BaseColor"
            Tags { "LightMode" = "UniversalForward" }
            Stencil {
                Ref 20
                Comp Greater
                Pass Replace
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "skeletonEffectInput.hlsl"
            #include "skeletonEffectPass.hlsl"
            ENDHLSL
        }

        Pass {
            Name "Outline"
            Stencil {
                Ref 10
                Comp Greater
            }
            ZWrite off

            HLSLPROGRAM
            #pragma vertex OutlineVertex
            #pragma fragment OutlineFragment

            #include "skeletonEffectInput.hlsl"
            #include "skeletonEffectPass.hlsl"
            ENDHLSL
        }

        Pass {
            Name "OutEffect"
            Tags { "LightMode" = "OutEffect" }
            Stencil {
                Ref 1
                Comp Greater
                Pass Replace
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite off

            HLSLPROGRAM
            #pragma vertex OutEffectVertex
            #pragma fragment OutEffectFragment

            #include "skeletonEffectInput.hlsl"
            #include "skeletonEffectPass.hlsl"
            ENDHLSL
        }
    }
}