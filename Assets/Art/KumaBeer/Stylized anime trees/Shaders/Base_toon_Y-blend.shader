// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "KumaBeer/Base_toon_Y-blend"
{
	Properties
	{
		_MainColor("Main Color", Color) = (1,1,1,1)
		[HDR]_Shadowcolor("Shadow color", Color) = (0.3921569,0.454902,0.5568628,1)
		_Main_tiling("Main_tiling", Float) = 1
		_Diffuse("Diffuse", 2D) = "white" {}
		[Normal]_MainNormalmap("Main Normalmap", 2D) = "bump" {}
		_Normalmapscale("Normalmap scale", Float) = 1
		[HDR]_RimColor("Rim Color", Color) = (1,1,1,0)
		_RimStr("Rim Str", Range( 0.01 , 3)) = 0.4
		_Rimoffset("Rim offset", Range( -1 , 1)) = 0
		_IndirectDiffuseContribution("Indirect Diffuse Contribution", Range( 0 , 1)) = 1
		_BaseCellSharpness("Base Cell Sharpness", Range( 0.01 , 1)) = 0.01
		_BaseCellOffset("Base Cell Offset", Range( -1 , 1)) = 0
		_Gradientpos("Gradient pos", Float) = 5
		_Gradientstr("Gradient str", Float) = 0.4
		_Gradientoffset("Gradient offset", Float) = -0.05
		_Gradientcolor("Gradient color", Color) = (0.4470589,0.4627451,0.0509804,1)
		[Toggle(_MULTIPLYCOLORONOFF_ON)] _MultiplycolorONOFF("Multiply color ON/OFF", Float) = 0
		[Toggle(_USEGRADIENTMASKRIMLIGHT_ON)] _UseGradientmaskrimlight("Use Gradient mask rimlight", Float) = 0
		[Toggle(_USEGRADIENTMASK_ON)] _UseGradientmask("Use Gradient mask", Float) = 0
		_Mask_tiling("Mask_tiling", Float) = 1
		_Gradientmask("Gradient mask", 2D) = "white" {}
		_Gradientmaskmin("Gradient mask min", Range( 0 , 1)) = 0.7
		_Gradientmaskrimmax("Gradient mask rim max", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		ColorMask RGB
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma shader_feature_local _USEGRADIENTMASKRIMLIGHT_ON
		#pragma shader_feature _MULTIPLYCOLORONOFF_ON
		#pragma shader_feature_local _USEGRADIENTMASK_ON
		#define ASE_USING_SAMPLING_MACROS 1
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
		#endif//ASE Sampling Macros

		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		UNITY_DECLARE_TEX2D_NOSAMPLER(_MainNormalmap);
		uniform float _Main_tiling;
		SamplerState sampler_MainNormalmap;
		uniform float _Normalmapscale;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Gradientmask);
		uniform float _Mask_tiling;
		SamplerState sampler_Gradientmask;
		uniform float _Gradientpos;
		uniform float _Gradientstr;
		uniform float _Gradientoffset;
		uniform float _Gradientmaskrimmax;
		uniform float _RimStr;
		uniform float _Rimoffset;
		uniform float4 _RimColor;
		uniform float _IndirectDiffuseContribution;
		uniform float _BaseCellOffset;
		uniform float _BaseCellSharpness;
		uniform float4 _Shadowcolor;
		uniform float4 _MainColor;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Diffuse);
		SamplerState sampler_Diffuse;
		uniform float4 _Gradientcolor;
		uniform float _Gradientmaskmin;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float LightType125 = _WorldSpaceLightPos0.w;
			float3 temp_cast_5 = (1.0).xxx;
			float2 temp_cast_6 = (_Main_tiling).xx;
			float2 uv_TexCoord21 = i.uv_texcoord * temp_cast_6;
			float2 MainUV22 = uv_TexCoord21;
			float3 newWorldNormal28 = normalize( (WorldNormalVector( i , UnpackScaleNormal( SAMPLE_TEXTURE2D( _MainNormalmap, sampler_MainNormalmap, MainUV22 ), _Normalmapscale ) )) );
			float3 WSNormal31 = newWorldNormal28;
			UnityGI gi72 = gi;
			float3 diffNorm72 = WSNormal31;
			gi72 = UnityGI_Base( data, 1, diffNorm72 );
			float3 indirectDiffuse72 = gi72.indirect.diffuse + diffNorm72 * 0.0001;
			float3 lerpResult90 = lerp( temp_cast_5 , indirectDiffuse72 , _IndirectDiffuseContribution);
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult34 = dot( WSNormal31 , ase_worldlightDir );
			float NdotL36 = dotResult34;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 Lightcolor93 = ase_lightColor;
			float4 temp_output_136_0 = ( float4( ( lerpResult90 + ase_lightAtten ) , 0.0 ) * saturate( ( ( NdotL36 + _BaseCellOffset ) / _BaseCellSharpness ) ) * Lightcolor93 );
			float4 lerpResult140 = lerp( _Shadowcolor , float4( 1,1,1,0 ) , temp_output_136_0);
			float4 ifLocalVar142 = 0;
			if( LightType125 == 1.0 )
				ifLocalVar142 = temp_output_136_0;
			else if( LightType125 < 1.0 )
				ifLocalVar142 = lerpResult140;
			float4 temp_output_115_0 = ( _MainColor * SAMPLE_TEXTURE2D( _Diffuse, sampler_Diffuse, MainUV22 ) );
			float2 temp_cast_9 = (_Mask_tiling).xx;
			float2 uv_TexCoord247 = i.uv_texcoord * temp_cast_9;
			float4 tex2DNode246 = SAMPLE_TEXTURE2D( _Gradientmask, sampler_Gradientmask, uv_TexCoord247 );
			float3 temp_cast_10 = (ase_worldPos.y).xxx;
			float3 worldToObj224 = mul( unity_WorldToObject, float4( temp_cast_10, 1 ) ).xyz;
			float temp_output_184_0 = saturate( (( ( 1.0 - ( _Gradientpos * worldToObj224.y ) ) + newWorldNormal28.y )*_Gradientstr + _Gradientoffset) );
			float clampResult265 = clamp( ( tex2DNode246.r * temp_output_184_0 ) , _Gradientmaskmin , 1.0 );
			#ifdef _USEGRADIENTMASK_ON
				float4 staticSwitch245 = ( _Gradientcolor * ( clampResult265 + _Gradientmaskmin ) );
			#else
				float4 staticSwitch245 = _Gradientcolor;
			#endif
			float4 lerpResult188 = lerp( temp_output_115_0 , staticSwitch245 , temp_output_184_0);
			float4 lerpResult237 = lerp( float4( 1,1,1,0 ) , _Gradientcolor , temp_output_184_0);
			#ifdef _MULTIPLYCOLORONOFF_ON
				float4 staticSwitch235 = ( temp_output_115_0 * ifLocalVar142 * lerpResult237 );
			#else
				float4 staticSwitch235 = ( ifLocalVar142 * lerpResult188 );
			#endif
			c.rgb = staticSwitch235.rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float2 temp_cast_0 = (_Main_tiling).xx;
			float2 uv_TexCoord21 = i.uv_texcoord * temp_cast_0;
			float2 MainUV22 = uv_TexCoord21;
			float3 newWorldNormal28 = normalize( (WorldNormalVector( i , UnpackScaleNormal( SAMPLE_TEXTURE2D( _MainNormalmap, sampler_MainNormalmap, MainUV22 ), _Normalmapscale ) )) );
			float3 WSNormal31 = newWorldNormal28;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult34 = dot( WSNormal31 , ase_worldlightDir );
			float NdotL36 = dotResult34;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult49 = dot( WSNormal31 , ase_worldViewDir );
			float temp_output_76_0 = ( 1.0 - dotResult49 );
			float2 temp_cast_1 = (_Mask_tiling).xx;
			float2 uv_TexCoord247 = i.uv_texcoord * temp_cast_1;
			float4 tex2DNode246 = SAMPLE_TEXTURE2D( _Gradientmask, sampler_Gradientmask, uv_TexCoord247 );
			float3 temp_cast_2 = (ase_worldPos.y).xxx;
			float3 worldToObj224 = mul( unity_WorldToObject, float4( temp_cast_2, 1 ) ).xyz;
			float temp_output_184_0 = saturate( (( ( 1.0 - ( _Gradientpos * worldToObj224.y ) ) + newWorldNormal28.y )*_Gradientstr + _Gradientoffset) );
			float clampResult254 = clamp( temp_output_184_0 , 0.0 , _Gradientmaskrimmax );
			float lerpResult273 = lerp( temp_output_76_0 , ( temp_output_76_0 * tex2DNode246.r ) , clampResult254);
			#ifdef _USEGRADIENTMASKRIMLIGHT_ON
				float staticSwitch251 = lerpResult273;
			#else
				float staticSwitch251 = temp_output_76_0;
			#endif
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 Lightcolor93 = ase_lightColor;
			o.Emission = ( saturate( ( NdotL36 * saturate( (staticSwitch251*_RimStr + _Rimoffset) ) ) ) * float4( (_RimColor).rgb , 0.0 ) * Lightcolor93 ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18921
-1092;-313;1041;668;13407.99;1906.67;7.989968;True;False
Node;AmplifyShaderEditor.RangedFloatNode;17;-11683.87,1888.099;Inherit;False;Property;_Main_tiling;Main_tiling;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-11447.98,1880.405;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-11491.07,1993.866;Inherit;False;Property;_Normalmapscale;Normalmap scale;5;0;Create;True;0;0;0;False;0;False;1;1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-11103.52,1892.886;Inherit;False;MainUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;25;-10848.27,1865.063;Inherit;True;Property;_MainNormalmap;Main Normalmap;4;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;2f6de58b8a4ca9a40b70f6a04a8289b9;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;186;-9763.392,2271.323;Inherit;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;28;-10445.94,1870.955;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;224;-9504.012,2314.757;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;200;-9311.009,2262.203;Inherit;False;Property;_Gradientpos;Gradient pos;12;0;Create;True;0;0;0;False;0;False;5;5.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-10059.75,1864.936;Inherit;False;WSNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;198;-9147.938,2267.444;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;30;-11169.95,956.8093;Inherit;False;852.9001;307.4;NdotL;4;36;34;32;149;NdotL;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;225;-8952.249,2493.371;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-11135.4,1004.999;Inherit;False;31;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;149;-11138.45,1087.622;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;230;-9525.922,2561.469;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;35;-11027.86,3421.185;Inherit;False;2265.065;686.1451;Rimlight;20;95;105;244;175;76;49;41;42;144;106;102;85;240;47;81;264;254;251;272;273;Rimlight;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-8898.188,871.7424;Inherit;False;Property;_Mask_tiling;Mask_tiling;19;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;233;-8953.099,2409.696;Inherit;False;Property;_Gradientoffset;Gradient offset;14;0;Create;True;0;0;0;False;0;False;-0.05;-0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;232;-8951.36,2319.261;Inherit;False;Property;_Gradientstr;Gradient str;13;0;Create;True;0;0;0;False;0;False;0.4;0.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-11008.68,3465.753;Inherit;False;31;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;34;-10828.16,1026.798;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;42;-10961.64,3576.961;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;231;-8761.591,2494.893;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;49;-10762.19,3471.631;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;60;-10891.29,2195.432;Inherit;False;828.4254;361.0605;Comment;5;90;74;72;70;66;Indirect Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;183;-8626.901,2366.183;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;37;-10999.16,2791.446;Inherit;False;2093.608;467.4646;Shadows;12;136;142;140;141;138;135;62;55;52;46;39;44;Shadows;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-10538.55,1024.181;Float;True;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;247;-8700.584,853.4456;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;264;-10984.09,3856.678;Inherit;False;Property;_Gradientmaskrimmax;Gradient mask rim max;22;0;Create;True;0;0;0;False;0;False;0;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;246;-8452.86,824.4114;Inherit;True;Property;_Gradientmask;Gradient mask;20;0;Create;True;0;0;0;False;0;False;-1;None;e2f0612f0eb88434183bdf207c05e36c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;184;-8382.063,2371.949;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;76;-10533.16,3502.02;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-10964.7,2849.535;Inherit;True;36;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-10841.29,2339.813;Inherit;False;31;WSNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-10981.48,3042.583;Float;False;Property;_BaseCellOffset;Base Cell Offset;11;0;Create;True;0;0;0;False;0;False;0;0.15;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;61;-11105.48,1411.489;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;250;-8090.536,855.09;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-10677.08,2990.253;Float;False;Property;_BaseCellSharpness;Base Cell Sharpness;10;0;Create;True;0;0;0;False;0;False;0.01;0.193;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;72;-10551.23,2341.408;Inherit;False;World;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;263;-8041.429,1101.075;Inherit;False;Property;_Gradientmaskmin;Gradient mask min;21;0;Create;True;0;0;0;False;0;False;0.7;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;272;-10443.47,3617.308;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-10687.46,2848.806;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-10582.3,2446.494;Float;False;Property;_IndirectDiffuseContribution;Indirect Diffuse Contribution;9;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-10462.68,2245.432;Float;False;Constant;_Float0;Float 0;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;254;-10669.96,3813.22;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-10875.06,1407.735;Inherit;False;Lightcolor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;90;-10309.81,2289.792;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;273;-10200.3,3597.63;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;137;-10236.55,2692.575;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;265;-7706.917,848.2427;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;55;-10364.4,2850.584;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;5;-9629.887,1097.007;Inherit;False;859.5496;556.2096;Diffuse;4;45;38;115;108;Diffuse ;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;261;-7424.191,1080.662;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;234;-8396.684,1457.436;Inherit;False;Property;_Gradientcolor;Gradient color;15;0;Create;True;0;0;0;False;0;False;0.4470589,0.4627451,0.0509804,1;0.4180405,0.4627448,0.05097956,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;251;-10222.73,3463.602;Inherit;False;Property;_UseGradientmaskrimlight;Use Gradient mask rimlight;17;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;135;-9984.79,3106.869;Inherit;False;93;Lightcolor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-10232.05,3994.994;Float;False;Property;_Rimoffset;Rim offset;8;0;Create;True;0;0;0;False;0;False;0;-0.3;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-10245.27,3831.216;Float;False;Property;_RimStr;Rim Str;7;0;Create;True;0;0;0;False;0;False;0.4;1.1;0.01;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-9572.109,1436.541;Inherit;False;22;MainUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;134;-9999.777,2581.442;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;124;-11218.29,1296.177;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;62;-10118.22,2857.811;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;240;-9891.3,3596.684;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;259;-7866.937,1717.427;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;3.61;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-9712.663,2863.507;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;125;-10806.29,1298.386;Inherit;False;LightType;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;108;-9280.328,1200.288;Float;False;Property;_MainColor;Main Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;138;-9712.931,3077.683;Inherit;False;Property;_Shadowcolor;Shadow color;1;1;[HDR];Create;True;0;0;0;False;0;False;0.3921569,0.454902,0.5568628,1;0.4470588,0.5168172,0.7843137,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;45;-9380.112,1404.541;Inherit;True;Property;_Diffuse;Diffuse;3;0;Create;True;0;0;0;False;0;False;-1;None;c81cc38cc81747146a9060748f221c91;True;0;False;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;245;-7573.344,1688.796;Inherit;False;Property;_UseGradientmask;Use Gradient mask;18;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;141;-9363.786,2842.653;Inherit;False;125;LightType;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;244;-9633.312,3556.04;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;140;-9367.328,3021.336;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-9012.732,1359.517;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;-9675.138,3467.648;Inherit;False;36;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;237;-7233.286,1436.436;Inherit;True;3;0;COLOR;1,1,1,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;188;-7157.889,1668.285;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ConditionalIfNode;142;-9160.426,2847.228;Inherit;True;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;85;-9599.174,3767.656;Float;False;Property;_RimColor;Rim Color;6;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.9056604,0.9056604,0.9056604,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-9455.627,3533.091;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-6830.871,1645.584;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;95;-9222.923,3533.031;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-9317.423,3866.745;Inherit;False;93;Lightcolor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;102;-9333.523,3766.375;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;236;-6826.939,1366.253;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;235;-6492.983,1521.245;Inherit;False;Property;_MultiplycolorONOFF;Multiply color ON/OFF;16;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;-8981.038,3530.714;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-6143.604,1397.371;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;KumaBeer/Base_toon_Y-blend;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;5;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;False;0;False;17;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;True;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;21;0;17;0
WireConnection;22;0;21;0
WireConnection;25;1;22;0
WireConnection;25;5;23;0
WireConnection;28;0;25;0
WireConnection;224;0;186;2
WireConnection;31;0;28;0
WireConnection;198;0;200;0
WireConnection;198;1;224;2
WireConnection;225;0;198;0
WireConnection;230;0;28;2
WireConnection;34;0;32;0
WireConnection;34;1;149;0
WireConnection;231;0;225;0
WireConnection;231;1;230;0
WireConnection;49;0;41;0
WireConnection;49;1;42;0
WireConnection;183;0;231;0
WireConnection;183;1;232;0
WireConnection;183;2;233;0
WireConnection;36;0;34;0
WireConnection;247;0;248;0
WireConnection;246;1;247;0
WireConnection;184;0;183;0
WireConnection;76;0;49;0
WireConnection;250;0;246;1
WireConnection;250;1;184;0
WireConnection;72;0;66;0
WireConnection;272;0;76;0
WireConnection;272;1;246;1
WireConnection;52;0;44;0
WireConnection;52;1;39;0
WireConnection;254;0;184;0
WireConnection;254;2;264;0
WireConnection;93;0;61;0
WireConnection;90;0;74;0
WireConnection;90;1;72;0
WireConnection;90;2;70;0
WireConnection;273;0;76;0
WireConnection;273;1;272;0
WireConnection;273;2;254;0
WireConnection;265;0;250;0
WireConnection;265;1;263;0
WireConnection;55;0;52;0
WireConnection;55;1;46;0
WireConnection;261;0;265;0
WireConnection;261;1;263;0
WireConnection;251;1;76;0
WireConnection;251;0;273;0
WireConnection;134;0;90;0
WireConnection;134;1;137;0
WireConnection;62;0;55;0
WireConnection;240;0;251;0
WireConnection;240;1;81;0
WireConnection;240;2;47;0
WireConnection;259;0;234;0
WireConnection;259;1;261;0
WireConnection;136;0;134;0
WireConnection;136;1;62;0
WireConnection;136;2;135;0
WireConnection;125;0;124;2
WireConnection;45;1;38;0
WireConnection;245;1;234;0
WireConnection;245;0;259;0
WireConnection;244;0;240;0
WireConnection;140;0;138;0
WireConnection;140;2;136;0
WireConnection;115;0;108;0
WireConnection;115;1;45;0
WireConnection;237;1;234;0
WireConnection;237;2;184;0
WireConnection;188;0;115;0
WireConnection;188;1;245;0
WireConnection;188;2;184;0
WireConnection;142;0;141;0
WireConnection;142;3;136;0
WireConnection;142;4;140;0
WireConnection;105;0;175;0
WireConnection;105;1;244;0
WireConnection;120;0;142;0
WireConnection;120;1;188;0
WireConnection;95;0;105;0
WireConnection;102;0;85;0
WireConnection;236;0;115;0
WireConnection;236;1;142;0
WireConnection;236;2;237;0
WireConnection;235;1;120;0
WireConnection;235;0;236;0
WireConnection;144;0;95;0
WireConnection;144;1;102;0
WireConnection;144;2;106;0
WireConnection;0;2;144;0
WireConnection;0;13;235;0
ASEEND*/
//CHKSM=FE402640E95E0346F14FBF597A2ABE16384318F7