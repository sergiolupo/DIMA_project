const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

// Replace with your News API key and the API endpoint
const NEWS_API_KEY = '61f777e67a9346cebb7cecf45b243af9';
const NEWS_API_URL = `https://newsapi.org/v2/everything?q=category&apiKey=${NEWS_API_KEY}`;
const NEWS_API_URL2 = `https://newsapi.org/v2/everything?q=sport&apiKey=${NEWS_API_KEY}`;

exports.checkNewsUpdate = functions.pubsub.schedule('every 2 minutes').onRun(async (context) => {
    try {
        // Step 1: Call the News API
        const response = await axios.get(NEWS_API_URL);
        const latestArticles = response.data.articles;

        // Step 2: Get the last saved articles from Firestore
        const articlesRef = db.collection('news').doc('latest');
        const doc = await articlesRef.get();

        if (!doc.exists) {
            // If no articles have been saved before, save the current ones
            await articlesRef.set({ articles: latestArticles });
        } else {
            // Step 3: Compare the new articles with the stored ones
            const previousArticles = doc.data().articles;

            // Assuming the API returns articles sorted by publication date, just compare the first ones
            const isDifferent = latestArticles[0].title !== previousArticles[0].title;

            if (isDifferent) {
                // Step 4: If there's a difference, send a notification
                await sendNotification("New articles available!");

                // Step 5: Update the stored articles
                await articlesRef.set({ articles: latestArticles });
            }
        }
    } catch (error) {
        console.error("Error fetching news or sending notification:", error);
    }

    return null;
});

async function sendNotification(message) {
    const payload = {
        notification: {
            title: "News Update",
            body: message,
        },
    };

    // Send a notification to all devices subscribed to the "news" topic
    await admin.messaging().sendToTopic("news", payload);
}
