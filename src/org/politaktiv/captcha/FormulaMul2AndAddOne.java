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

class FormulaMul2AndAddOne extends MathCaptchaFormula {
	
	private int uA = 0, uB = 0, uC = 0;
	
	public FormulaMul2AndAddOne() {}
	
	public void initFormulaVars() {
		this.uA = super.GetRandomUnsignedInt(1,10);
		this.uB = super.GetRandomUnsignedInt(1,10);
		this.uC = super.GetRandomUnsignedInt(1,10);
	}
	
	public String getQuestion() {
		String sTpl = "Multiplizieren Sie %d mit %d und addieren anschliessend %d";
		return String.format(sTpl,new Integer(this.uA),new Integer(this.uB),new Integer(this.uC));
	}
	
	public int calculateResult() {
		return (this.uA * this.uB) + this.uC;
	}
	
}