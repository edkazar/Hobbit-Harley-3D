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

    public bool doIt;

    // Start is called before the first frame update
    void Start()
    {
        initialPos = carTransform.position;
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 toTarget = (transform.position - camera.transform.position).normalized;
        float dotProd = Vector3.Dot(toTarget, camera.transform.forward);

        if (dotProd > 0.95f)
        {
            float distanceZ = Mathf.Abs(initialPos.z - carTransform.position.z);
            if (distanceZ <= rotationResetDistance)
            {
                transform.forward = new Vector3(-camera.forward.x, -transform.forward.y, -camera.forward.z);
            }
        }   
    }
}
