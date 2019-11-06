using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraDepth : MonoBehaviour {

	public Material depth;
	public RenderTexture rt;

	void Awake()
	{
		rt = new RenderTexture (Screen.width, Screen.height, 0) {

			name = "cameradepth",
		};
	}

	void OnDestroy()
	{
		if (rt)
			Destroy (rt);

	}
	// Use this for initialization
	void Start () {
		Camera.main.depthTextureMode =  DepthTextureMode.Depth;
	}
	
	// Update is called once per frame
	void Update () {
		if (rt) {
			rt.DiscardContents ();
			Graphics.Blit (null, rt, depth);
		}
	}
}
