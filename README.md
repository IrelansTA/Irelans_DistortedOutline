# Irelans_DistortedOutline
DistortedOutline DemoSample

1.配置Renderfeature到你的URP renderer，需要添加一个描边用的材质，shader选择项目中的Irelans/SS_Outline_Distort
2.在场景中添加Volume_SS_OutlineVolume，这里可以控制你的描边大小，以及颜色强度，关闭volume描边也将消失
3.在想要渲染描边的物体的Renderlayermask为-Outline，或者你的URPsetting中第2位的layer，也可以基于你的需求修改Renderfeature
4.调节第一步中创建的材质，达到你想要的描边扰动效果
