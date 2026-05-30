const functions = require("firebase-functions");
const nodemailer = require("nodemailer");
const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");

admin.initializeApp();
const firestore = admin.firestore();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

const chiefWelcomeTemplate = (name, role)=>`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Welcome to Home Ops</title>
</head>
<body style="margin:0; padding:0; font-family:'Segoe UI', sans-serif; background:#f4f8ff;">

  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f8ff; padding:40px 0;">
    <tr>
      <td align="center">

        <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff; border-radius:12px; padding:40px; box-shadow:0 4px 12px rgba(0,0,0,0.05);">

          <tr>
            <td align="center">
              <h1 style="font-size:28px; color:#1a237e; margin:0;">
                Welcome to <strong>Home Ops</strong> 🎉
              </h1>
              <p style="font-size:16px; color:#555; margin-top:10px;">
                Your family’s productivity HQ is now live!
              </p>
            </td>
          </tr>

          <tr>
            <td style="padding-top:25px;">
              <p style="font-size:16px; color:#333; line-height:1.6;">
                Hi <strong>Chief</strong>,<br><br>
                Your Home Ops board has been successfully created.  
                You're officially in command!  
                From now on, you can oversee every aspect of your household—smoothly, efficiently, and all in one place.
              </p>
            </td>
          </tr>

          <tr>
            <td>
              <h3 style="font-size:20px; color:#1a237e;">What you can do as Chief:</h3>

              <ul style="font-size:16px; color:#444; line-height:1.8; padding-left:20px; margin-top:10px;">
                <li>Assign tasks to your spouse, grandparents, babysitters, and caregivers</li>
                <li>Manage your child’s daily routines, schedules, and care details</li>
                <li>Share kid profiles with family members & caregivers</li>
                <li>Track progress, time, completion, and household updates</li>
                <li>Organize groceries, meals, routines, reminders, and more</li>
                <li>Add board members and define their roles with just one tap</li>
                <li>Use AI-powered suggestions to simplify household management</li>
              </ul>
            </td>
          </tr>

          <tr>
            <td style="padding-top:20px;">
              <p style="font-size:16px; color:#555; line-height:1.6;">
                Your dashboard is ready.  
                You can begin adding members, creating tasks, and building a smarter and smoother family workflow.
              </p>
            </td>
          </tr>

          <tr>
        <td align="center" style="padding:30px 0;">
    <a href="https://drive.google.com/file/d/1-FBe9U-TM9kzuDbZwMcc4F96S8oFDxCS/view?usp=sharing" 
       style="background:#1a73e8; color:#fff; padding:14px 32px; border-radius:8px; text-decoration:none; font-size:16px; display:inline-block;">
      Open Home Ops
    </a>
        </td>
      </tr>

          <tr>
            <td>
              <p style="font-size:14px; color:#888; text-align:center; margin-top:30px;">
                Thank you for choosing Home Ops.<br>
                Together, we’ll make family life easier—one smart task at a time.
              </p>
            </td>
          </tr>

        </table>

      </td>
    </tr>
  </table>

</body>
</html>
` 


