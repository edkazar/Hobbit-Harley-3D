using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class TimelineController : MonoBehaviour
{
    public GameObject Timeline;
    public TestControllerManager testControllerScript;

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
            Debug.Log("I need to wave in here!");
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
