using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BodyConstraint : MonoBehaviour
{
    [SerializeField] private Transform rootObject, followObject;
    private float followY;
    public float fixedRotation = 0;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        followY = followObject.eulerAngles.y;
        rootObject.eulerAngles = new Vector3(fixedRotation, followY, fixedRotation);
    }
}
