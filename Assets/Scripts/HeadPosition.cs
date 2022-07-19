using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HeadPosition : MonoBehaviour
{
    [SerializeField] private Transform myPos;
    [SerializeField] Transform camera;

    private Vector3 initialPos;

    [SerializeField]
    private Transform carTransform;

    [SerializeField] private int rotationResetDistance;

    // Start is called before the first frame update
    void Start()
    {
        initialPos = carTransform.position;
    }

    // Update is called once per frame
    void Update()
    {
        float distanceZ = Mathf.Abs(initialPos.z - carTransform.position.z);
        if (distanceZ <= rotationResetDistance)
        {
            transform.forward = new Vector3(-camera.forward.x, -transform.forward.y, -camera.forward.z);
        }
    }
}
