/*
 * 
 */
package com.tothenew.ga.service.impl;

import java.io.IOException;
import java.io.InputStream;
import java.security.GeneralSecurityException;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.jcr.Node;
import javax.jcr.PathNotFoundException;
import javax.jcr.RepositoryException;
import javax.jcr.ValueFormatException;

import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Service;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ResourceResolver;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.day.cq.commons.inherit.HierarchyNodeInheritanceValueMap;
import com.day.cq.commons.inherit.InheritanceValueMap;
import com.day.cq.wcm.api.Page;
import com.day.cq.wcm.api.PageManager;
import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.googleapis.json.GoogleJsonResponseException;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.analytics.Analytics;
import com.google.api.services.analytics.AnalyticsScopes;
import com.google.api.services.analytics.model.Column;
import com.google.api.services.analytics.model.CustomDimension;
import com.tothenew.ga.constant.Constant;
import com.tothenew.ga.service.GADimensionsListService;

@Component(immediate = true, metatype = true, label = "Get all dimensions from google analytics", enabled = true, name = "GADimensionsList")
@Service(value = GADimensionsListService.class)
public class GADimensionsListServiceImpl implements GADimensionsListService {

	private String appName = null;
	private String filePath = null;
	private String keyProvider = null;
	private String keyStoreType = null;
	private String filePassword = null;
	private String keyAliasName = null;
	private String gaAccountId = null;
	private String gaWebPropertyId = null;
	private GsonFactory JSON_FACTORY = GsonFactory.getDefaultInstance();
	private String serviceAccountEmail = null;
	private final Logger LOGGER = LoggerFactory.getLogger(this.getClass());
	ResourceResolver resourceResolver = null;
	String[] hitType = new String[] { "pageview", "screenview", "event", "transaction", "item", "social", "exception",
			"timing" };
	PageManager pageManager = null;

	/**
	 * Get Analytics object and return it.
	 * 
	 * @return {Analytics}
	 */
	public Analytics getInitializedAnalytics(final String resourcePath, ResourceResolver resourceResolver) {
		Analytics analytics = null;
		try {
			if (resourcePath.startsWith(Constant.PROP_CLOUD_SERVICE_CONFIG_PATH)) {
				InheritanceValueMap parentPageProperties = null;
				pageManager = resourceResolver.adaptTo(PageManager.class);
				final Page mappingPage = pageManager.getContainingPage(resourcePath);
				if (mappingPage != null) {
					parentPageProperties = new HierarchyNodeInheritanceValueMap(mappingPage.getContentResource());
					appName = parentPageProperties.getInherited("applicationName", "");
					serviceAccountEmail = parentPageProperties.getInherited("serviceAccountEmail", "");
					keyProvider = parentPageProperties.getInherited("keyProvider", "");
					keyStoreType = parentPageProperties.getInherited("keystoreType", "");
					filePassword = parentPageProperties.getInherited("password", "");
					keyAliasName = parentPageProperties.getInherited("keyAliasName", "");
					gaAccountId = parentPageProperties.getInherited("accountID", "");
					gaWebPropertyId = parentPageProperties.getInherited("trackingCode", "");
					filePath = mappingPage.getPath() + "/jcr:content/filePath/jcr:content";
					Resource fileResource = resourceResolver.getResource(filePath);
					if (fileResource == null) {
						filePath = mappingPage.getParent().getPath() + "/jcr:content/filePath/jcr:content";
						fileResource = resourceResolver.getResource(filePath);
					}
					final Node node = fileResource.adaptTo(Node.class);
					final InputStream is = node.getProperty("jcr:data").getBinary().getStream();
					final HttpTransport httpTransport = GoogleNetHttpTransport.newTrustedTransport();
					final KeyStore keyStore = KeyStore.getInstance(keyStoreType, keyProvider);
					keyStore.load(is, filePassword.toCharArray());
					final PrivateKey serviceAccountPrivateKey = (PrivateKey) keyStore.getKey(keyAliasName,
							filePassword.toCharArray());
					final GoogleCredential credential = new GoogleCredential.Builder().setTransport(httpTransport)
							.setJsonFactory(JSON_FACTORY).setServiceAccountId(serviceAccountEmail)
							.setServiceAccountPrivateKey(serviceAccountPrivateKey)
							.setServiceAccountScopes(AnalyticsScopes.all()).build();
					analytics = new Analytics.Builder(httpTransport, JSON_FACTORY, credential)
							.setApplicationName(appName).build();
					resourceResolver.close();
				}
			}
		} catch (final IOException ioe) {
			LOGGER.error("IOException", ioe);
		} catch (final GeneralSecurityException e) {
			LOGGER.error("GeneralSecurityException", e);
		} catch (final ValueFormatException e) {
			LOGGER.error("ValueFormatException", e);
		} catch (final PathNotFoundException e) {
			LOGGER.error("PathNotFoundException", e);
		} catch (final RepositoryException e) {
			LOGGER.error("RepositoryException", e);
		} catch (final Exception e) {
			LOGGER.error("unknown exception", e);
		}
		return analytics;
	}

