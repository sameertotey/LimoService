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

  if (request.object.get("status") == "New") {
    var installationQuery = new Parse.Query(Parse.Installation)
    var userQuery = new Parse.Query(Parse.User)
    userQuery.equalTo("role", "provider")
    installationQuery.matchesQuery("user", userQuery)
    installationQuery.find({
      success: function(installations) {
        // got all the installations
        console.log(installations)
        console.log("There are some installations..." + installations)
        console.log(installations.length)
      },
      error: function(error) {
        // error is an instance of Parse.Error.
      }
    })
    var status = request.object.get("status")
    var whenString = request.object.get("whenString")
    var when = request.object.get("when")
    var fromAddress = request.object.get("fromAddress")
    var toAddress = request.object.get("toAddress")

    console.log("Status is " + status)
    console.log("When is " + when)
    console.log("When String is " + whenString)
    console.log("From  is " + fromAddress)

    var channel = "C" + request.object.id
    console.log (channel)
    Parse.Push.send({
      where: installationQuery,
      data: {
        alert:  " From: " + fromAddress  + " At: " + whenString + " To: " + toAddress,
        limoreq: request.object.id
        }
      }, {
        success: function() {
        // Push was successful
        },
        error: function(error) {
        // Handle error
          console.error("Got an error in LimoRequest afterSave " + error.code + " : " + error.message)
      }
    })

 } else {
    console.log("updating an existing request")
    var installationQuery = new Parse.Query(Parse.Installation);
    var userQuery = new Parse.Query(Parse.User);
    var owner = new Parse.User();
    owner = request.object.get("owner");
    var assignedTo = new Parse.User();
    assignedTo = request.object.get("assignedTo");
    var users = [owner, assignedTo];
    userQuery.containedIn("objectId", [owner.id, assignedTo.id]);
    installationQuery.matchesQuery("user", userQuery);
    installationQuery.find({
      success: function(installations) {
        // got all the installations
        console.log(installations)
        console.log("There are some installations for existing requests..." + installations)
        console.log(installations.length)
      },
      error: function(error) {
        // error is an instance of Parse.Error.
        console.error("Got an error in LimoRequest afterSave " + error.code + " : " + error.message)
      }
    })
    var status = request.object.get("status")
    var whenString = request.object.get("whenString")
    var when = request.object.get("when")
    var fromAddress = request.object.get("fromAddress")
    var toAddress = request.object.get("toAddress")
    console.log("Status is " + status)

    var channel = "C" + request.object.id
    console.log (channel)
    if (status === "Accepted") {
       Parse.Push.send({
        where: installationQuery,
        data: {
        alert:  " Request has been Accepted! by " + assignedTo.id,
        limoreq: request.object.id
        }
      }, {
        success: function() {
          // Push was successful
        },
        error: function(error) {
          // Handle error
              console.error("Got an error in LimoRequest afterSave " + error.code + " : " + error.message)
        }
      })
    }
 }


});

