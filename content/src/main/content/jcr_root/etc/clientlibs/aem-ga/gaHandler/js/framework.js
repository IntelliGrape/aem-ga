var gaHandler = gaHandler
		|| {
			mappingPath : '',
			record : function(jsonObject, resourcePath) {
				if (resourcePath) {
					resourcePath = this.mappingPath + "/jcr:content/mappings/"
							+ resourcePath.replace(/\//g, '_');
					var data = {};
					$.ajax({
						url : "/bin/getMappedNode",
						data : {
							mappingNodePath : resourcePath
						},
						success : function(result, status) {
							data = gaHandler.getMappedData(result,
									jsonObject.values, data);
							$.each(jsonObject.event, function(index, value) {
								$.each(result, function(i, v) {
									if (value === v) {
										data['hitType'] = i;
										console.log(data);
										ga('send', data);
									}
								});
							});
						},
						error : function(xhr, status, error) {
							console.error('Resource does not exist.');
						}
					});
				} else {
					console.error('Missing resource path');
				}

			},

			getMappedData : function(response, jsonObjectValues, data) {
				var keys = [];
				$.each(jsonObjectValues, function(key, value) {
					// Get ga dimension which is mapped with this key
					$.each(response, function(k, v) {
						if (v === key) {
							k = k.replace('ga:', '');
							data[k] = value;
						}
					});
				});
				return data;
			},
			gaScript : function(trackingID) {
				(function(i, s, o, g, r, a, m) {
					i['GoogleAnalyticsObject'] = r;
					i[r] = i[r] || function() {
						(i[r].q = i[r].q || []).push(arguments)
					}, i[r].l = 1 * new Date();
					a = s.createElement(o), m = s.getElementsByTagName(o)[0];
					a.async = 1;
					a.src = g;
					m.parentNode.insertBefore(a, m)
				})(window, document, 'script',
						'//www.google-analytics.com/analytics.js', 'ga');

				ga('create', trackingID, 'auto');
				ga('send', 'pageview');
			}

		};
