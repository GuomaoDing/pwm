<%@ page import="password.pwm.http.JspUtility" %>
<%@ page import="password.pwm.http.bean.ConfigGuideBean" %>
<%@ page import="password.pwm.http.servlet.ConfigGuideServlet" %>
<%@ page import="java.util.Map" %>
<%--
  ~ Password Management Servlets (PWM)
  ~ http://code.google.com/p/pwm/
  ~
  ~ Copyright (c) 2006-2009 Novell, Inc.
  ~ Copyright (c) 2009-2014 The PWM Project
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or
  ~ (at your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~ GNU General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  --%>

<!DOCTYPE html>

<%@ page language="java" session="true" isThreadSafe="true"
         contentType="text/html; charset=UTF-8" %>
<% ConfigGuideBean configGuideBean = (ConfigGuideBean) PwmSession.getPwmSession(session).getSessionBean(ConfigGuideBean.class);%>
<% Map<String,String> DEFAULT_FORM = ConfigGuideServlet.defaultForm(configGuideBean.getStoredConfiguration().getTemplate()); %>
<%@ taglib uri="pwm" prefix="pwm" %>
<html dir="<pwm:LocaleOrientation/>">
<%@ include file="fragment/header.jsp" %>
<body class="nihilo">
<link href="<pwm:context/><pwm:url url='/public/resources/configStyle.css'/>" rel="stylesheet" type="text/css"/>
<div id="wrapper">
    <div id="header">
        <div id="header-center">
            <div id="header-page">
                <pwm:display key="Title_ConfigGuide" bundle="Config"/>
            </div>
            <div id="header-title">
                <pwm:display key="Title_ConfigGuide_ldap" bundle="Config"/>
            </div>
        </div>
    </div>
    <div id="centerbody">
        <form id="configForm">
            <%@ include file="/WEB-INF/jsp/fragment/message.jsp" %>
            <br/>
            <div id="outline_ldap" class="setting_outline">
                <div class="setting_title">
                    LDAP Test User (Optional)
                </div>
                <div class="setting_body">
                    Enter the LDAP DN of a test user account.  You will need to create a new test user account for this purpose.  This test user account should be created with the same privileges and policies
                    as a typical user in your system.  This application will modify the password and perform other operations against the test user account to
                    validate the configuration and health of both the LDAP server and this server.
                    <br/><br/>
                    This setting is optional but recommended.  If you do not wish to configure an LDAP Test User DN at this time, you can leave this setting blank and configure a test user later.
                    <div class="setting_item">
                        <div id="titlePane_<%=ConfigGuideServlet.PARAM_LDAP2_TEST_USER%>" style="padding-left: 5px; padding-top: 5px">
                            <b>LDAP Test User DN</b>
                            <br/>
                            <span class="fa fa-chevron-circle-right"></span>
                            <input id="<%=ConfigGuideServlet.PARAM_LDAP2_TEST_USER%>" name="<%=ConfigGuideServlet.PARAM_LDAP2_TEST_USER%>" value="<%=configGuideBean.getFormData().get(ConfigGuideServlet.PARAM_LDAP2_TEST_USER)%>"/>
                            <pwm:script>
                            <script type="text/javascript">
                                PWM_GLOBAL['startupFunctions'].push(function(){
                                    require(["dijit/form/ValidationTextBox"],function(ValidationTextBox){
                                        new ValidationTextBox({
                                            name: '<%=ConfigGuideServlet.PARAM_LDAP2_TEST_USER%>',
                                            required: false,
                                            style: "width: 550px",
                                            placeholder: '<%=DEFAULT_FORM.get(ConfigGuideServlet.PARAM_LDAP2_TEST_USER)%>',
                                            value: '<%=configGuideBean.getFormData().get(ConfigGuideServlet.PARAM_LDAP2_TEST_USER)%>'
                                        }, "<%=ConfigGuideServlet.PARAM_LDAP2_TEST_USER%>");
                                    });
                                });
                            </script>
                            </pwm:script>
                        </div>
                    </div>
                </div>
            </div>
        </form>
        <br/>
        <div id="healthBody" style="border:0; margin:0; padding:0">
            <div style="text-align: center">
                <a class="menubutton" style="max-width: 100px; margin-left: auto; margin-right: auto">Check Settings</a>
            </div>
        </div>
        <div id="buttonbar">
            <button class="btn" id="button_previous">
                <pwm:if test="showIcons"><span class="btn-icon fa fa-backward"></span></pwm:if>
                <pwm:display key="Button_Previous" bundle="Config"/>
            </button>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <button class="btn" id="button_next">
                <pwm:if test="showIcons"><span class="btn-icon fa fa-forward"></span></pwm:if>
                <pwm:display key="Button_Next"  bundle="Config"/>
            </button>
        </div>
    </div>
    <div class="push"></div>
</div>
<pwm:script>
<script type="text/javascript">
    function handleFormActivity() {
        PWM_GUIDE.updateForm();
        clearHealthDiv();
        checkIfNextEnabled();
    }

    function clearHealthDiv() {
        var healthBodyObj = PWM_MAIN.getObject('healthBody');
        var newHtml = '<div style="text-align: center">';
        newHtml += '<a class="menubutton" style="max-width: 100px; margin-left: auto; margin-right: auto">Check Settings</a>';
        newHtml += '</div>';
        healthBodyObj.innerHTML = newHtml;
    }

    PWM_GLOBAL['startupFunctions'].push(function(){
        checkIfNextEnabled();

        PWM_MAIN.addEventHandler('button_next','click',function(){PWM_GUIDE.gotoStep('CR_STORAGE')});
        PWM_MAIN.addEventHandler('button_previous','click',function(){PWM_GUIDE.gotoStep('LDAP2')});

        PWM_MAIN.addEventHandler('configForm','input',function(){handleFormActivity()});
        PWM_MAIN.addEventHandler('healthBody','click',function(){loadHealth()});
    });

    function checkIfNextEnabled() {
        var fieldValue = PWM_MAIN.getObject('<%=ConfigGuideServlet.PARAM_LDAP2_TEST_USER%>').value;
        PWM_MAIN.getObject('button_next').disabled = false;
        if (fieldValue.length && fieldValue.length > 0) {
            if (PWM_GLOBAL['pwm-health'] !== 'GOOD' && PWM_GLOBAL['pwm-health'] !== 'CONFIG') {
                PWM_MAIN.getObject('button_next').disabled = true;
            }
        }
    }

    function loadHealth() {
        var options = {};
        options['sourceUrl'] = 'ConfigGuide?processAction=ldapHealth';
        options['showRefresh'] = false;
        options['refreshTime'] = -1;
        options['finishFunction'] = function(){
            PWM_MAIN.closeWaitDialog();
            checkIfNextEnabled();
        };
        PWM_MAIN.showWaitDialog();
        PWM_ADMIN.showAppHealth('healthBody', options);
    }
</script>
</pwm:script>
<% JspUtility.setFlag(pageContext, PwmRequest.Flag.HIDE_LOCALE); %>
<script type="text/javascript" src="<pwm:context/><pwm:url url="/public/resources/js/configguide.js"/>"></script>
<script type="text/javascript" src="<pwm:context/><pwm:url url="/public/resources/js/configmanager.js"/>"></script>
<script type="text/javascript" src="<pwm:context/><pwm:url url="/public/resources/js/admin.js"/>"></script>
<%@ include file="fragment/footer.jsp" %>
</body>
</html>
