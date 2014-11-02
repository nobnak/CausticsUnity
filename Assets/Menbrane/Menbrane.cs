using UnityEngine;
using System.Collections;

namespace nobnak.Menbrane {

	public class Menbrane : MonoBehaviour {
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

		private RenderTexture _vhTex0, _vhTex1;
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
					RenderTexture.active = _vhTex0;
					Graphics.DrawTexture(paintRect, brushTex, brushMat);
					RenderTexture.active = null;
					GL.PopMatrix();
				}
			}

			for (var i = 0; i < nSteps; i++) {
				Graphics.Blit(_vhTex0, _vhTex1, sim);
				Swap();
			}

			var mat = renderer.sharedMaterial;
			mat.mainTexture = _vhTex0;
			mat.SetFloat(SHADER_DX, dx);
		}
		
		void Release() {
			if (_vhTex0 != null)
				_vhTex0.Release();
			if (_vhTex1 != null)
				_vhTex1.Release();
		}
		void Swap() {
			var tmpRtex = _vhTex0; _vhTex0 = _vhTex1; _vhTex1 = tmpRtex;
		}
		void CheckInit() {
			if (_vhTex0 != null && _vhTex0.width == nGrids)
				return;
			
			Release();
			_vhTex0 = new RenderTexture(nGrids, nGrids, 0, RenderTextureFormat.RGFloat, RenderTextureReadWrite.Linear);
			_vhTex1 = new RenderTexture(nGrids, nGrids, 0, RenderTextureFormat.RGFloat, RenderTextureReadWrite.Linear);
			_vhTex0.wrapMode = _vhTex1.wrapMode = TextureWrapMode.Repeat;
			_vhTex0.Create();
			_vhTex1.Create();
			
			RenderTexture.active = _vhTex0;
			GL.Clear(true, true, Color.black);
			RenderTexture.active = _vhTex1;
			GL.Clear(true, true, Color.black);
			RenderTexture.active = null;
		}
	}
}