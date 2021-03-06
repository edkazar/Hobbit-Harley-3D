using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TestControllerManager : MonoBehaviour
{
    [SerializeField] private Camera myCamera;

    private int testID;
    private MovementControllerScript myMovementController;
    private List<List<GameObject>> Tests;

    private int outerTestID;
    private int innerTestID;

    private int[] testsOrder = new int[] { 0, 1, 2, 3, 0, 1, 3, 3, 0, 1, 2, 3 }; // 0: right, 1: left, 2: face, 3: forward
    private string[] helpTexts = new string[] { "Before crossing a street, look to your right to make sure cars are not coming!",
                                                "Before crossing a street, look to your left to make sure cars are not coming!",
                                                "If a car is coming, make eye contact with the driver to ask for the right-of-way!",
                                                "You are doing great! Now keep going forward!"};
    private int testOrderCounter;
    private int timeTaken;
    private int testTimeTaken;
    private int targetHelpTime;
    [SerializeField] private int targetTestTime;
    [SerializeField] private int watchDrivertargetTestTime;
    private int offset;

    [SerializeField] private Transform anillo1Pos;
    [SerializeField] private Transform anillo2Pos;
    [SerializeField] private Transform anillo3Pos;
    [SerializeField] private Transform anillo4Pos;

    [SerializeField] private GameObject HelpText;
    private Text helpTextField;

    private CarSpeedController mySpeedController;
    private const int stopMovementID = 1;

    // Start is called before the first frame update
    void Start()
    {
        loadTests();
        outerTestID = 0;
        innerTestID = 0;

        testOrderCounter = 0;
        timeTaken = 0;
        testTimeTaken = 0;
        targetHelpTime = targetTestTime * 2;
        offset = 20;

        GameObject MovementController = GameObject.Find("MovementController");
        myMovementController = MovementController.GetComponent<MovementControllerScript>();

        GameObject speedController = GameObject.Find("CarMovementController");
        mySpeedController = speedController.GetComponent<CarSpeedController>();

        Transform hText = HelpText.transform.Find("FinalText");
        helpTextField = hText.GetComponent<Text>();
        HelpText.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        if (myMovementController.startTest)
        {
            runTest();
        }
    }

    void loadTests()
    {
        Tests = new List<List<GameObject>>();

        for (int i = 0; i < this.transform.childCount; i++)
        {
            List<GameObject> temp = new List<GameObject>();
            Transform child = this.transform.GetChild(i);

            for (int j = 0; j < child.childCount; j++)
            {
                temp.Add(child.GetChild(j).gameObject);
            }
            Tests.Add(temp);
        }

        for (int i = 0; i < Tests.Count; i++)
        {
            for (int j = 0; j < Tests[i].Count; j++)
            {
                Tests[i][j].SetActive(false);
            }
        }

    }

    void runTest()
    {
        testTimeTaken++;

        if(testTimeTaken >= targetHelpTime)
        {
            setText();
            HelpText.SetActive(true);
        }

        if (outerTestID < myMovementController.getWaypointsLength() - 1) // minus initial waypoint
        {
            Tests[outerTestID][innerTestID].SetActive(true);
            float mousePosX = Input.mousePosition.x;
            Vector3 screenPos = myCamera.WorldToScreenPoint(Tests[outerTestID][innerTestID].transform.position);

            if (testsOrder[testOrderCounter] == 0)
            {
                if (screenPos.x < mousePosX)
                {
                    timeTaken++;
                }
            }
            else if (testsOrder[testOrderCounter] == 1)
            {

                if (screenPos.x > mousePosX)
                {
                    timeTaken++;
                }
                else
                {
                    timeTaken = 0;
                }
            }
            else if (testsOrder[testOrderCounter] == 2)
            {
                float mousePosY = Input.mousePosition.y;
                Vector3 anillo1 = myCamera.WorldToScreenPoint(anillo1Pos.position);
                Vector3 anillo2 = myCamera.WorldToScreenPoint(anillo2Pos.position);
                Vector3 anillo3 = myCamera.WorldToScreenPoint(anillo3Pos.position);
                Vector3 anillo4 = myCamera.WorldToScreenPoint(anillo4Pos.position);


                if ((mousePosX < anillo1.x + offset*2 && mousePosX > anillo1.x - offset*2 && mousePosY < anillo1.y + offset*2 && mousePosY > anillo1.y - offset*2) ||
                    (mousePosX < anillo2.x + offset*2 && mousePosX > anillo2.x - offset*2 && mousePosY < anillo2.y + offset*2 && mousePosY > anillo2.y - offset*2) ||
                    (mousePosX < anillo3.x + offset*2 && mousePosX > anillo3.x - offset*2 && mousePosY < anillo3.y + offset*2 && mousePosY > anillo3.y - offset*2) ||
                    (mousePosX < anillo4.x + offset*2 && mousePosX > anillo4.x - offset*2 && mousePosY < anillo4.y + offset*2 && mousePosY > anillo4.y - offset*2))
                {
                    timeTaken++;

                    if (timeTaken >= watchDrivertargetTestTime)
                    {
                        mySpeedController.changeMovementspeed(stopMovementID);
                        timeTaken = targetTestTime;
                    }
                }
                else
                {
                    timeTaken = 0;
                }
                /*
                 * Poner true la bandera que dice que ya cruzo
                 */
            }
            else //testsOrder[testOrderCounter] == 3
            {
                if (mousePosX < screenPos.x + offset && mousePosX > screenPos.x - offset)
                {
                    timeTaken++;
                    if (timeTaken >= watchDrivertargetTestTime / 2)
                    {
                        timeTaken = targetTestTime;
                    }
                }
                else
                {
                    timeTaken = 0;
                }
            }

            if (timeTaken >= targetTestTime)
            {
                Tests[outerTestID][innerTestID].SetActive(false);
                timeTaken = 0;
                testTimeTaken = 0;
                innerTestID++;
                testOrderCounter++;
                HelpText.SetActive(false);

                if (innerTestID >= Tests[outerTestID].Count)
                {
                    innerTestID = 0;
                    outerTestID++;
                    myMovementController.setStartTestFalse();
                    StartCoroutine(resumeCarMovement());
                }
            }
        }
    }


    IEnumerator resumeCarMovement()
    {
        if (!myMovementController.hasCrossed)
        {
            mySpeedController.justCrossed = true;
            yield return new WaitForSeconds(5);
            mySpeedController.resetSpeed(false);
            yield return new WaitForSeconds(2);
            myMovementController.hasCrossed = true;
            
        }
    }

    void setText()
    {
        helpTextField.text = helpTexts[testsOrder[testOrderCounter]];
    }
}
