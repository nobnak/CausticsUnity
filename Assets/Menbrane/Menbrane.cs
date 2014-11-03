using UnityEngine;
using System.Collections;

namespace nobnak.Menbrane {

	public class Menbrane : MonoBehaviour {
		public const string SHADER_BUMP_TEX = "_BumpMap";
		public const string SHADER_DT = "_Dt";
		public const string SHADER_DX = "_Dx";
		public const string SHADER_T = "_T";

		public Material sim;
		public Material brushMat;
		public int nGrids = 256;
		public float l = 4;
		public int fps = 30;
		public float tension = 3;
		public float density = 10;

		private RenderTexture _hvTex0, _hvTex1;
		private RenderTexture _nTex;
		private Ticker _ticker;

		void OnDestroy() {
			Release();
		}
		void Start() {
			_ticker = new Ticker(fps);
		}
		void Update() {
			CheckInit();

			var dt = 1f / fps;
			var nSteps = _ticker.Count();
			var dx = l / nGrids;
			var mass = density * dx * dx;

			sim.SetFloat(SHADER_DX, dx);
			sim.SetFloat(SHADER_DT, dt);
			sim.SetFloat(SHADER_T, tension / mass);

			if (Input.GetMouseButton(0)) {
				var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
				RaycastHit hit;
				if (collider.Raycast(ray, out hit, float.MaxValue)) {
					var pxPos = nGrids * hit.textureCoord;
					var projMat = Matrix4x4.Ortho(0f, nGrids, 0f, nGrids, -1f, 1f);
					var brushTex = brushMat.mainTexture;
					var brushSize = 0.128f * nGrids;
					var paintRect = new Rect(pxPos.x - 0.5f * brushSize, pxPos.y - 0.5f * brushSize, 
					                         brushSize, brushSize);

					GL.PushMatrix();
					GL.LoadIdentity();
					GL.LoadProjectionMatrix(projMat);
					RenderTexture.active = _hvTex0;
					Graphics.DrawTexture(paintRect, brushTex, brushMat);
					RenderTexture.active = null;
					GL.PopMatrix();
				}
			}

			for (var i = 0; i < nSteps; i++) {
				Graphics.Blit(_hvTex0, _hvTex1, sim, 0);
				Swap();
				Graphics.Blit(_hvTex0, _nTex, sim, 1);
			}

			var mat = renderer.sharedMaterial;
			mat.SetTexture(SHADER_BUMP_TEX, _nTex);
		}
		
		void Release() {
			if (_hvTex0 != null)
				_hvTex0.Release();
			if (_hvTex1 != null)
				_hvTex1.Release();
			if (_nTex != null)
				_nTex.Release();
		}
		void Swap() {
			var tmpRtex = _hvTex0; _hvTex0 = _hvTex1; _hvTex1 = tmpRtex;
		}
		void CheckInit() {
			if (_hvTex0 != null && _hvTex0.width == nGrids)
				return;
			
			Release();
			_hvTex0 = new RenderTexture(nGrids, nGrids, 0, RenderTextureFormat.RGFloat, RenderTextureReadWrite.Linear);
			_hvTex1 = new RenderTexture(nGrids, nGrids, 0, RenderTextureFormat.RGFloat, RenderTextureReadWrite.Linear);
			_nTex = new RenderTexture(nGrids, nGrids, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
			_hvTex0.wrapMode = _hvTex1.wrapMode = _nTex.wrapMode =  TextureWrapMode.Repeat;
			_hvTex0.Create();
			_hvTex1.Create();
			_nTex.Create();
			
			RenderTexture.active = _hvTex0;
			GL.Clear(true, true, Color.black);
			RenderTexture.active = _hvTex1;
			GL.Clear(true, true, Color.black);
			RenderTexture.active = null;
		}
	}
}