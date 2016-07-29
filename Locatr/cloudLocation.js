window.addEventListener('cloudkitloaded', function() {
	CloudKit.configure({
		containers: [{
			containerIdentifier: 'iCloud.com.brianAdvent.Locatr',
			apiToken: 'YOUR_KEY',
			environment: 'development'
		}]
	});

	function LocatrViewModel() {
		var self = this;
		var container = CloudKit.getDefaultContainer();
		var publicDB = container.publicCloudDatabase;

		self.locations = ko.observableArray();

		self.newLocationTitle = ko.observable('');

		self.fetchRecords = function() {
			var query = { recordType: 'Position' };

			// Execute the query.
			return publicDB.performQuery(query).then(function (response) {
				if(response.hasErrors) {
					console.error(response.errors[0]);
					return;
				}
				var records = response.records;
				var numberOfRecords = records.length;
				if (numberOfRecords === 0) {
					console.error('No matching items');
					return;
				}

				self.locations(records);
			});
			
		};

	self.initMap = function (location) {
      	  var myLatLng = {lat: location.fields.sharedLocation.value.latitude, lng: location.fields.sharedLocation.value.longitude};

        var map = new google.maps.Map(document.getElementById('map'), {
          zoom: 4,
          center: myLatLng
        });

        var marker = new google.maps.Marker({
          position: myLatLng,
          map: map,
          title: 'Map'
        });
      }


		container.setUpAuth().then(function(userInfo) {
			self.fetchRecords();  // Records are public
		});

	}

	ko.applyBindings(new LocatrViewModel());

});