	/**
	 * Return all custom dimensions of a google analytics account.
	 * 
	 * @return List<CustomDimension>
	 */
	public List<Map<String, String>> getCustomDimensionList(final Analytics analytics) {
		List<CustomDimension> customDimensionsList = new ArrayList<CustomDimension>();
		Map<String, String> map = null;
		List<Map<String, String>> dimensions = new ArrayList<Map<String, String>>();
		try {
			// Get custom dimensions list
			com.google.api.services.analytics.Analytics.Management.CustomDimensions.List customDimensions = analytics
					.management().customDimensions().list(gaAccountId, gaWebPropertyId);
			customDimensions = customDimensions.setFields("items(id,active,name)");
			customDimensionsList = customDimensions.execute().getItems();
			final Iterator<CustomDimension> itr = customDimensionsList.iterator();
			while (itr.hasNext()) {
				final CustomDimension col = itr.next();
				final boolean isActive = (Boolean) col.get("active");
				if (!isActive) {
					itr.remove();
				} else {
					map = new HashMap<String, String>();
					map.put("id", col.getId());
					map.put("name", (String) col.get("name"));
					dimensions.add(map);
				}
			}
		} catch (final GoogleJsonResponseException e) {
			LOGGER.error("GoogleJsonResponseException", e);
		} catch (final IOException e) {
			LOGGER.error("IOException", e);
		}
		return dimensions;
	}

	/**
	 * Return all predefined dimensions of google analytics.
	 * 
	 * @param {@Analytics}
	 * @return List<Column>
	 */
	public List<Map<String, String>> getPredefinedDimensionList(final Analytics analytics) {
		// Get predefined GA dimensions list
		List<Column> columnList = new ArrayList<Column>();
		Map<String, String> map = null;
		List<Map<String, String>> preDefinedDimensionsList = new ArrayList<Map<String, String>>();
		try {
			final com.google.api.services.analytics.Analytics.Metadata.Columns.List preDefinedDimensions = analytics
					.metadata().columns().list("ga");
			columnList = preDefinedDimensions.execute().getItems();
			final Iterator<Column> itr = columnList.iterator();
			while (itr.hasNext()) {
				final Column col = itr.next();
				final Map<String, String> attributes = col.getAttributes();
				final String type = attributes.get("type");
				final String status = attributes.get("status");
				if ("METRIC".equalsIgnoreCase(type) || "DEPRECATED".equalsIgnoreCase(status)) {
					itr.remove();
				} else {
					map = new HashMap<String, String>();
					map.put("id", col.getId());
					map.put("name", attributes.get("uiName"));
					preDefinedDimensionsList.add(map);
				}
			}
		} catch (final IOException e) {
			LOGGER.error("IOException", e);
		}
		return preDefinedDimensionsList;
	}

	/**
	 * Return all dimensions(custom and predefined in a map)
	 * 
	 * @return Map
	 */
	public List<Map<String, String>> getAllDimensions(final Analytics analytics) {
		List<Map<String, String>> allDimensionList = new ArrayList<Map<String, String>>();
		allDimensionList.addAll(getCustomDimensionList(analytics));
		allDimensionList.addAll(getPredefinedDimensionList(analytics));
		return allDimensionList;
	}

	/**
	 * Return all hit type available for Google analytics.
	 * 
	 * @return {@link List}
	 */
	public List<Map<String, String>> gethitType() {
		Map<String, String> map = null;
		List<Map<String, String>> hitList = new ArrayList<Map<String, String>>();
		for (String hit : hitType) {
			map = new HashMap<String, String>();
			map.put("id", hit);
			map.put("name", hit);
			hitList.add(map);
		}
		return hitList;
	}

	public Boolean verifyAccountDetail(String accountDetailPath, ResourceResolver resourceResolver) {
		Boolean isCorrectAccountDetail = Boolean.FALSE;
		Analytics analytics = getInitializedAnalytics(accountDetailPath, resourceResolver);
		if (analytics != null) {
			com.google.api.services.analytics.model.Accounts accounts;
			try {
				accounts = analytics.management().accounts().list().execute();
				isCorrectAccountDetail = !accounts.getItems().isEmpty();
			} catch (IOException ioe) {
				LOGGER.error("IOException", ioe);
			} catch (Exception e) {
				LOGGER.error("general exception", e);
			}
		}
		return isCorrectAccountDetail;
	}
}
