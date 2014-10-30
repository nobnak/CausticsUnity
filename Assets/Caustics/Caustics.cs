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
	private RenderTexture _causticsTex0;
	private RenderTexture _causticsTex1;

	void OnDisable() { Release(); }
	void Update () {
		CheckInit();

		genMat.SetVector(SHADER_CAUSTICS_TEXEL_SIZE, _texelSize);

		genMat.SetInt(SHADER_NOFFSET, -3);
		_causticsTex0.DiscardContents();
		Graphics.Blit(null, _causticsTex0, genMat);

		genMat.SetInt(SHADER_NOFFSET, 1);
		_causticsTex1.DiscardContents();
		Graphics.Blit(null, _causticsTex1, genMat);

		var m = renderer.sharedMaterial;
		m.SetTexture(SHADER_CAUSTICS_TEX0, _causticsTex0);
		m.SetTexture(SHADER_CAUSTICS_TEX1, _causticsTex1);
	}
	
	void CheckInit() {
		if (_causticsTex0 != null && _causticsTex0.width == n)
			return;

		Release();
		
		_texelSize = new Vector4(1f / n, 1f / n, n, n);

		_causticsTex0 = new RenderTexture(n, n, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
		_causticsTex1 = new RenderTexture(n, n, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
		_causticsTex0.Create();
		_causticsTex1.Create();
	}
	void Release() {
		if (_causticsTex0 != null)
			_causticsTex0.Release();
		if (_causticsTex1 != null)
			_causticsTex1.Release();
	}
}
