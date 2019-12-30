using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class UVClipPostEffect : MonoBehaviour
{

    public Material clip;
    public float value;
    public bool isEnable;
    [SerializeField]
    private Camera c;
    private void Awake()
    {
        Close();
    }

    public void Reset()
    {
        value = 0f;
        isEnable = true;
        c.enabled = true;
    }

    public void Close()
    {
        c.enabled = false;
        isEnable = false;
    }


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (isEnable)
        {
            value += 0.01f;
            if (clip)
            {
                clip.SetFloat("_Value", value);
                Graphics.Blit(source, destination, clip, 0);
            }
        }

    }
}
