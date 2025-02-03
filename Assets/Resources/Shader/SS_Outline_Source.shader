Shader "Irelans/SS_Outline_Source"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
        [Toggle(_ALPHATEST_ON)] _AlphatestON ("AlphatestON", Int) = 0

    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        //屏幕空间描边
        Pass
        {
            Name "ScreenOutlineSource"
            Tags { "LightMode" = "ScreenOutline" }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ZTest Always
            ColorMask R
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
       
            
            // Includes
            // #include "Assets/Script/Rendering/UniversalRenderPipeline/Shaders/LitInput.hlsl"
            #include "Assets/Resources/Shader/Library/DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
}
