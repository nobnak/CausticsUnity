using UnityEngine;
using System.Collections;

public class Caustics : MonoBehaviour {
	public const string SHADER_CAUSTIC_Y_TEX0 = "_CausticYTex0";
	public const string SHADER_CAUSTIC_Y_TEX1 = "_CausticYTex1";
	public const string SHADER_CAUSTIC_TEX = "_CausticTex";
	public const string SHADER_BUMP_TEX = "_BumpMap";

	public const string SHADER_NOFFSET = "_NOffset";
	public const string SHADER_CAUSTICS_TEXEL_SIZE = "_Caustics_TS";
	public const string SHADER_UV_C_OFFSET = "_UvC_Offset";
	public const string SHADER_REFRACTION_FACTOR = "_Refraction";
	public const string SHADER_HEIGHT = "_Height";
	public const string SHADER_LIGHT_DIR = "_LightDir";
	public const string SHADER_VIEW_DIR = "_ViewDir";
	
	public int n = 512;
	public Material genMat;
	public Data data;

	private Vector4 _texelSize;
	private RenderTexture _causticYTex0;
	private RenderTexture _causticYTex1;
	private RenderTexture _causticTex;

	void OnDisable() { Release(); }
	void Update () {
		CheckInit();

		data.Normalize();
		genMat.SetVector(SHADER_CAUSTICS_TEXEL_SIZE, _texelSize);
		genMat.SetVector(SHADER_UV_C_OFFSET, data.UvCOffset());
		genMat.SetFloat(SHADER_REFRACTION_FACTOR, data.RefractionFactor);
		genMat.SetFloat(SHADER_HEIGHT, data.Height);
		genMat.SetVector(SHADER_LIGHT_DIR, data.LightDir);
		genMat.SetTexture(SHADER_BUMP_TEX, renderer.sharedMaterial.GetTexture(SHADER_BUMP_TEX));

		genMat.SetInt(SHADER_NOFFSET, -3);
		_causticYTex0.DiscardContents();
		Graphics.Blit(null, _causticYTex0, genMat, 0);

		genMat.SetInt(SHADER_NOFFSET, 1);
		_causticYTex1.DiscardContents();
		Graphics.Blit(null, _causticYTex1, genMat, 0);

		genMat.SetTexture(SHADER_CAUSTIC_Y_TEX0, _causticYTex0);
		genMat.SetTexture(SHADER_CAUSTIC_Y_TEX1, _causticYTex1);
		_causticTex.DiscardContents();
		Graphics.Blit(null, _causticTex, genMat, 1);

		var m = renderer.sharedMaterial;
		m.SetFloat(SHADER_REFRACTION_FACTOR, data.RefractionFactor);
		m.SetFloat(SHADER_HEIGHT, data.Height);
		m.SetVector(SHADER_VIEW_DIR, data.ViewDir);
		m.SetTexture(SHADER_CAUSTIC_TEX, _causticTex);
	}
	
	void CheckInit() {
		if (_causticYTex0 != null && _causticYTex0.width == n)
			return;

		Release();
		
		_texelSize = new Vector4(1f / n, 1f / n, n, n);

		_causticYTex0 = new RenderTexture(n, n, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
		_causticYTex1 = new RenderTexture(n, n, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
		_causticTex = new RenderTexture(n, n, 0, RenderTextureFormat.RFloat, RenderTextureReadWrite.Linear);
		_causticTex.wrapMode = TextureWrapMode.Repeat;
		_causticYTex0.Create();
		_causticYTex1.Create();
		_causticTex.Create();
	}
	void Release() {
		if (_causticYTex0 != null)
			_causticYTex0.Release();
		if (_causticYTex1 != null)
			_causticYTex1.Release();
		if (_causticTex != null)
			_causticTex.Release();
	}

	[System.Serializable]
	public struct Data {
		public static readonly Vector3 N = new Vector3(0, 0, -1);

		public float RefractionFactor;
		public float Height;
		public Vector3 LightDir;
		public Vector3 ViewDir;

		public void Normalize() {
			this.LightDir.Normalize();
			this.ViewDir.Normalize();
		}
		public Vector2 UvCOffset() {
			var rr = RTUtil.Refract(LightDir, N, RefractionFactor);
			var invZ = 1f/rr.z;
			return new Vector2(-rr.x * invZ * Height, -rr.y * invZ * Height);
		}
	}
}
