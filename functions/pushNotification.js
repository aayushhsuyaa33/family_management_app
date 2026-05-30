const functions = require("firebase-functions");
const express = require("express");
const admin = require("firebase-admin");
const cors = require("cors");
const { user } = require("firebase-functions/v1/auth");

if (!admin.apps.length) {
  admin.initializeApp();

}
const app = express();
app.use(express.json());
app.use(cors({ origin: true }));

// -----------------------------
// 🔔 FUNCTION TO SEND PUSH
// -----------------------------
async function sendPushNotification(token, title, body) {
  if (!token) return { success: false, msg: "No token provided" };

  const message = {
    token: token,
    notification: {
      title: title,
      body: body,
    },
    android: {
      priority: "high",
      notification: { channelId: "default" },
    },
    apns: { payload: { aps: { sound: "default" } } },
  };

  try {
    const response = await admin.messaging().send(message);
    return { success: true, response };
  } catch (error) {
    console.error("❌ Error sending push:", error);
    return { success: false, error };
  }
}

// -----------------------------
// 📌 ENDPOINT — WHEN A USER JOINS
// -----------------------------
app.post("/userJoinNotification", async (req, res) => {
  const { chiefUid, newUserName, boardId, imagePath} = req.body;

  if (!chiefUid || !newUserName || !boardId) {
    return res.status(400).json({
      error: "chiefUid, UserName & baordId are required",
    });
  }

  try {
    // Fetch Chief's data
    const chiefDoc = await admin.firestore().collection("users").doc(chiefUid).get();


    if (!chiefDoc.exists) {
      return res.status(404).json({ error: "Chief user not found" });
    }

    const chiefData = chiefDoc.data();
    const chiefToken = chiefData.fcmToken;

    if (!chiefToken) {
      return res.status(400).json({ error: "Chief has no FCM token" });
    }

    // Create notification content
    const title = "New Crew Member!";
    const body = `@${newUserName} just joined your crew.`;

     await admin.firestore()
      .collection("notifications")
      .doc(boardId)
      .collection("chief")
      .add({
        title,
        body : `@${newUserName} has requested to join your board. Please review to accept or reject.`,
        type: "user_join",
        recipientUid: chiefUid,
        read: false,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        imagePath: imagePath ?? "", 
        name : newUserName
      });

    // Send push
    const result = await sendPushNotification(chiefToken, title, body);

    if (!result.success) {
      return res.status(500).json({ error: "Failed to send push", result });
    }

    return res.json({
      message: "Push notification sent to chief successfully",
      result,
    });

  } catch (error) {
    console.error("❌ Error:", error);
    return res.status(500).json({ error: error.message });
  }
});

app.post("/userAcceptNotification", async (req, res) => {
  const { chiefUid, newUserName, boardId, imagePath} = req.body;

  if (!chiefUid || !newUserName || !boardId) {
    return res.status(400).json({
      error: "chiefUid, userName and boardId are required",
    });
  }

  try {
    // Fetch Chief's data
    const chiefDoc = await admin.firestore().collection("users").doc(chiefUid).get();

    if (!chiefDoc.exists) {
      return res.status(404).json({ error: "Chief user not found" });
    }

    const chiefData = chiefDoc.data();
    const chiefToken = chiefData.fcmToken;

    if (!chiefToken) {
      return res.status(400).json({ error: "Chief has no FCM token" });
    }

    // Create notification content
    const title = "Invitation Accepted!";
    const body = `@${newUserName} has accepted your invitation.`;

      await admin.firestore()
      .collection("notifications")
      .doc(boardId)
      .collection("chief")
      .add({
        title,
        body,
        type: "user_accept",
        recipientUid: chiefUid,
        read: false,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        name : newUserName, 
        imagePath: imagePath?? ""
      });

    // Send push
    const result = await sendPushNotification(chiefToken, title, body);

    if (!result.success) {
      return res.status(500).json({ error: "Failed to send push", result });
    }

    return res.json({
      message: "Push notification sent to chief successfully",
      result,
    });

  } catch (error) {
    console.error("❌ Error:", error);
    return res.status(500).json({ error: error.message });
  }
});


