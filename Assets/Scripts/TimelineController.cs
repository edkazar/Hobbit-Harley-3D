using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class TimelineController : MonoBehaviour
{
    public GameObject Timeline;

    private void OnTriggerEnter(Collider other)
    {
        PlayableDirector pd = Timeline.GetComponent<PlayableDirector>();
        if(pd != null)
        {
            pd.Play();
        }
    }
}
