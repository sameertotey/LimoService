

Parse.Cloud.afterSave("LimoRequest", function(request) {
  Parse.Cloud.useMasterKey();
  var LimoUser = Parse.Object.extend("LimoUser")
  var installationQuery = new Parse.Query(Parse.Installation)
  var limoUserQuery = new Parse.Query(LimoUser)
  limoUserQuery.equalTo("role", "provider")
  installationQuery.matchesQuery("limouser", limoUserQuery)
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
  var fromString = request.object.get("fromString")
  var toString = request.object.get("toString")


  console.log("Status is " + status)
  console.log("When is " + when)
  console.log("When String is " + whenString)
  console.log("From  is " + fromString)

  var channel = "C" + request.object.id
  console.log (channel)
  if (status === "New") {
     Parse.Push.send({
      where: installationQuery,
      data: {
      alert:  channel + " From: " + fromString + " To: " + toString + " At: " + whenString
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