app.post("/cheifAcceptNotification", async (req, res) => {
  const {userUid, boardId, role } = req.body;

  if (!userUid || !boardId) {
    return res.status(400).json({
      error: "UserUid & BoardId are required",
    });
  }

  try {
    // Fetch Chief's data
    const userDoc = await admin.firestore().collection("board").doc(boardId).collection('joinRequests').doc(userUid).get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: "User not found" });
    }

    const userData = userDoc.data();
    const userToken = userData.fcmToken;

    if (!userToken) {
      return res.status(400).json({ error: "User has no FCM token" });
    }

    // Create notification content
    const title = "Join Request Accepted!";
    const body = `🎉 Great news! Your request has been approved as ${role}.`;

      

    // Send push
    const result = await sendPushNotification(userToken, title, body);

    if (!result.success) {
      return res.status(500).json({ error: "Failed to send push", result });
    }

    return res.json({
      message: "Push notification sent to User successfully",
      result,
    });

  } catch (error) {
    console.error("❌ Error:", error);
    return res.status(500).json({ error: error.message });
  }
});

app.post("/chiefRejectNotification", async (req, res) => {
  const {userUid, boardId} = req.body;

  if (!userUid || !boardId) {
    return res.status(400).json({
      error: "UserUid & BoardId are required",
    });
  }

  try {
    // Fetch Chief's data
    const userDoc = await admin.firestore().collection("board").doc(boardId).collection('joinRequests').doc(userUid).get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: "User not found" });
    }

    const userData = userDoc.data();
    const userToken = userData.fcmToken;

    if (!userToken) {
      return res.status(400).json({ error: "User has no FCM token" });
    }

    // Create notification content
    const title = "Join Request Rejected";
    const body = `❌ Your request has been rejected by the chief.`

    // Send push
    const result = await sendPushNotification(userToken, title, body);

    if (!result.success) {
      return res.status(500).json({ error: "Failed to send push", result });
    }

    return res.json({
      message: "Push notification sent to User successfully",
      result,
    });

  } catch (error) {
    console.error("❌ Error:", error);
    return res.status(500).json({ error: error.message });
  }
});




app.post("/sendTaskAssignedNotification", async (req, res) => {
  const {userUids, boardId, taskTitle, description, chiefName} = req.body;


 if (!userUids || !Array.isArray(userUids) || userUids.length === 0) {
    return res.status(400).json({ error: "userUids (array) is required" });
  }
   if (!boardId) {
    return res.status(400).json({ error: "boardId is required" });
  }


  try {
const tokens = [];
const firstName = chiefName.split(" ")[0]; // "Ayush"
    for (const userUid of userUids) {
      const userDoc = await admin
        .firestore()
        .collection("board")
        .doc(boardId)
        .collection("joinRequests").doc(userUid)        
        .get();

      if (userDoc.exists) {
        const userData = userDoc.data();

       const token = userData.fcmToken;
        if (token) tokens.push(token);
      }

      await admin.firestore()
      .collection("notifications")
      .doc(boardId)
      .collection("members")
      .add({
        title: "New Task Assigned!",
        body : `@${firstName} has assigned you a new task: ${taskTitle}.`,
        type: "task_assigned",
        recipientUid: userUid,
        read: false,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        name: chiefName, 
        imagePath: null
      });

    }
      if (tokens.length === 0) {
      return res.status(400).json({ error: "No FCM tokens found for users" });
    }


    const message = {
      notification: {
        title: "New Task Assigned!",
        body: `@${firstName} has assigned you a new task`,
      },
      data: {
        taskTitle: taskTitle,
        description: description || "",
        type: "task_assigned",
      },
    };

   const response = await admin.messaging().sendEachForMulticast({tokens: tokens, ...message});
   return res.json({
      message: "Push notifications sent successfully",
      sentTo: tokens.length,
      response
    });

  } catch (error) {
    console.error("❌ Error:", error);
    return res.status(500).json({ error: error.message });
  }
});