const invitationAcceptedTemplate = (chiefName, chiefEmail, userEmail, role, acceptedDate) => `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Invitation Accepted - Home Ops</title>
</head>
<body style="font-family: Arial, sans-serif; background-color: #f0f4fb; margin:0; padding:0;">
  <table width="100%" cellpadding="0" cellspacing="0" 
         style="max-width:600px; margin:0 auto; background:#ffffff; border-radius:12px; 
                box-shadow:0 6px 18px rgba(0,0,0,0.08); overflow:hidden;">

    <!-- Header -->
    <tr>
      <td style="padding:25px; text-align:center;">
        <h1 style="color:#333333; font-size:26px; margin:0;">🎉 Good News!</h1>
      </td>
    </tr>

    <!-- Body -->
    <tr>
      <td style="padding:30px; text-align:left;">

        <p style="color:#333; font-size:16px; margin:0 0 20px 0;">
          <strong>Dear ${chiefName},</strong>
        </p>

        <p style="color:#444; font-size:16px; line-height:1.7; margin:0 0 20px 0;">
          We are pleased to inform you that the user (${userEmail.substring(0,3)}*****@gmail.com) you recently invited to join 
          <strong>Home Ops</strong> has successfully accepted the invitation 
          and completed their onboarding process.
        </p>

        <p style="color:#444; font-size:16px; line-height:1.7; margin:0 0 20px 0;">
          This means they are now officially added to your Command Center and can begin 
          collaborating, accessing assigned roles, and participating in your Home Ops ecosystem.  
          Below are the details of the user who accepted the invitation:
        </p>

        <p style="color:#333; font-size:16px; margin:0 0 8px 0;">
          <strong>User Details:</strong>
        </p>
        <p style="color:#444; font-size:16px; margin:0;">
          Email: <strong>${userEmail}</strong>
        </p>
        <p style="color:#444; font-size:16px; margin:0;">
          Role Assigned: <strong>${role}</strong>
        </p>
        <p style="color:#444; font-size:16px; margin:0 0 20px 0;">
          Accepted On: <strong>${acceptedDate}</strong>
        </p>

        <p style="color:#444; font-size:16px; line-height:1.7;">
          You can now view their activity, manage their permissions, assign tasks, 
          and monitor their participation directly from your Home Ops dashboard.  
          We hope this addition brings more efficiency and coordination to your team.
        </p>

        <hr style="border:none; border-top:1px solid #ddd; margin:30px 0;">

        <p style="color:#888; font-size:13px; line-height:1.5;">
          If you did not authorize this invitation or believe this action was done in error, 
          please review your team settings from the Home Ops application.
        </p>

      </td>
    </tr>

    <!-- Footer -->
    <tr>
      <td style="background:#f7f9fc; padding:15px; color:#999; font-size:12px; text-align:left;">
        © ${new Date().getFullYear()} Home Ops. All rights reserved.
      </td>
    </tr>

  </table>
</body>
</html>`


const invitationHtmlTemplate = (role, name, password, email) => `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Home Ops Invitation</title>
</head>
<body style="font-family: Arial, sans-serif; background-color: #f0f4fb; margin:0; padding:0;">
  <table width="100%" cellpadding="0" cellspacing="0" 
         style="max-width:600px; margin:0 auto; background:#ffffff; border-radius:12px; 
                box-shadow:0 6px 18px rgba(0,0,0,0.08); overflow:hidden;">

    <!-- Header with only heading (no logo, no background color) -->
    <tr>
      <td style="padding:25px; text-align:center;">
        <h1 style="color:#333333; font-size:26px; margin:0;">🎉 Congratulations!</h1>
      </td>
    </tr>

    <!-- Body LEFT aligned -->
    <tr>
      <td style="padding:30px; text-align:left;">

        <p style="color:#333; font-size:16px; margin:0 0 20px 0;">
          <strong>Dear ${name},</strong>
        </p>

        <p style="color:#444; font-size:16px; line-height:1.7; margin:0 0 20px 0;">
          You are invited to <strong>Home Ops</strong> as <strong>${role}</strong>!
          By joining, you will gain access to our collaborative tools, stay connected with your team, 
          and contribute to making task management simple and efficient.  
          We are excited to have you on board!
        </p>

        <p style="color:#333; font-size:16px; line-height:1.7; margin:0 0 10px 0;">
        <strong>Your Login Credentials:</strong>
        </p>
        <p style="color:#444; font-size:16px; line-height:1.7; margin:0;">
        Email: <strong>${email}</strong>
        </p>
        <p style="color:#444; font-size:16px; line-height:1.7; margin:0 0 20px 0;">
       Password: <strong>${password}</strong>
       </p>

        <!-- Centered download text + button -->
        <div style="text-align:center; margin:30px 0;">
          <p style="color:#333; font-size:15px; margin-bottom:15px;">Download the App & Get Started</p>
          <a href="https://drive.google.com/file/d/1-FBe9U-TM9kzuDbZwMcc4F96S8oFDxCS/view?usp=sharing"
             style="display:inline-block; padding:14px 22px; background:#0057D9; color:#ffffff; 
                    text-decoration:none; border-radius:6px; font-weight:bold;">
            Download App
          </a>
        </div>

        <hr style="border:none; border-top:1px solid #ddd; margin:30px 0;">

        <p style="color:#888; font-size:13px; line-height:1.5;">
          If you did not request or recognize this activity, please ignore this email.  
          No action is required.
        </p>

      </td>
    </tr>

    <!-- Footer LEFT aligned -->
    <tr>
      <td style="background:#f7f9fc; padding:15px; color:#999; font-size:12px; text-align:left;">
        © ${new Date().getFullYear()} Home Ops. All rights reserved.
      </td>
    </tr>

  </table>
</body>
</html>`;

