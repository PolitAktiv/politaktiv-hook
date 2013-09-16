<%
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
%>

<%@ include file="/html/taglib/ui/captcha/init.jsp" %>

<%
String url = (String)request.getAttribute("liferay-ui:captcha:url");

boolean captchaEnabled = false;

try {
	if (portletRequest != null) {
		captchaEnabled = CaptchaUtil.isEnabled(portletRequest);
	}
	else {
		captchaEnabled = CaptchaUtil.isEnabled(request);
	}
}
catch (CaptchaMaxChallengesException cmce) {
	captchaEnabled = true;
}
%>

<c:if test="<%= captchaEnabled %>">
	<div class="taglib-captcha">
		<iframe id="mathcaptcha_result_frame" src="<%= url %>" style="visibility:hidden;" width="1" height="1" scrolling="no" frameborder="0"></iframe>
		<div id="mathcaptcha_result_panel" class="mathcaptcha-result-panel" style="font-weight:bold"></div>
		<script type="text/javascript">
			/*<![CDATA[*/
			var oMathCaptchaResultFrame = document.getElementById('mathcaptcha_result_frame');			
			var pInitMathCaptcha = function(oEvt) {
				var oMathCaptchaResultPanel = document.getElementById('mathcaptcha_result_panel');
				if(!oMathCaptchaResultPanel)
					return;
				oMathCaptchaResultPanel.innerHTML = oMathCaptchaResultFrame.contentDocument.body.innerHTML; 
			};
			if(window.attachEvent) {
				window.attachEvent("onload",pInitMathCaptcha);	
			} else if(oMathCaptchaResultFrame.contentWindow.addEventListener) {
				window.addEventListener("load",pInitMathCaptcha,false);
			}			
			/*]]>*/           
		</script>
 		<table class="lfr-table">
		<tr>
			<td>
				Ergebnis
				<!-- <liferay-ui:message key="text-verification" /> -->
			</td>
			<td>
				<input name="<%= namespace %>captchaText" size="10" type="text" value="" />
			</td>
		</tr>
		</table>
	</div>
</c:if>