app.post("/sendEventAssignedNotification", async (req, res) => {
  const {userUids, boardId, taskTitle, description, chiefName} = req.body;


 if (!userUids || !Array.isArray(userUids) || userUids.length === 0) {
    return res.status(400).json({ error: "userUids (array) is required" });
  }
   if (!boardId) {
    return res.status(400).json({ error: "boardId is required" });
  }

  try {
const tokens = [];
const firstName = chiefName.split(" ")[0]; // "Ayush"
    for (const userUid of userUids) {
      const userDoc = await admin
        .firestore()
        .collection("board")
        .doc(boardId)
        .collection("joinRequests").doc(userUid)        
        .get();

      if (userDoc.exists) {
        const userData = userDoc.data();

       const token = userData.fcmToken;
        if (token) tokens.push(token);
      }

      await admin.firestore()
      .collection("notifications")
      .doc(boardId)
      .collection("members")
      .add({
        title: "New Event Assigned!",
        body : `@${firstName} has assigned you a new Event: ${taskTitle}.`,
        type: "event_assigned",
        recipientUid: userUid,
        read: false,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        name: chiefName, 
        imagePath: null
      });
    }
      if (tokens.length === 0) {
      return res.status(400).json({ error: "No FCM tokens found for users" });
    }
const message = {
  notification: {
    title: "New Event Assigned!",
    body: `@${firstName} has assigned you a new event`,
  },
  data: {
    taskTitle: taskTitle,
    description: description || "",
    type: "event_assigned",
  },
};
   const response = await admin.messaging().sendEachForMulticast({tokens: tokens, ...message});
   return res.json({
      message: "Push notifications sent successfully",
      sentTo: tokens.length,
      response
    });

  } catch (error) {
    console.error("❌ Error:", error);
    return res.status(500).json({ error: error.message });
  }
});


app.post("/sendTaskCompleteNotification", async (req, res) => {
  const {taskIds, boardId, userName, imagePath, savedRole} = req.body;

 if (!boardId || !taskIds || !Array.isArray(taskIds) || taskIds.length === 0) {
    return res.status(400).json({ error: "boardId, and taskTitles are required" });
  }
  try {
    const firstName = userName.split(' ')[0];
     const chiefDoc = await admin.firestore()
      .collection("Chiefs")
      .doc(boardId)
      .get();

    if (!chiefDoc.exists) {
      return res.status(404).json({ error: "Chief not found" });
    }
    const chiefData = chiefDoc.data();
    const chiefToken = chiefData.fcmToken;
    const chiefUid = chiefData.uid;

     if (!chiefToken) {
      return res.status(400).json({ error: "Chief has no FCM token" });
    }


    for (const id of taskIds) {
       const taskDoc = await admin.firestore()
        .collection("tasks")
        .doc(boardId)
        .collection("allTasks")
        .doc(id)
        .get();

      if (!taskDoc.exists) continue;
      const taskData = taskDoc.data();
      const taskTitle = taskData.title;

      const title = "Task Completed!";
      const body = savedRole === "Chief" ? `@You have a completed a task`: `@${firstName} has completed a task`;


   const result = await sendPushNotification(chiefToken, title, body);

    if (!result.success) {
      return res.status(500).json({ error: "Failed to send push", result });
    }
      await admin.firestore()
        .collection("notifications")
        .doc(boardId)
        .collection("chief")
        .add({
          title: "Task Completed!",
          body: savedRole === "Chief" ? `@You have a completed a task: ${taskTitle}`: `@${firstName} has completed a task: ${taskTitle}`,
          recipientUid: chiefUid, 
          read: false,
          type : "task_completed",
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          name : userName, 
          imagePath : imagePath ?? null
        });

    }
    return res.json({
      message: "Notifications sent & saved successfully",
      count: taskIds.length,
    });
  } catch (error) {
    console.error("❌ Error:", error);
    return res.status(500).json({ error: error.message });
  }
});


app.post("/sendEventCompleteNotification", async (req, res) => {
  const {taskIds, boardId, userName, imagePath, savedRole} = req.body;

 if (!boardId || !taskIds || !Array.isArray(taskIds) || taskIds.length === 0) {
    return res.status(400).json({ error: "boardId, and taskTitles are required"  });
  }


  try {
    const firstName = userName.split(' ')[0];
     const chiefDoc = await admin.firestore()
      .collection("Chiefs")
      .doc(boardId)
      .get();

       if (!chiefDoc.exists) {
      return res.status(404).json({ error: "Chief not found" });
    }

    const chiefData = chiefDoc.data();
    const chiefToken = chiefData.fcmToken;
    const chiefUid = chiefData.uid;

    if (!chiefToken) {
      return res.status(400).json({ error: "Chief has no FCM token" });
    }

    for (const id of taskIds) {
      const taskDoc = await admin.firestore()
        .collection("events")
        .doc(boardId)
        .collection("allEvents")
        .doc(id)
        .get();

         if (!taskDoc.exists) continue;

          const taskData = taskDoc.data();
          const taskTitle = taskData.title;

      const title = "Event Completed!";
      const body = savedRole === "Chief" ? `@You have a completed an event`: `@${firstName} has completed an event`;
       
      const result = await sendPushNotification(chiefToken, title, body);

      
    if (!result.success) {
      return res.status(500).json({ error: "Failed to send push", result });
    }
    

      await admin.firestore()
        .collection("notifications")
        .doc(boardId)
        .collection("chief")
        .add({
          title: "Event Completed!",
          body: savedRole === "Chief" ? `@You have a completed a task: ${taskTitle}`: `@${firstName} has completed a task: ${taskTitle}`,
          recipientUid: chiefUid, 
          read: false,
          type : "event_completed",
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          name : userName, 
          imagePath : imagePath ?? null
        });
      
    }
    return res.json({
      message: "Notifications sent & saved successfully",
      count: taskIds.length,
    });
  } catch (error) {
    console.error("❌ Error:", error);
    return res.status(500).json({ error: error.message });
  }
});

