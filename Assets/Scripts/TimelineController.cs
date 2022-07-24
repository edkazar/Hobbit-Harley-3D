using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class TimelineController : MonoBehaviour
{
    [SerializeField] Transform playerTransform = null;
    [SerializeField] Transform WayPoint2 = null;
    [SerializeField] Transform ballTransform = null;
    [SerializeField] Transform hobbitBallTransform = null;

    public GameObject Timeline;
    public TestControllerManager testControllerScript;
    public GameObject wave;
    public GameObject wave2;
   

    private bool startBallRolling = true;
    public bool startRollingProcess = false;
    private GameObject ball;
    private SkinnedMeshRenderer visible;
    private BallBehavior ballBehaviorScript;

    private List<Vector3> WayPoints;
    private int currentTargetPos;
    

    private Animator animator;


    void Start()
    {
        WayPoints = new List<Vector3>();
        GameObject manager = GameObject.Find("TestController");
        testControllerScript = manager.GetComponent<TestControllerManager>();
        animator = GameObject.Find("testBall").GetComponent<Animator>();
        ball = GameObject.Find("basketball");
        visible = ball.GetComponent<SkinnedMeshRenderer>();
        animator.enabled = false;
        



        currentTargetPos = 0;
    }

    void Update()
    {
        if (playerTransform != null)
        {
            if (playerTransform.position == WayPoint2.position && startBallRolling)
            {
                startBallRolling = false;
                WayPoints.Add(hobbitBallTransform.position);
                WayPoints.Add(new Vector3(hobbitBallTransform.position.x, 0.2f, hobbitBallTransform.position.z));
                WayPoints.Add(new Vector3(5.42999983f, 0.00300000003f, 53.4500008f));
                ballTransform.position = hobbitBallTransform.position;
                startRollingProcess = true;
                
            }
        }

        if(startRollingProcess)
        {
            ballTransform.position = Vector3.MoveTowards(ballTransform.position, WayPoints[currentTargetPos], 5.0f * Time.deltaTime);
            animator.enabled = true;
            //ballTransform.RotateAround(ballTransform.position, Vector3.up, 270 * Time.deltaTime);
            //ballTransform.RotateAround(ballTransform.position, Vector3.left, 270 * Time.deltaTime);
            updateTargetPosition();
        }

        if (testControllerScript.waving && wave != null)
        {

            updateWave();
            
            
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

    void updateTargetPosition()
    {
        if (ballTransform.position == WayPoints[currentTargetPos])
        {
            if (currentTargetPos < WayPoints.Count - 1)
            {
                currentTargetPos++;
            }
            else
            {
                startRollingProcess = false;
            }
        }
    }


    void updateWave()
    {

        if (!visible.enabled)
        {
            PlayableDirector pd3 = wave2.GetComponent<PlayableDirector>();
            pd3.Play();
        }

        else
        {
           PlayableDirector pd2 = wave.GetComponent<PlayableDirector>();
           pd2.Play();
        }
    }
}
