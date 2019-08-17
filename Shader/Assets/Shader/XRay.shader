Shader "Custom/XRay"
{
    Properties
    {
        _RimColor ("RimColor", Color) = (1,0,0,1)  // 轮廓颜色
		_RimIntensity("Intensity", Range(0,2)) = 1
    }
    SubShader
    {
		Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
        
		// 渲染X光轮廓的Pass
		Pass{
			Tags {"LightMode" = "ForwardBase"}

			// 关闭深度写入（使透明物体后面的物体也能显示）
			ZWrite Off

		    // 打开混合模式（完全透明）
			Blend SrcAlpha One

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"

			fixed4 _RimColor;
			float _RimIntensity;

			// 顶点着色器输入
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			// 顶点着色器输出
			struct v2f {
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD0;
			};

			v2f vert(a2v v) {
				v2f o;

				// 模型空间到裁剪空间的坐标变化
				o.pos = UnityObjectToClipPos(v.vertex);

				o.viewDir = ObjSpaceViewDir(v.vertex);  // 计算出视角向量
				o.normal = v.normal;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				float3 normal = normalize(i.normal);
				float3 viewDir = normalize(i.viewDir);

				float rim = 1 - saturate(dot(i.normal, viewDir));

				fixed4 color = _RimColor * rim * _RimIntensity;        // 计算边缘轮廓
				return color;
			}

			ENDCG
		}
		
    }
	FallBack "Transparent/VertexLit"
}