const userJoinedTemplate = (userName, userEmail, joinedOn) => `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>User Joined Notification</title>
</head>

<body style="font-family: Arial, sans-serif; background-color: #f0f4fb; margin:0; padding:0;">
  <table width="100%" cellpadding="0" cellspacing="0"
    style="max-width:600px; margin:0 auto; background:#ffffff; border-radius:12px;
           box-shadow:0 6px 18px rgba(0,0,0,0.08); overflow:hidden;">

    <!-- Header -->
    <tr>
      <td style="padding:25px; text-align:center;">
        <h1 style="color:#333333; font-size:26px; margin:0;">👤 New Crew Member Joined</h1>
      </td>
    </tr>

    <!-- Body -->
    <tr>
      <td style="padding:30px; text-align:left;">

        <p style="color:#333; font-size:16px; margin:0 0 20px 0;">
          <strong>Dear Chief,</strong>
        </p>

        <p style="color:#444; font-size:16px; line-height:1.7; margin:0 0 20px 0;">
          We’re excited to inform you that a new user has recently joined your crew on
          <strong>Home Ops</strong>. Below are the details of the member who has just signed up and is now waiting for your review.
        </p>

        <!-- User Details -->
        <table cellpadding="0" cellspacing="0" style="width:100%; margin-bottom:25px;">
          <tr>
            <td style="padding:8px 0; font-size:15px; color:#333;">
              <strong>User Name:</strong>
            </td>
            <td style="padding:8px 0; font-size:15px; color:#555;">
              ${userName}
            </td>
          </tr>

          <tr>
            <td style="padding:8px 0; font-size:15px; color:#333;">
              <strong>User Email:</strong>
            </td>
            <td style="padding:8px 0; font-size:15px; color:#555;">
              ${userEmail}
            </td>
          </tr>

          <tr>
            <td style="padding:8px 0; font-size:15px; color:#333;">
              <strong>Joined On:</strong>
            </td>
            <td style="padding:8px 0; font-size:15px; color:#555;">
              ${joinedOn}
            </td>
          </tr>
        </table>

        <p style="color:#444; font-size:16px; line-height:1.7;">
          To ensure your workspace remains secure and organized, we kindly request you to review this user and either
          <strong>approve</strong> or <strong>reject</strong> their onboarding request.
        </p>

        <!-- Button -->
        <div style="text-align:center; margin:30px 0;">
          <p style="color:#333; font-size:15px; margin-bottom:15px;">
            Open the app to manage their access
          </p>

          <a href="https://drive.google.com/file/d/1-FBe9U-TM9kzuDbZwMcc4F96S8oFDxCS/view?usp=sharing"
             style="display:inline-block; padding:14px 22px; background:#0057D9; color:#ffffff;
             text-decoration:none; border-radius:6px; font-weight:bold;">
            Open Home Ops
          </a>
        </div>

        <hr style="border:none; border-top:1px solid #ddd; margin:30px 0;">

        <p style="color:#888; font-size:13px; line-height:1.5;">
          If you believe this activity was not initiated by you or someone on your board, please contact support immediately.
        </p>

      </td>
    </tr>

    <!-- Footer -->
    <tr>
      <td style="background:#f7f9fc; padding:15px; color:#999; font-size:12px; text-align:left;">
        © ${new Date().getFullYear()} Home Ops. All rights reserved.
      </td>
    </tr>

  </table>
</body>
</html>
`

