
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

// Make sure all installations point to the current user.
Parse.Cloud.beforeSave(Parse.Installation, function(request, response) {
  Parse.Cloud.useMasterKey();
  if (request.user) {
    console.log("setting the user for installation ---")
    request.object.set('user', request.user);
  } else {
    request.object.unset('user');
  }
  response.success();
});

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
  console.log("Status is " + status)
  var channel = "C" + request.object.id
  console.log (channel)
  Parse.Push.send({
    where: installationQuery,
    data: {
      alert: "The Giants won against " + channel + " the Mets 2-3."
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
});

