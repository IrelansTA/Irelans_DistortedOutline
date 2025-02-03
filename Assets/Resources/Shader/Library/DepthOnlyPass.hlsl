#ifndef UNIVERSAL_DEPTH_ONLY_PASS_SPINE_INCLUDED
#define UNIVERSAL_DEPTH_ONLY_PASS_SPINE_INCLUDED



#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


TEXTURE2D(_MainTex);        SAMPLER(sampler_MainTex);
half _Cutoff;
struct Attributes
{
    float4 position : POSITION;
    float2 texcoord : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    #if defined(_ALPHATEST_ON)
        float2 uv : TEXCOORD0;
    #endif
    float4 positionCS : SV_POSITION;
    float4 positionNDC : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    #if defined(_ALPHATEST_ON)
        output.uv = input.texcoord;
    #endif
    // output.positionCS = TransformObjectToHClip(input.position.xyz);

    VertexPositionInputs positionInputs = GetVertexPositionInputs(input.position.xyz);
    output.positionCS = positionInputs.positionCS;
    output.positionNDC = positionInputs.positionNDC; 
       return output;
}

half DepthOnlyFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    #if defined(_ALPHATEST_ON)
        float4 texcol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
        clip(texcol.a - _Cutoff);
    #endif

    #if defined(LOD_FADE_CROSSFADE)
        LODFadeCrossFade(input.positionCS);
    #endif

    

    
    return input.positionCS.z ;
}
#endif
