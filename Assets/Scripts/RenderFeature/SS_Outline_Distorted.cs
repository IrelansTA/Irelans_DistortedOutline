using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.Collections.Generic;
using UnityEngine.Experimental.Rendering;

public class SS_Outline_Distorted : ScriptableRendererFeature
{
    OutlineDistortPass outlineDistortPass;
    public Material OutlineDistortMat;

    public GraphicsFormat gfxFormat;


    public RenderPassEvent Event = RenderPassEvent.BeforeRenderingPostProcessing;


    // public LayerMask layerMask;
    public class OutlineDistortPass : ScriptableRenderPass
    {

        SS_OutlineVolume outline_volume;
        public SS_Outline_Distorted feature;
        private RTHandle cameraColor;
        private readonly RenderTargetHandle OutlineSourceRT = RenderTargetHandle.CameraTarget;

        private List<ShaderTagId> shaderTagIdList = new List<ShaderTagId> {
        new ShaderTagId("UniversalForward"),
    };
 
        public Material OutlineDistortMat;


        public OutlineDistortPass(SS_Outline_Distorted feature)
        {
            this.feature = feature;
            // 在构造函数中创建描边时使用的材质
            this.OutlineDistortMat = feature.OutlineDistortMat;
            OutlineSourceRT.Init("OutlineSourceRT");

        }

        public void SetTarget(RTHandle cameraColor)
        {
            this.cameraColor = cameraColor;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {




            // if (outline_volume != null)
            // {
            RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;

            descriptor.colorFormat = RenderTextureFormat.ARGB32;
            // 分配颜色 RenderTexture
            descriptor.depthBufferBits = 0;





            //Get RT
            RenderTextureDescriptor cameraTextureDescriptor_full = renderingData.cameraData.cameraTargetDescriptor;
            cameraTextureDescriptor_full.width = Mathf.RoundToInt(cameraTextureDescriptor_full.width);
            cameraTextureDescriptor_full.height = Mathf.RoundToInt(cameraTextureDescriptor_full.height);
            cameraTextureDescriptor_full.graphicsFormat = feature.gfxFormat;

            // cameraTextureDescriptor_full.graphicsFormat = GraphicsFormat.RGBA_ASTC4X4_UFloat;
            cmd.GetTemporaryRT(OutlineSourceRT.id, cameraTextureDescriptor_full, FilterMode.Bilinear);//创建RT-ID / RT desciptor /Filter Mode
            ConfigureTarget(OutlineSourceRT.Identifier());



            // }
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {


            var stac = VolumeManager.instance.stack;
            if (stac.GetComponent<SS_OutlineVolume>() != null)
            {
                outline_volume = stac.GetComponent<SS_OutlineVolume>();
            }


            float Outlinewidth ;
            Color Outlinecolor ;


            if (outline_volume != null && outline_volume.IsActive())
            {
                Outlinewidth = outline_volume.OutlineWidth.value;
                Outlinecolor = outline_volume.OutlineColor.value;

            }
            else
            {
                Debug.LogWarning("outline_volume is null");

                return;
            }

            Shader.SetGlobalFloat("_OutlineWidth", Outlinewidth);
            Shader.SetGlobalVector("_OutlineColor", Outlinecolor);




            CommandBuffer cmd = CommandBufferPool.Get("DistortOutline");
            cmd.ClearRenderTarget(true, true, Color.clear, 0);

            {


                // 指定 DrawingSettings，这里使用了 URP 默认的 Shader Pass
                uint OutlineLayer = (uint)1 << 2;
                FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.all, -1, OutlineLayer);
                DrawingSettings drawingSettings = CreateDrawingSettings(shaderTagIdList, ref renderingData, renderingData.cameraData.defaultOpaqueSortFlags);
                //覆盖layer里所有物体的材质
                drawingSettings.overrideShader = Shader.Find("Irelans/SS_Outline_Source");

                RendererListParams rendererListParams = new RendererListParams(renderingData.cullResults, drawingSettings, filteringSettings);

                // // 构建 RendererList
                RendererList rendererList = context.CreateRendererList(ref rendererListParams);


                // // 绘制需要描边的物体
                cmd.DrawRendererList(rendererList);

                context.ExecuteCommandBuffer(cmd);

                cmd.Clear();


                // 绘制描边
                cmd.Blit(OutlineSourceRT.Identifier(), cameraColor, OutlineDistortMat);
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
                //     // 执行

            }
            // 回收 CommandBuffer
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {

            cmd.ReleaseTemporaryRT(OutlineSourceRT.id);


        }
    }


    public override void Create()
    {

        // 建立对应的 ScriptableRenderPass
        outlineDistortPass = new OutlineDistortPass(this);
        // 将 ScriptableRenderPass 的渲染时机指定为所有其他渲染操作完成之后
        outlineDistortPass.renderPassEvent = Event;
        const FormatUsage usage = FormatUsage.Linear | FormatUsage.Render;
        gfxFormat = SystemInfo.IsFormatSupported(GraphicsFormat.R8G8B8A8_SRGB, usage) ? GraphicsFormat.R8G8B8A8_SRGB : GraphicsFormat.R16G16B16A16_SFloat; // HDR fallback

    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {

        renderer.EnqueuePass(outlineDistortPass);
    }
    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData)
    {

        outlineDistortPass.SetTarget(renderer.cameraColorTargetHandle);
    }
}