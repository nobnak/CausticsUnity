using UnityEngine;
using System.Collections;

public static class RTUtil {

	public static Vector3 Refract(Vector3 l, Vector3 n, float r) {
		var c = -Vector3.Dot(l, n);
		return r * l + (r * c - Mathf.Sqrt(1f - r * r * (1f - c * c))) * n;
	}
}
