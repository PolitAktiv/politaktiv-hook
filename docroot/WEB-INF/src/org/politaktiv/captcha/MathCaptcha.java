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

package org.politaktiv.captcha;

import com.liferay.portal.kernel.captcha.Captcha;
import com.liferay.portal.kernel.captcha.CaptchaException;
import com.liferay.portal.kernel.captcha.CaptchaMaxChallengesException;
import com.liferay.portal.kernel.captcha.CaptchaTextException;
import com.liferay.portal.kernel.util.ContentTypes;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.util.PortalUtil;

import com.liferay.portal.kernel.util.PropsUtil;
import com.liferay.portal.kernel.util.PropsKeys;

import java.io.IOException;

import javax.portlet.PortletRequest;
import javax.portlet.PortletResponse;
import javax.portlet.PortletSession;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.util.ArrayList;
import java.util.Random;

import org.politaktiv.captcha.MathCaptchaFormula;


public class MathCaptcha implements Captcha {
		
	private static final String _TAGLIB_PATH 			= "/html/taglib/ui/captcha/mathcaptcha.jsp";	
	public  static final String CAPTCHA_COUNT 			= "CAPTCHA_COUNT";
	public  static final String CAPTCHA_TEXT 			= "CAPTCHA_TEXT"; 
	public  static final int 	CAPTCHA_MAX_CHALLENGES 	= GetterUtil.getInteger(PropsUtil.get(PropsKeys.CAPTCHA_MAX_CHALLENGES));	
		
	
	private ArrayList<Class> aFormulaClasses;
	
	public MathCaptcha() {
		aFormulaClasses = new ArrayList<Class>();
		this.registerFormulaClass(FormulaMul2AndAddOne.class.getName());
		this.registerFormulaClass(FormulaAdd2AndMulOne.class.getName());
	}
	
	public boolean registerFormulaClass(String sClass) {
		Class oFormulaClass = null;
		try {
			oFormulaClass = Class.forName(sClass);
		} catch(ClassNotFoundException oEx) {
			
		}
		if(oFormulaClass == null)
			return false;
		if(!this.aFormulaClasses.contains(oFormulaClass))
			this.aFormulaClasses.add(oFormulaClass);
		return true;
	}
	
	protected MathCaptchaFormula createRandomFormulaObj() {
		int uCount = this.aFormulaClasses.size();
		
		Class oFormulaClass = null;
		
		MathCaptchaFormula oFormula = null;
		
		if(uCount == 1)
			oFormulaClass = this.aFormulaClasses.get(0);
		else if(uCount > 1)
			oFormulaClass = this.aFormulaClasses.get(this.GetRandomUnsignedInt(0,uCount-1));
		
		if(oFormulaClass != null) {
			try {
				oFormula = (MathCaptchaFormula)oFormulaClass.newInstance();
				oFormula.initFormulaVars();
			} catch(Exception oEx) {	
			}
		}	
		
		return oFormula;
	}
	
	public void check(HttpServletRequest request) throws CaptchaException {
		if (!isEnabled(request)) {
			return;
		}

		HttpSession session = request.getSession();

		String captchaText = (String)session.getAttribute(CAPTCHA_TEXT);

		if (captchaText == null) {
			/*
			_log.error(
				"Captcha text is null. User " + request.getRemoteUser() +
					" may be trying to circumvent the captcha.");
			*/

			throw new CaptchaTextException();
		}

		if (!captchaText.equals(ParamUtil.getString(request, "captchaText"))) {
			if ((CAPTCHA_MAX_CHALLENGES > 0) &&
				(Validator.isNotNull(request.getRemoteUser()))) {

				Integer count = (Integer)session.getAttribute(CAPTCHA_COUNT);

				if (count == null) {
					count = new Integer(1);
				}
				else {
					count = new Integer(count.intValue() + 1);
				}

				session.setAttribute(CAPTCHA_COUNT, count);
			}

			throw new CaptchaTextException();
		}

		/*
		if (_log.isDebugEnabled()) {
			_log.debug("Captcha text is valid");
		}
		*/

		session.removeAttribute(CAPTCHA_TEXT);
	}

