

Parse.Cloud.afterSave("LimoRequest", function(request) {
  Parse.Cloud.useMasterKey();
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
  console.log("received" + " " + request.object.id)
  console.log("User is " + request.user.toJSON())
  console.log(request)
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
  if (status === "New") {
     Parse.Push.send({
      where: installationQuery,
      data: {
      alert:  " From: " + fromAddress  + " At: " + whenString + " To: " + toAddress
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
 
});

