<%--
/**
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *        http://www.apache.org/licenses/LICENSE-2.0
 *        
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
--%>

<%@ include file="/html/portlet/login/init.jsp" %>

<c:choose>
	<c:when test="<%= themeDisplay.isSignedIn() %>">

		<%
		String signedInAs = HtmlUtil.escape(user.getFullName());

		if (themeDisplay.isShowMyAccountIcon() && (themeDisplay.getURLMyAccount() != null)) {
			String myAccountURL = String.valueOf(themeDisplay.getURLMyAccount());

			if (PropsValues.DOCKBAR_ADMINISTRATIVE_LINKS_SHOW_IN_POP_UP) {
				signedInAs = "<a class=\"signed-in\" href=\"javascript:Liferay.Util.openWindow({dialog: {destroyOnHide: true}, title: '" + LanguageUtil.get(pageContext, "my-account") + "', uri: '" + HtmlUtil.escape(myAccountURL) + "'});\">" + signedInAs + "</a>";
			}
			else {
				myAccountURL = HttpUtil.setParameter(myAccountURL, "controlPanelCategory", PortletCategoryKeys.MY);

				signedInAs = "<a class=\"signed-in\" href=\"" + HtmlUtil.escape(myAccountURL) + "\">" + signedInAs + "</a>";
			}
		}
		%>
		<div class="you-are-signed-in-as-x-message">
			<%= LanguageUtil.format(pageContext, "you-are-signed-in-as-x", signedInAs, false) %>
		</div>
	</c:when>
	<c:otherwise>

		<%
		String redirect = ParamUtil.getString(request, "redirect");

		String login = LoginUtil.getLogin(request, "login", company);
		String password = StringPool.BLANK;
		boolean rememberMe = ParamUtil.getBoolean(request, "rememberMe");

		if (Validator.isNull(authType)) {
			authType = company.getAuthType();
		}
		%>

		<portlet:actionURL secure="<%= PropsValues.COMPANY_SECURITY_AUTH_REQUIRES_HTTPS || request.isSecure() %>" var="loginURL">
			<portlet:param name="struts_action" value="/login/login" />
		</portlet:actionURL>


		<div class="login-content">
			<aui:form action="<%= loginURL %>" autocomplete='<%= PropsValues.COMPANY_SECURITY_LOGIN_FORM_AUTOCOMPLETE ? "on" : "off" %>' cssClass="sign-in-form" method="post" name="fm">
				<aui:input name="saveLastPath" type="hidden" value="<%= false %>" />
				<aui:input name="redirect" type="hidden" value="<%= redirect %>" />
				<aui:input name="doActionAfterLogin" type="hidden" value="<%= portletName.equals(PortletKeys.FAST_LOGIN) ? true : false %>" />
		
				<%	
				redirect = PortletURLUtil.getCurrent(renderRequest, renderResponse).toString();
				%>
				
				<c:choose>
					<c:when test='<%= SessionMessages.contains(request, "userAdded") %>'>
	
						<%
						String userEmailAddress = (String)SessionMessages.get(request, "userAdded");
						String userPassword = (String)SessionMessages.get(request, "userAddedPassword");
						%>
	
						<div class="alert alert-success">
							<c:choose>
								<c:when test="<%= company.isStrangersVerify() || Validator.isNull(userPassword) %>">
									<%= LanguageUtil.get(pageContext, "thank-you-for-creating-an-account") %>
	
									<c:if test="<%= company.isStrangersVerify() %>">
										<%= LanguageUtil.format(pageContext, "your-email-verification-code-has-been-sent-to-x", userEmailAddress) %>
									</c:if>
								</c:when>
								<c:otherwise>
<%-- 									<%= Poliaktiv change: removed LanguageUtil.format(pageContext, "thank-you-for-creating-an-account.-your-password-is-x", userPassword, false) %> --%>
								</c:otherwise>
							</c:choose>
	
							<c:if test="<%= PrefsPropsUtil.getBoolean(company.getCompanyId(), PropsKeys.ADMIN_EMAIL_USER_ADDED_ENABLED) %>">
<%-- 							Politaktiv change: replaced <%= LanguageUtil.format(pageContext, "your-password-has-been-sent-to-x", userEmailAddress) %> --%>
								<%= LanguageUtil.format(pageContext, "thank-you-for-creating-an-account-your-password-has-been-sent-to-x", userEmailAddress) %>
							</c:if>
						</div>
					</c:when>
					<c:when test='<%= SessionMessages.contains(request, "userPending") %>'>
	
						<%
						String userEmailAddress = (String)SessionMessages.get(request, "userPending");
						%>
	
						<div class="alert alert-success">
							<%= LanguageUtil.format(pageContext, "thank-you-for-creating-an-account.-you-will-be-notified-via-email-at-x-when-your-account-has-been-approved", userEmailAddress) %>
						</div>
					</c:when>
				</c:choose>
	
				<liferay-ui:error exception="<%= AuthException.class %>" message="authentication-failed" />
				<liferay-ui:error exception="<%= CompanyMaxUsersException.class %>" message="unable-to-login-because-the-maximum-number-of-users-has-been-reached" />
				<liferay-ui:error exception="<%= CookieNotSupportedException.class %>" message="authentication-failed-please-enable-browser-cookies" />
				<liferay-ui:error exception="<%= NoSuchUserException.class %>" message="authentication-failed" />
				<liferay-ui:error exception="<%= PasswordExpiredException.class %>" message="your-password-has-expired" />
				<liferay-ui:error exception="<%= UserEmailAddressException.class %>" message="authentication-failed" />
				<liferay-ui:error exception="<%= UserLockoutException.class %>" message="this-account-has-been-locked" />
				<liferay-ui:error exception="<%= UserPasswordException.class %>" message="authentication-failed" />
				<liferay-ui:error exception="<%= UserScreenNameException.class %>" message="authentication-failed" />
	
				<aui:fieldset>
	
					<%
					String loginLabel = null;
	
					if (authType.equals(CompanyConstants.AUTH_TYPE_EA)) {
						loginLabel = "email-address";
					}
					else if (authType.equals(CompanyConstants.AUTH_TYPE_SN)) {
						loginLabel = "screen-name";
					}
					else if (authType.equals(CompanyConstants.AUTH_TYPE_ID)) {
						loginLabel = "id";
					}
					%>
					
<!-- 			Politaktiv change: welcome message with register link -->
				<div class="politaktiv-hook-login-welcome">
					<h1> <liferay-ui:message key="welcome-to-login" /></h1>
				</div>
				<div class="politaktiv-hook-login-if-first-visit">
				<!-- <liferay-ui:message key="if-this-is-your-first-visit-please-register-first-by" /> -->
					<a href="<%= PortalUtil.getCreateAccountURL(request, themeDisplay) %>">
						<liferay-ui:message key="creating-an-account" />
					</a>
				</div>
	
	
					<aui:input autoFocus="<%= windowState.equals(LiferayWindowState.EXCLUSIVE) || windowState.equals(WindowState.MAXIMIZED) %>" cssClass="clearable" label="<%= loginLabel %>" name="login" showRequiredLabel="<%= false %>" type="text" value="<%= login %>">
						<aui:validator name="required" />
					</aui:input>
	
					<aui:input name="password" showRequiredLabel="<%= false %>" type="password" value="<%= password %>">
						<aui:validator name="required" />
					</aui:input>
	
					<span id="<portlet:namespace />passwordCapsLockSpan" style="display: none;"><liferay-ui:message key="caps-lock-is-on" /></span>
	
					<c:if test="<%= company.isAutoLogin() && !PropsValues.SESSION_DISABLED %>">
						<div class="politaktiv-hook-login-remember-checkbox">
							<aui:input checked="<%= rememberMe %>" name="rememberMe" type="checkbox" />
						</div>
					</c:if>
				</aui:fieldset>
	
				<aui:button-row>
					<aui:button type="submit" value="sign-in" />
				</aui:button-row>
			</aui:form>
		</div>

		<div class="login-description-article">
			<liferay-ui:journal-article showTitle="false" groupId="10165" articleId="LOGIN_DESCRIPTION"/>
		</div>

		<div class="login-navigation">
			<liferay-util:include page="/html/portlet/login/navigation.jsp" />
		</div>

		<aui:script use="aui-base">
			var password = A.one('#<portlet:namespace />password');

			if (password) {
				password.on(
					'keypress',
					function(event) {
						Liferay.Util.showCapsLock(event, '<portlet:namespace />passwordCapsLockSpan');
					}
				);
			}
		</aui:script>
	</c:otherwise>
</c:choose>