using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class SS_OutlineVolume : VolumeComponent, IPostProcessComponent
{



    public ClampedFloatParameter OutlineWidth = new(0.0f, 0f, 20f);

    // public ClampedFloatParameter RTScale = new(0.5f, 0.01f, 1f);

    public ColorParameter OutlineColor = new(Color.black, true, true, true);

    public bool IsActive() => this.OutlineWidth.value > 0.0;
    public bool IsTileCompatible() => false;
}