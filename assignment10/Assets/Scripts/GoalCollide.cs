using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GoalCollide : MonoBehaviour {

    // Start is called before the first frame update
    void Start() {
    }

    // Update is called once per frame
    void Update() {
        
    }

    void OnControllerColliderHit(ControllerColliderHit hit) {
        if (hit.gameObject.tag == "Goal") {
		  GameObject.Find("LevelComplete").GetComponent<Text>().color = new Color(0, 0, 0, 1);
        }
    }
}