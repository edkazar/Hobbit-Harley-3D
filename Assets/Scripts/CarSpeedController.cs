using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CarSpeedController : MonoBehaviour
{
    private const float fastMovementSpeed = 14.0f;
    private const float slowMovementSpeed = 7.0f;
    private const float stopMovementSpeed = 0.0f;

    public float currentMovementSpeed;

    private const int slowMovementID = 0;
    private const int stopMovementID = 1;

    public bool justCrossed = false;
    public int crossCounter = 0;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    public void resetSpeed(bool hasCrossed)
    {
        currentMovementSpeed = fastMovementSpeed;
    }

    public void changeMovementspeed(int ID)
    {
        if (currentMovementSpeed != stopMovementSpeed)
        {
            if (ID == slowMovementID)
            {
                currentMovementSpeed = slowMovementSpeed;
            }
            else if (ID == stopMovementID)
            {
                currentMovementSpeed = stopMovementSpeed;
            }
            else
            {
                currentMovementSpeed = fastMovementSpeed;
            }
        }
    }
}
