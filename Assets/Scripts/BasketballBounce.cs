using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BasketballBounce : MonoBehaviour

    
{
    public AudioSource tickSource;

    // Start is called before the first frame update
    void Start()
    {
        tickSource = GetComponent<AudioSource> ();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnCollisionEnter (Collision collision) {
        if (collision.gameObject.tag == "Target") {

            tickSource.Play ();

        }
    }
}
