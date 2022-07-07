using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class TimelineController : MonoBehaviour
{
    public GameObject Timeline;
    public TestControllerManager testControllerScript;
    public GameObject wave; 
    

    void Start()
    {
        GameObject manager = GameObject.Find("TestController");
        testControllerScript = manager.GetComponent<TestControllerManager>();
        Debug.Log(testControllerScript.waving);
    }

    void Update()
    {
        if (testControllerScript.waving)
        {
            PlayableDirector pd2 = wave.GetComponent<PlayableDirector>();
            Debug.Log("I need to wave in here!");
            pd2.Play();
            testControllerScript.waving = false;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        PlayableDirector pd = Timeline.GetComponent<PlayableDirector>();
        if(pd != null)
        {
            pd.Play();
        }

       
    }
}
