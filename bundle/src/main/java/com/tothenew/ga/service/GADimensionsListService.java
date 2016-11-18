/*
 * 
 */
package com.tothenew.ga.service;

import java.util.List;
import java.util.Map;

import org.apache.sling.api.resource.ResourceResolver;

import com.google.api.services.analytics.Analytics;

public interface GADimensionsListService {

	Analytics getInitializedAnalytics(String resourcePath, ResourceResolver resourceResolver);

	List<Map<String, String>> getCustomDimensionList(final Analytics analytics);

	List<Map<String, String>> getPredefinedDimensionList(final Analytics analytics);

	List<Map<String, String>> gethitType();

	List<Map<String, String>> getAllDimensions(final Analytics analytics);

	Boolean verifyAccountDetail(String accountDetailPath, ResourceResolver resourceResolver);
}
