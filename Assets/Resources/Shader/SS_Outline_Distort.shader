Shader "Irelans/SS_Outline_Distort"
{
    Properties
    {
        _MainTex ("RT", 2D) = "white" { }
        _DistortTex ("Distort Texture", 2D) = "white" { }
        _Distort ("Distort",float) = 0
        _DistortSpeed ("Distort Speed", float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        ZWrite Off
         Cull Off
        // ZTest On
        Blend One OneMinusSrcAlpha
        Pass
        {
            Name "SS_Outline_Distort"

            HLSLPROGRAM
            // core.hlsl
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            

            #pragma vertex vert
            #pragma fragment frag

            #define SAMPLE_COUNT 4

            uniform float _OutlineWidth;
            uniform float4 _OutlineColor;
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            TEXTURE2D(_DistortTex); SAMPLER(sampler_DistortTex);
            half4 _DistortTex_ST;
            half _Distort;
            half _DistortSpeed;

            


            struct appdata
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };

            Varyings vert(appdata v)
            {
                Varyings o;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(v.positionOS.xyz);
                o.positionCS = positionInputs.positionCS;
                o.uv = v.uv;
                
                return o;
            }

            half4 frag(Varyings input) : SV_Target
            {
                
                float2 uv_DistortTex = input.uv * _DistortTex_ST.xy + _DistortTex_ST.zw;
                uv_DistortTex += float2(0,_DistortSpeed) * _Time.y;
                half distortTex_UV = SAMPLE_TEXTURE2D(_DistortTex, sampler_DistortTex, uv_DistortTex).r;

                half2 distorted_UV= input.uv + float2(0,distortTex_UV) * _Distort*0.1;
                
                float4 color = tex2D(_MainTex, input.uv);
                
             

                if (color.x > 0.1f)
                {
                    // 预乘 Alpha
                    clip(-1);

                }

                int insideCount = 0;

                // 采样周围的像素
                float2 texelSize = _MainTex_TexelSize.xy;
                for (int i = 0; i < SAMPLE_COUNT; i++)
                {
                    float s;
                    float c;
                    sincos(radians(360.0f / ((float)SAMPLE_COUNT) * ((float)i)), s, c);
                    // 这里采用的是采样一圈 16 个像素的方式
                    float2 uv = distorted_UV + float2(s, c) * texelSize * _OutlineWidth;
                    float4 sampleColor = tex2D(_MainTex, uv);
                    if (sampleColor.x > 0.1f)
                    {
                        // 统计在 Mask 中的像素的数量
                        insideCount += 1;
                    }
                }

                if ((insideCount <= SAMPLE_COUNT) && (insideCount >= 1))
                {
                    // 预乘 Alpha
                    // 深度遮罩
                    
                    
                    

                    return float4(_OutlineColor.rgb * 1, 1);
                }
                //


                return 0;
            }
            ENDHLSL
        }
    }
}