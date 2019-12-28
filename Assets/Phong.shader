Shader "Unlit/BlinnOrPhong"
{
	Properties
	{
        _MainTex ("MainTex", 2D) = "white"{}
		_Power ("Power", Range(1,256)) = 2
        [Toggle]_EnableBlinn("EnableBlinn",float) = 0
        _SpecularColor("Specular",Color)= (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
                float4 m_pos : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float4 m_pos : TEXCOORD1;
                
			};

			sampler _MainTex;
			float4  _MainTex_ST;
            float _Power;
            bool _EnableBlinn;
            float4 _SpecularColor;
			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;
                o.m_pos = v.vertex;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                // sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
                
                
                //float3 worldPos = mul(unity_ObjectToWorld,i.m_pos).xyz;

                //float3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                float3 worldSpaceNormal = normalize(UnityObjectToWorldNormal(i.normal));
                

                // 漫反射 dot( normal , light) worldsapce
                float3 worldSpaceLightDir =  WorldSpaceLightDir(i.m_pos);
                fixed3 diffuse = max(0,dot(worldSpaceNormal,worldSpaceLightDir)) * col.rgb;
                float3 worldSpaceViewDir = normalize(WorldSpaceViewDir(i.m_pos));
                
                fixed3 specular = 0;
                //Phong 高光反射 eyedirection  light_reflect_dirction 的夹角 worldspace
                if(!_EnableBlinn)
                {
                    float3 worldSpaceLightReflectDir = reflect(-worldSpaceLightDir,worldSpaceNormal);
                    specular = pow(max(0,dot(worldSpaceViewDir,worldSpaceLightReflectDir)),_Power) * _SpecularColor;
                }
                //Blinn Phong 是 dot(eyedirction + lightdir,normal) worldspace 
                else
                {
                    float3 h = normalize( worldSpaceViewDir + worldSpaceLightDir);
                    specular = pow(max(0,dot(worldSpaceNormal,h)),_Power) * _SpecularColor;
                }

               
                //固有色
				
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				return fixed4(specular + diffuse + ambient ,1);
			}
			ENDCG
		}
	}
}
