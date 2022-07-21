using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BallBehavior : MonoBehaviour
{
    //Animator animator;
    Renderer visibility;
    public GameObject riggedBall;
    public SkinnedMeshRenderer rigBall;
    public bool seeRigBall;

    //public bool stopRenderBall = false;

    private MovementControllerScript myMovementController;
    private TestControllerManager myTestController;

    // Start is called before the first frame update
    void Start()
    {

        GetComponent<MeshRenderer>().enabled = false;

        //animator = GetComponent<Animator>();

        rigBall = riggedBall.GetComponent<SkinnedMeshRenderer>();

        GameObject MovementController = GameObject.Find("MovementController");
        myMovementController = MovementController.GetComponent<MovementControllerScript>();

        GameObject TestController = GameObject.Find("TestController");
        myTestController = TestController.GetComponent<TestControllerManager>();
    }

    // Update is called once per frame
    void Update()
    {

        if(!rigBall.enabled)
        {
            GetComponent<MeshRenderer>().enabled = true;
            seeRigBall = false;
            //GetComponent<Animator>().enabled = true; 
        }
        if(rigBall.enabled) // myTestController.stopRenderBall
        {
            GetComponent<MeshRenderer>().enabled = false;
            seeRigBall = true; 
            //GetComponent<Animator>().enabled = false;
        }
    }
}
