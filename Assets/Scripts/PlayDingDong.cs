using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayDingDong : MonoBehaviour
{
    AudioSource audioData;

    // Start is called before the first frame update
    void OnEnable()
    {
        audioData = GetComponent<AudioSource>();
        audioData.PlayDelayed(0);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
