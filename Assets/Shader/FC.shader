﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/FC"
{
    Properties
    {
		_Color("Color Tint",Color)=(1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
	    _BumpMap("Normal Map",2D) = "bump" {}
		_BumpScale("Bump Scale",Float) = 1.0
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
		_Atten("_Atten",Range(0,1)) = 0.5
	}
		SubShader
		{
			Pass{
				Tags{"LightMode" = "ForwardBase"}

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include"Lighting.cginc"
				#include "UnityCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			};


			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
			fixed3 tangentLightDir = normalize(i.lightDir);
			fixed3 tangentViewDir = normalize(i.viewDir);
			fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
			fixed3 tangentNormal = UnpackNormal(packedNormal);
			tangentNormal.xy *= _BumpScale;
			tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
			fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
			fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
			return fixed4((ambient + diffuse + specular) , 1.0);
			};
			ENDCG
	}
			Pass{
				Tags{"LightMode" = "ForwardAdd"}

				Blend one one

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include"Lighting.cginc"
				#include "UnityCG.cginc"
				#include"AutoLight.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;
			float _Atten;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			};


			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
			fixed3 tangentLightDir = normalize(i.lightDir);
			fixed3 tangentViewDir = normalize(i.viewDir);
			fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
			fixed3 tangentNormal = UnpackNormal(packedNormal);
			tangentNormal.xy *= _BumpScale;
			tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
			fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
			fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

			#if defined(POINT) 
			float3 lightCoord = mul(unity_WorldToLight, float4(a.worldPos, 1)).xyz;
			fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
			#else
			fixed atten = 1.0;
			#endif
				return fixed4((ambient + diffuse ) * atten*_Atten, 1.0);
			};
			ENDCG
	}
		}
		Fallback "Specular"
}
