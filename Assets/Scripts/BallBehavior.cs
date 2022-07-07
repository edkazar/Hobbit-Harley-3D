using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BallBehavior : MonoBehaviour
{
    Animator animator;
    Renderer visibility;
    public GameObject riggedBall;
    SkinnedMeshRenderer rigBall;
    //MeshRenderer bool streetBall;
    
    

    // Start is called before the first frame update
    void Start()
    {

        GetComponent<MeshRenderer>().enabled = false;

        animator = GetComponent<Animator>();

        rigBall = riggedBall.GetComponent<SkinnedMeshRenderer>();
        
    }

    // Update is called once per frame
    void Update()
    {

        if(!rigBall.enabled)
        {
            GetComponent<MeshRenderer>().enabled = true;
            GetComponent<Animator>().enabled = true; 
        }
        if(rigBall.enabled)
        {
            GetComponent<MeshRenderer>().enabled = false;
            GetComponent<Animator>().enabled = false;
        }
        //if (rigBall.enabled)
        //{
           // GetComponent<Renderer>().enabled = !GetComponent<Renderer>().enabled;
            //animator.SetBool("showBall", false);
        //}
        //if(!rigBall.enabled)
        //{
            //animator.SetBool("showBall", true);
        //}

    }
}