const newUserWelcomeTemplate = (userName) => `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Welcome to Home Ops</title>
</head>

<body style="font-family: Arial, sans-serif; background-color: #f0f4fb; margin:0; padding:0;">
  <table width="100%" cellpadding="0" cellspacing="0"
    style="max-width:600px; margin:0 auto; background:#ffffff; border-radius:12px;
           box-shadow:0 6px 18px rgba(0,0,0,0.08); overflow:hidden;">

    <tr>
      <td style="padding:25px; text-align:center;">
        <h1 style="color:#333333; font-size:26px; margin:0;">🎉 Welcome to Home Ops!</h1>
      </td>
    </tr>

    <tr>
      <td style="padding:30px; text-align:left;">

        <p style="color:#333; font-size:16px; margin:0 0 20px 0;">
          <strong>Hi ${userName},</strong>
        </p>

        <p style="color:#444; font-size:16px; line-height:1.7; margin:0 0 20px 0;">
          Thank you for joining <strong>Home Ops</strong>!
          We're delighted to have you here and excited for you to explore what Home Ops can bring to your daily workflow.
        </p>

        <p style="color:#444; font-size:16px; line-height:1.7; margin:0 0 20px 0;">
          At the moment, your request to join the board is <strong>under review</strong> by the Chief.  
          They will review your details shortly and decide whether to approve or decline your request.  
          Once the Chief takes action, you’ll receive an email notification immediately with the update.
        </p>

        <p style="color:#444; font-size:16px; line-height:1.7; margin:0 0 20px 0;">
          Until then, feel free to explore the Home Ops app, review the features, and get familiar with our tools that help keep families, tasks, and daily operations organized and stress-free.
        </p>

        <p style="color:#333; font-size:16px; line-height:1.7; font-weight:bold; margin:0 0 20px 0;">
          What happens next?
        </p>

        <ul style="color:#555; font-size:15px; line-height:1.8; padding-left:20px; margin:0 0 25px 0;">
          <li>The Chief reviews your request.</li>
          <li>You receive an email notification once the decision is made.</li>
          <li>If approved, you’ll gain full access to the board and its shared tools.</li>
          <li>If declined, you may try again or contact the Chief for clarification.</li>
        </ul>

        <p style="color:#444; font-size:16px; line-height:1.7;">
          We're committed to making your experience seamless, productive, and enjoyable.  
          Welcome once again — the team is excited to have you on board!
        </p>

        <hr style="border:none; border-top:1px solid #ddd; margin:30px 0;">

        <p style="color:#888; font-size:13px; line-height:1.5;">
          If you did not request to join a Home Ops board, please ignore this email.
        </p>

      </td>
    </tr>

    <tr>
      <td style="background:#f7f9fc; padding:15px; color:#999; font-size:12px; text-align:left;">
        © ${new Date().getFullYear()} Home Ops. All rights reserved.
      </td>
    </tr>

  </table>
</body>
</html>
  `

