using UnityEngine;
using System.Collections;

public class Ticker {
	public readonly float Fps;
	public readonly float Dt;

	private float _tPrev = 0;

	public Ticker(float fps) {
		Dt = 1f / fps;
		_tPrev = Time.timeSinceLevelLoad;
	}

	public int Count() {
		var nSteps = Mathf.FloorToInt((Time.timeSinceLevelLoad - _tPrev) / Dt);
		_tPrev += nSteps * Dt;
		return nSteps;
	}
}
