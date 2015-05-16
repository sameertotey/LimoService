function sendPush(installationQuery, message, limoreq) {
  Parse.Push.send({
    where: installationQuery,
    data: {
    alert:  message,
    limoreq: limoreq
    }
  }, {
    success: function() {
      // Push was successful
      console.log("Push was sent successfully")
    },
    error: function(error) {
      // Handle error
          console.error("Got an error in LimoRequest afterSave " + error.code + " : " + error.message)
    }
  })
}


Parse.Cloud.afterSave("LimoRequest", function(request) {
  Parse.Cloud.useMasterKey();

  // Give all provider write permission to this record
  // Only send push notifications for new requests
    // if (request.object.existed()) {
    //   return;
    // }


  //  // Only add ACL permissions for new requests
  // if (!request.object.existed()) {
  //   var groupACL = new Parse.ACL();
  //   groupACL.setPublicReadAccess(true);
  //   groupACL.setWriteAccess(request.object.get("owner"));
  //   var providerUserQuery = new Parse.Query(Parse.User);
  //   providerUserQuery.equalTo("role", "provider");

  //   providerUserQuery.find({
  //     success: function(userList) {
  //       // got all the provider users
  //       console.log(userList);
  //       console.log("There are some providers ..." + userList);
  //       console.log(userList.length);
  //       // userList is an array with the users who are providers
  //       for (var i = 0; i < userList.length; i++) {
  //         groupACL.setWriteAccess(userList[i], true);
  //       }
  //     },
  //     error: function(error) {
  //       // error is an instance of Parse.Error.
  //     }
  //   });
  //   request.object.setACL(groupACL);
  //   request.object.save();
  // }

  var status = request.object.get("status")
  if (status == "New") {
    console.log("new request " + request.object.id)
    var installationQuery = new Parse.Query(Parse.Installation)
    var userQuery = new Parse.Query(Parse.User)
    userQuery.equalTo("role", "provider")
    installationQuery.matchesQuery("user", userQuery)

    // var status = request.object.get("status")
    var whenString = request.object.get("whenString")
    // var when = request.object.get("when")
    var fromAddress = request.object.get("fromAddress")
    var toAddress = request.object.get("toAddress")

    // console.log("Status is " + status)
    // console.log("When is " + when)
    // console.log("When String is " + whenString)
    // console.log("From  is " + fromAddress)

    // var channel = "C" + request.object.id
    // console.log (channel)
    sendPush(installationQuery, " From: " + fromAddress  + " At: " + whenString + " To: " + toAddress, request.object.id)
  // })

 } else {
    console.log("updating an existing request" + request.object.id)
    var installationQuery = new Parse.Query(Parse.Installation);
    var userQuery = new Parse.Query(Parse.User);
    var owner = new Parse.User();
    var message
    owner = request.object.get("owner");
    var assignedTo = new Parse.User();
    if (request.object.has("assignedTo")) {
      assignedTo = request.object.get("assignedTo");
      console.log(assignedTo)
      var assignedToQuery = new Parse.Query(Parse.User)
      assignedToQuery.get(assignedTo.id,{
        success: function(assignedToUser) {
          userQuery.containedIn("objectId", [owner.id, assignedTo.id]);
          userQuery.notContainedIn("objectId", [request.user.id])
          installationQuery.matchesQuery("user", userQuery);
          if (status === "Accepted") {
            message = " Request Accepted By " + assignedToUser.get("username") + " has been updated! "
          } else {
            message = " Request has been updated! "
          }
          sendPush(installationQuery, message , request.object.id);
        },
        error: function(assignedToUser, error) {
          console.log (error)
        }
      });
      // var users = [owner, assignedTo];
    }  else {
      userQuery.containedIn("objectId", [owner.id]);
      userQuery.notContainedIn("objectId", [request.user.id])
      installationQuery.matchesQuery("user", userQuery);
      if (status === "Accepted") {
        message = " Request Accepted By " + assignedToUser.get("username") + " has been updated! "
      } else {
        message = " Request has been updated! "
      }
      sendPush(installationQuery, message , request.object.id);
    }
 }
});

