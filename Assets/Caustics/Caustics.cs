using UnityEngine;
using System.Collections;

public class Caustics : MonoBehaviour {
	public const string SHADER_NOFFSET = "_NOffset";
	public const string SHADER_CAUSTICS_TEXEL_SIZE = "_Caustics_TS";
	public const string SHADER_CAUSTICS_TEX0 = "_CausticTex0";
	public const string SHADER_CAUSTICS_TEX1 = "_CausticTex1";

	public int n = 512;
	public Material genMat;

	private Vector4 _texelSize;
	private RenderTexture _causticYTex0;
	private RenderTexture _causticYTex1;
	private RenderTexture _causticTex;

	void OnDisable() { Release(); }
	void Update () {
		CheckInit();

		genMat.SetVector(SHADER_CAUSTICS_TEXEL_SIZE, _texelSize);

		genMat.SetInt(SHADER_NOFFSET, -3);
		_causticYTex0.DiscardContents();
		Graphics.Blit(null, _causticYTex0, genMat, 0);

		genMat.SetInt(SHADER_NOFFSET, 1);
		_causticYTex1.DiscardContents();
		Graphics.Blit(null, _causticYTex1, genMat, 0);

		genMat.SetTexture(SHADER_CAUSTICS_TEX0, _causticYTex0);
		genMat.SetTexture(SHADER_CAUSTICS_TEX1, _causticYTex1);
		_causticTex.DiscardContents();
		Graphics.Blit(null, _causticTex, genMat, 1);

		var m = renderer.sharedMaterial;

	}
	
	void CheckInit() {
		if (_causticYTex0 != null && _causticYTex0.width == n)
			return;

		Release();
		
		_texelSize = new Vector4(1f / n, 1f / n, n, n);

		_causticYTex0 = new RenderTexture(n, n, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
		_causticYTex1 = new RenderTexture(n, n, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
		_causticTex = new RenderTexture(n, n, 0, RenderTextureFormat.RFloat, RenderTextureReadWrite.Linear);
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
}
