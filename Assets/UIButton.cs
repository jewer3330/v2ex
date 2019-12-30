using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class UIButton : MonoBehaviour,IPointerClickHandler
{
    public UVClipPostEffect effect;

    void IPointerClickHandler.OnPointerClick(PointerEventData eventData)
    {
        Debug.Log("onclick");
        effect.Reset();
    }

    // Start is called before the first frame update
    void Start()
    {
        effect.Close();    
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    
}