	public void check(PortletRequest portletRequest) throws CaptchaException {
		if (!isEnabled(portletRequest)) {
			return;
		}

		PortletSession portletSession = portletRequest.getPortletSession();

		String captchaText = (String)portletSession.getAttribute(CAPTCHA_TEXT);

		if (captchaText == null) {
			/*
			_log.error(
				"Captcha text is null. User " + portletRequest.getRemoteUser() +
					" may be trying to circumvent the captcha.");
			*/	
			throw new CaptchaTextException();
		}

		if (!captchaText.equals(
				ParamUtil.getString(portletRequest, "captchaText"))) {

			if ((CAPTCHA_MAX_CHALLENGES > 0) &&
				(Validator.isNotNull(portletRequest.getRemoteUser()))) {

				Integer count = (Integer)portletSession.getAttribute(CAPTCHA_COUNT);

				if (count == null) {
					count = new Integer(1);
				}
				else {
					count = new Integer(count.intValue() + 1);
				}

				portletSession.setAttribute(CAPTCHA_COUNT, count);
			}

			throw new CaptchaTextException();
		}

		/*
		if (_log.isDebugEnabled()) {
			_log.debug("Captcha text is valid");
		}
		*/

		portletSession.removeAttribute(CAPTCHA_TEXT);
	}

	public String getTaglibPath() {
		//throw new NullPointerException("getTaglibPath");
		return _TAGLIB_PATH;
	}

	public boolean isEnabled(HttpServletRequest request)
		throws CaptchaException {

		if (CAPTCHA_MAX_CHALLENGES > 0) {
			HttpSession session = request.getSession();

			Integer count = (Integer)session.getAttribute(CAPTCHA_COUNT);

			if (count != null && count >= CAPTCHA_MAX_CHALLENGES) {
				throw new CaptchaMaxChallengesException();
			}

			if ((count != null) &&
				(CAPTCHA_MAX_CHALLENGES <= count.intValue())) {

				return false;
			}
			else {
				return true;
			}
		}
		else if (CAPTCHA_MAX_CHALLENGES < 0) {
			return false;
		}
		else {
			return true;
		}
	}

	public boolean isEnabled(PortletRequest portletRequest)
		throws CaptchaException {

		if (CAPTCHA_MAX_CHALLENGES > 0) {
			PortletSession portletSession = portletRequest.getPortletSession();

			Integer count = (Integer)portletSession.getAttribute(CAPTCHA_COUNT);

			if (count != null && count >= CAPTCHA_MAX_CHALLENGES) {
				throw new CaptchaMaxChallengesException();
			}

			if ((count != null) &&
				(CAPTCHA_MAX_CHALLENGES <= count.intValue())) {

				return false;
			}
			else {
				return true;
			}
		}
		else if (CAPTCHA_MAX_CHALLENGES < 0) {
			return false;
		}
		else {
			return true;
		}
	}

	private String buildIFrameContent(String sQuestion) {	
		String sDoc = "";
		sDoc += "<!DOCTYPE html>\r\n";
		sDoc += "<html>\r\n";
		sDoc += "<head></head>\r\n";
		sDoc += "<body>\r\n";
		sDoc += "<div class=\"matchcaptcha-question\">";
		sDoc += sQuestion;
		sDoc += "</div>\r\n";
		sDoc += "</body>\r\n";
		sDoc += "</html>"; 
	
		return sDoc;
	}

	public void serveImage(HttpServletRequest request, HttpServletResponse response) throws IOException {		
		MathCaptchaFormula oFormula = this.createRandomFormulaObj();
		String sQ = oFormula.getQuestion();
		String sR = String.valueOf(oFormula.calculateResult());
		
		HttpSession oSession = request.getSession();
		oSession.setAttribute(CAPTCHA_TEXT,sR);
		
		response.setContentType(ContentTypes.TEXT_HTML);
		response.getOutputStream().print(this.buildIFrameContent(sQ));
	}

	public void serveImage(PortletRequest portletRequest, PortletResponse portletResponse) throws IOException {
		MathCaptchaFormula oFormula = this.createRandomFormulaObj();
		String sQ = oFormula.getQuestion();
		String sR = String.valueOf(oFormula.calculateResult());
		
		PortletSession oSession = portletRequest.getPortletSession();
		oSession.setAttribute(CAPTCHA_TEXT,sR);

		HttpServletResponse oResponse = PortalUtil.getHttpServletResponse(
				portletResponse);		
		
		oResponse.setContentType(ContentTypes.TEXT_HTML);
		oResponse.getOutputStream().print(this.buildIFrameContent(sQ));		
	}
	
	public static int GetRandomUnsignedInt(int uMin, int uMax) {
		if(uMin < 0)
			uMin = 0;
		if(uMax < 0)
			uMax = 0;
		int iDiff = uMax - uMin;
		if(iDiff <= 0) {
			uMax = uMin+1;
			iDiff = 1;
		}
		Random oRand = new Random();
		return uMin + oRand.nextInt(iDiff+1);
	}	
	
}