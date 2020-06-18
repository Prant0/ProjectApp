const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
exports.onCreateFollower = functions.firestore
    .document('/follower/{userId}/userFollower/{followerId}')
    .onCreate(async(snapshot, context)=>{
        console.log('Follower Created', snapshot.id);
        const userId = context.params.userId;
        const followerId = context.params.followerId;

        //1) Get Followed Users Post
        const followedUserPostRef = admin
            .firestore()
            .collection('posts')
            .doc(userId)
            .collection('usersPosts');

        //2) Get Following Users TimeLine
        const timelinePostRef = admin
            .firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts');

        const querySnapshot = await followedUserPostRef.get();

        //3) Each User Post to Following User Timeline
        querySnapshot.forEach(doc =>{
            if(doc.exists){
                const postId = doc.id;
                const postData = doc.data();
                timelinePostRef.doc(postId).set(postData);
            }
        });
    });
    // Deleting User Timeline
    exports.onDeleteFollower = functions.firestore
        .document('/follower/{userId}/userFollower/{followerId}')
        .onDelete(async(snapshot, context)=>{
            console.log('Follower Removed', snapshot.id);
            const userId = context.params.userId;
            const followerId = context.params.followerId;

        const timelinePostRef = admin
        .firestore()
        .collection('timeline')
        .doc(followerId)
        .collection('timelinePosts')
        .where('ownerId','==',userId);

    const querySnapshot = await timelinePostRef.get();

        querySnapshot.forEach(doc =>{
        if(doc.exists){
            doc.ref.delete();
        }
    });

});
// Create
exports.onCreatePost = functions.firestore
    .document('/posts/{userId}/usersPosts/{postId}')
    .onCreate(async(snapshot, context)=>{
        const postCreated = snapshot.data();
        const userId = context.params.userId;
        const followerId = context.params.followerId;


        const userFollowerRef = admin
            .firestore()
            .collection('follower')
            .doc(userId)
            .collection('userFollower');


        const querySnapshot = await userFollowerRef.get();
        querySnapshot.forEach(doc =>{
            const followerId = doc.id;
            admin.firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts')
            .doc(postId)
            .set(postCreated);
        });
    });

    // Update
    exports.onUpdatePost = functions.firestore
        .document('/posts/{userId}/usersPosts/{postId}')
        .onUpdate(async(change, context)=>{
            const postUpdate = change.after.data();
            const userId = context.params.userId;
            const postId = context.params.postId;


            const userFollowerRef = admin
                .firestore()
                .collection('follower')
                .doc(userId)
                .collection('userFollower');


            const querySnapshot = await userFollowerRef.get();
            querySnapshot.forEach(doc =>{
                const followerId = doc.id;
                admin.firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .get().then(doc => {
                    if(doc.exists){
                        doc.ref.update(postUpdate);
                    }
                });
            });
        });
    // Delete
     // Update
        exports.onDeletePost = functions.firestore
            .document('/posts/{userId}/usersPosts/{postId}')
            .onDelete(async(snapshot, context)=>{
                const userId = context.params.userId;
                const postId = context.params.postId;


                const userFollowerRef = admin
                    .firestore()
                    .collection('follower')
                    .doc(userId)
                    .collection('userFollower');


                const querySnapshot = await userFollowerRef.get();
                querySnapshot.forEach(doc =>{
                    const followerId = doc.id;
                    admin.firestore()
                    .collection('timeline')
                    .doc(followerId)
                    .collection('timelinePosts')
                    .doc(postId)
                    .get().then(doc => {
                        if(doc.exists){
                            doc.ref.delete();
                        }
                    });
                });
            });