const userJoinAcceptedTemplate = (chiefEmail, userName, role) => `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Welcome to Home Ops</title>
</head>
<body style="font-family: Arial, sans-serif; background-color: #f0f4fb; margin:0; padding:0;">
  <table width="100%" cellpadding="0" cellspacing="0" 
         style="max-width:600px; margin:0 auto; background:#ffffff; border-radius:12px; 
                box-shadow:0 6px 18px rgba(0,0,0,0.08); overflow:hidden;">

    <!-- Header -->
    <tr>
      <td style="padding:25px; text-align:center;">
        <h1 style="color:#333333; font-size:26px; margin:0;">🎉 Welcome Aboard!</h1>
      </td>
    </tr>

    <!-- Body -->
    <tr>
      <td style="padding:30px; text-align:left;">

        <p style="color:#333; font-size:16px; margin:0 0 20px 0;">
          <strong>Hi ${userName},</strong>
        </p>

        <p style="color:#444; font-size:16px; line-height:1.7; margin:0 0 20px 0;">
          Your request to join <strong>Home Ops</strong> has been accepted. 
          You are now officially part of the board as a <strong>${role}</strong>.
        </p>


        <p style="color:#444; font-size:16px; line-height:1.7; margin:0 0 20px 0;">
          You can now access your tasks, view schedules, and collaborate with your team directly from your Home Ops dashboard. 
          We’re excited to have you on board!
        </p>

        <hr style="border:none; border-top:1px solid #ddd; margin:30px 0;">

        <p style="color:#888; font-size:13px; line-height:1.5;">
          If you did not request this or believe this action was done in error, please contact <strong>${chiefEmail}</strong> immediately.
        </p>

      </td>
    </tr>

    <!-- Footer -->
    <tr>
      <td style="background:#f7f9fc; padding:15px; color:#999; font-size:12px; text-align:left;">
        © ${new Date().getFullYear()} Home Ops. All rights reserved.
      </td>
    </tr>

  </table>
</body>
</html>
`;



// Transporter with dual-pattern credentials
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.GMAIL_EMAIL ||  functions.config().gmail.email,
    pass: process.env.GMAIL_PASSWORD || functions.config().gmail.password,
  },
});

app.post("/send", async (req, res) => {
  const { email, role, name, password } = req.body;

  if (!email) return res.status(400).json({ error: "Email is required" });

  try {
    await transporter.sendMail({
      from: `"Home Ops" <${process.env.GMAIL_EMAIL || functions.config().gmail.email}>`,
      to: email,
      subject: "You're Invited to Home Ops!",
         html: invitationHtmlTemplate(role, name, password, email),
    });

    res.json({ success: true });
  } catch (err) {
    console.error("Email error:", err);
    res.status(500).json({ error: err.message });
  }
});

app.post("/accepted", async (req, res) => {
  const { chiefName, chiefEmail, userEmail, role, acceptedDate, boardId, userUid } = req.body;

  if (!chiefEmail) return res.status(400).json({ error: "Chief email is required" });

  try {
    await transporter.sendMail({
      from: `"Home Ops" <${process.env.GMAIL_EMAIL || functions.config().gmail.email}>`,
      to: chiefEmail,
      subject: "Update: Invitation Accepted",
      html: invitationAcceptedTemplate(chiefName, chiefEmail, userEmail, role, acceptedDate),
    });
      await admin.firestore()
          .collection("notifications")
          .doc(boardId)
          .collection("members")
          .add({
            title :"Welcome to Home Ops!",
            body : `You’ve been added to the Home Ops board as ${role}. Start collaborating and managing tasks with your team!` ,
            type: "welcome_user",
            recipientUid: userUid, 
            read: false,
            name : 'Home Ops', 
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            imagePath: "https://firebasestorage.googleapis.com/v0/b/home-ops-10cc3.firebasestorage.app/o/app_icon_foreground.png?alt=media&token=32b5ab55-58a8-4e46-a3c7-2f5fd78ab2f7",      
          });

    res.json({ success: true });
  } catch (err) {
    console.error("Email error:", err);
    res.status(500).json({ error: err.message });
  }
});