// From here I have to start and remmber markasdoen is showing a bt unexpected behaviour chek it as well bye bye 

app.post("/sendTaskRemoveNotification", async (req, res) => {
  const {userUids, boardId, taskTitle, chiefName} = req.body;


 if (!userUids || !Array.isArray(userUids) || userUids.length === 0) {
    return res.status(400).json({ error: "userUids (array) is required" });
  }
   if (!boardId) {
    return res.status(400).json({ error: "boardId is required" });
  }

  try {
const tokens = [];
const firstName = chiefName.split(" ")[0]; // "Ayush"
    for (const userUid of userUids) {
      const userDoc = await admin
        .firestore()
        .collection("board")
        .doc(boardId)
        .collection("joinRequests").doc(userUid)        
        .get();

      if (userDoc.exists) {
        const userData = userDoc.data();
       const token = userData.fcmToken;
        if (token) tokens.push(token);
      }

      await admin.firestore()
      .collection("notifications")
      .doc(boardId)
      .collection("members")
      .add({
        title: "Task Removed!",
        body : `@${firstName} has removed the task: ${taskTitle}.`,
        type: "task_removed",
        recipientUid: userUid,
        read: false,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        name: chiefName, 
        imagePath: null
      });
    }
      if (tokens.length === 0) {
      return res.status(400).json({ error: "No FCM tokens found for users" });
    }

const message = {
  notification: {
    title: "Task Removed!",
    body: `@${firstName} has removed a task`,
  },
  data: {
    taskTitle: taskTitle,
    description: description || "",
    type: "task_removed",
  },
};
   const response = await admin.messaging().sendEachForMulticast({tokens: tokens, ...message});
   return res.json({
      message: "Push notifications sent successfully",
      sentTo: tokens.length,
      response
    });

  } catch (error) {
    console.error("❌ Error:", error);
    return res.status(500).json({ error: error.message });
  }
});



app.post("/sendTaskAddedToGoogleNotification", async (req, res) => {
  const {taskTitle, boardId, userName, userUid, imagePath} = req.body;

 if (!boardId || !taskTitle) {
    return res.status(400).json({ error: "boardId, and taskTitle are required" });
  }
const firstName = userName.split(' ')[0];

  try {
     const chiefDocs = await admin.firestore()
      .collection("Chiefs")
      .doc(boardId)
      .get();

    const chiefToken = chiefDocs.fcmToken;
    const chiefUid = chiefDocs.uid;

      const bodyMessage = `@${firstName} has added a task to google Calender`;

      const message= {
        notification: {
          title: "Task Added to Google!",
          body: bodyMessage,
        },
        data: {
          type: "task_added_google",
          taskTitle,
          userUid,
        }
      }
      await admin.messaging().sendEachForMulticast({tokens : [chiefToken], ...message});

      await admin.firestore()
        .collection("notifications")
        .doc(boardId)
        .collection("chiefs")
        .add({
          title: "Task Completed!",
          body:  `@${firstName} has added a task to google Calender: ${taskTitle}`, 
          recipientUid: chiefUid, 
          read: false,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          name : userName, 
          imagePath : imagePath ?? null
        });
    
  } catch (error) {
    console.error("❌ Error:", error);
    return res.status(500).json({ error: error.message });
  }
});

exports.pushNotification = functions.https.onRequest(app);
