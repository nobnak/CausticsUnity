using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class Caustics : MonoBehaviour {
	public const string SHADER_TEXEL_SIZE = "_TexelSize";

	public int n = 512;
	public Material genMat;

	private Vector4 _texelSize;
	private RenderTexture[] _causticsTexs;
	private RenderBuffer[] _colorBuffers;
	private RenderBuffer _depthBuffer;

	void OnDisable() { Release(); }
	void Update () {
		CheckInit();

		genMat.SetVector(SHADER_TEXEL_SIZE, _texelSize);
		Graphics.SetRenderTarget(_colorBuffers, _depthBuffer);
		Graphics.Blit(null, genMat, 0);
		Graphics.SetRenderTarget(null);
	}
	
	void CheckInit() {
		if (_causticsTexs != null && _causticsTexs.Length > 0 && _causticsTexs[0].width == n)
			return;

		Release();
		
		_texelSize = new Vector4(1f / n, 1f / n, n, n);

		var _causticsTex0 = new RenderTexture(n, n, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
		var _causticsTex1 = new RenderTexture(n, n, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
		_causticsTex0.Create();
		_causticsTex1.Create();

		_causticsTexs = new RenderTexture[]{ _causticsTex0, _causticsTex1 };
		_colorBuffers = new RenderBuffer[]{ _causticsTex0.colorBuffer, _causticsTex1.colorBuffer };
		_depthBuffer = _causticsTex0.depthBuffer;
	}
	void Release() {
		if (_causticsTexs != null) {
			foreach (var rt in _causticsTexs)
				rt.Release();
			_causticsTexs = null;
		}
	}
}