app.post("/send-chief-welcome", async (req, res) => {
  const { email, name, role, chiefUid, boardId } = req.body;

  if (!email) return res.status(400).json({ error: "Email is required" });

  try {
    await transporter.sendMail({
      from: `"Home Ops" <${process.env.GMAIL_EMAIL || functions.config().gmail.email}>`,
      to: email,
      subject: "Welcome to Home Ops!",
      html: chiefWelcomeTemplate(name, role),
    });

     await admin.firestore()
          .collection("notifications")
          .doc(boardId)
          .collection("chief")
          .add({
            title  :"Welcome to Home Ops!",
            body : "Your Home Ops board is ready. You’re now in command to manage your household efficiently." ,
            type: "welcome_chief",
            read: false,
            recipientUid: chiefUid,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            name : 'Home Ops',
            imagePath: "https://firebasestorage.googleapis.com/v0/b/home-ops-10cc3.firebasestorage.app/o/app_icon_foreground.png?alt=media&token=32b5ab55-58a8-4e46-a3c7-2f5fd78ab2f7",      
          });

    res.json({ success: true });
  } catch (err) {
    console.error("Email error:", err);
    res.status(500).json({ error: err.message });
  }
});

app.post("/send-user-joined-notification", async (req, res) => {
  const {chiefEmail, userName, userEmail, joinedOn } = req.body;

  if (!chiefEmail) {
    return res.status(400).json({ error: "chiefEmail is required" });
  }

  try {
    await transporter.sendMail({
      from: `"Home Ops" <${process.env.GMAIL_EMAIL || functions.config().gmail.email}>`,
      to: chiefEmail,
      subject: "A New Member Has Joined the Crew",
      html: userJoinedTemplate(userName, userEmail, joinedOn ),
    });

    res.json({ success: true });
  } catch (err) {
    console.error("Email error:", err);
    res.status(500).json({ error: err.message });
  }
});


app.post("/send-user-welcome", async (req, res) => {
  const { userName, userEmail} = req.body;

  if (!userEmail) {
    return res.status(400).json({ error: "userEmail is required" });
  }

  try {
    await transporter.sendMail({
      from: `"Home Ops" <${process.env.GMAIL_EMAIL || functions.config().gmail.email}>`,
      to: userEmail,
      subject: "Welcome to Home Ops – Your Request is Under Review",
      html: newUserWelcomeTemplate(userName),
    });

   

    res.json({ success: true });
  } catch (err) {
    console.error("Email error:", err);
    res.status(500).json({ error: err.message });
  }
});

app.post("/send-acceptance-email", async (req, res) => {
  const { chiefEmail, userName, userEmail, role, userUid, boardId } = req.body;

  if (!chiefEmail || !userName || !userEmail || !role) {
    return res.status(400).json({ 
      error: "chiefEmail, userName, userEmail, role are required" 
    });
  }

  try {
    // Send the email
    await transporter.sendMail({
      from: `"Home Ops" <${process.env.GMAIL_EMAIL || functions.config().gmail.email}>`,
      to: userEmail, // Send to the user who joined
      subject: "Your Join Request Has Been Accepted",
      html: userJoinAcceptedTemplate(chiefEmail, userName, role),
    });

     await admin.firestore()
          .collection("notifications")
          .doc(boardId)
          .collection("members")
          .add({
            title :"Welcome to Home Ops!",
            body : `You’ve been added to the Home Ops board as ${role}. Start collaborating and managing tasks with your team!` ,
            type: "welcome_user",
            recipientUid: userUid, 
            read: false,
            name : 'Home Ops', 
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            imagePath: "https://firebasestorage.googleapis.com/v0/b/home-ops-10cc3.firebasestorage.app/o/app_icon_foreground.png?alt=media&token=32b5ab55-58a8-4e46-a3c7-2f5fd78ab2f7",      
          });

    res.json({ success: true, message: "Notification email sent successfully" });
  } catch (err) {
    console.error("Email error:", err);
    res.status(500).json({ error: err.message });
  }
});


// Export as 2nd-gen HTTPS function
exports.invitation = functions.https.onRequest(app);
